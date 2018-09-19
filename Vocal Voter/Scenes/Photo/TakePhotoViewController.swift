//
//  TakePhotoViewController.swift
//  Vocal Voter
//
//  Created by Mobdev125 on 9/6/18.
//  Copyright © 2018 Mobdev125. All rights reserved.
//

import UIKit
import Material
import AVFoundation
import RxSwift
import RxCocoa

class TakePhotoViewController: SwiftyCamViewController {

    private let disposeBag = DisposeBag()
    
    var viewModel: TakePhotoViewModel!
    
    @IBOutlet weak var captureButton: SwiftyRecordButton!
    @IBOutlet weak var flashButton: RaisedButton!
    @IBOutlet weak var flipCameraButton: RaisedButton!
    @IBOutlet weak var closeButton: CloseButton!
    @IBOutlet weak var libraryButton: RaisedButton!
    @IBOutlet weak var titleLabel: UILabel!
    
    var imageSubject = PublishSubject<UIImage>()
    var imagePickerController: UIImagePickerController?
    var isAvatar: Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if isAvatar {
            titleLabel.text = "User Photo"
        }
        else {
            titleLabel.text = "Verification Photo"
        }
        shouldPrompToAppSettings = true
        cameraDelegate = self
        shouldUseDeviceOrientation = false
        allowAutoRotate = false
        audioEnabled = false
        maximumVideoDuration = 0.0
        
        // disable capture button until session starts
        captureButton.buttonEnabled = false
        
        libraryButton.image = Icon.cm.photoLibrary?.tint(with: UIColor.white)
        flashButton.image = #imageLiteral(resourceName: "flashOutline")
        flipCameraButton.image = #imageLiteral(resourceName: "flipCamera")
        
        bindViewModel()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        captureButton.delegate = self
    }
    
    private func bindViewModel() {
        assert(viewModel != nil)
        let input = TakePhotoViewModel.Input(closeTrigger: closeButton.rx.tap.asDriver(),
                                             libraryTrigger: libraryButton.rx.tap.asDriver(),
                                            flipTrigger: flipCameraButton.rx.tap.asDriver(),
                                            flashTrigger: flashButton.rx.tap.asDriver(),
                                            imageTrigger: imageSubject.asDriverOnErrorJustComplete())
        let output = viewModel.transform(input: input)
        
        output.close.drive().disposed(by: disposeBag)
        output.library.drive(libraryBinding).disposed(by: disposeBag)
        output.flip.drive(flipBinding).disposed(by: disposeBag)
        output.flash.drive(flashBinding).disposed(by: disposeBag)
        output.image.drive(imageBinding).disposed(by: disposeBag)
    }
    
    var libraryBinding: Binder<Void> {
        return Binder(self, binding: { (vc, _) in
            vc.imagePicker()
        })
    }
    
    var flipBinding: Binder<Void> {
        return Binder(self, binding: { (vc, _) in
            vc.switchCamera()
        })
    }
    
    var flashBinding: Binder<Void> {
        return Binder(self, binding: { (vc, _) in
            vc.flashEnabled = !vc.flashEnabled
            vc.toggleFlashAnimation()
        })
    }
    
    var imageBinding: Binder<UIImage> {
        return Binder(self, binding: { (vc, image) in
            if let pickerController = vc.imagePickerController {
                pickerController.dismiss(animated: true, completion: nil)
                vc.imagePickerController = nil
            }
        })
    }
}


// UI Animations
extension TakePhotoViewController {
    fileprivate func imagePicker() {
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            let imagePickerController = UIImagePickerController()
            imagePickerController.delegate = self
            imagePickerController.sourceType = .photoLibrary;
            imagePickerController.allowsEditing = false
            self.present(imagePickerController, animated: true, completion: nil)
        }
    }
    fileprivate func hideButtons() {
        UIView.animate(withDuration: 0.25) {
            self.flashButton.alpha = 0.0
            self.flipCameraButton.alpha = 0.0
        }
    }
    
    fileprivate func showButtons() {
        UIView.animate(withDuration: 0.25) {
            self.flashButton.alpha = 1.0
            self.flipCameraButton.alpha = 1.0
        }
    }
    
    fileprivate func focusAnimationAt(_ point: CGPoint) {
        let focusView = UIImageView(image: #imageLiteral(resourceName: "focus"))
        focusView.center = point
        focusView.alpha = 0.0
        view.addSubview(focusView)
        
        UIView.animate(withDuration: 0.25, delay: 0.0, options: .curveEaseInOut, animations: {
            focusView.alpha = 1.0
            focusView.transform = CGAffineTransform(scaleX: 1.25, y: 1.25)
        }) { (success) in
            UIView.animate(withDuration: 0.15, delay: 0.5, options: .curveEaseInOut, animations: {
                focusView.alpha = 0.0
                focusView.transform = CGAffineTransform(translationX: 0.6, y: 0.6)
            }) { (success) in
                focusView.removeFromSuperview()
            }
        }
    }
    
    fileprivate func toggleFlashAnimation() {
        if flashEnabled == true {
            flashButton.image = #imageLiteral(resourceName: "flash")
        } else {
            flashButton.image = #imageLiteral(resourceName: "flashOutline")
        }
    }
}

extension TakePhotoViewController : SwiftyCamViewControllerDelegate {
    func swiftyCamSessionDidStartRunning(_ swiftyCam: SwiftyCamViewController) {
        print("Session did start running")
        captureButton.buttonEnabled = true
    }
    
    func swiftyCamSessionDidStopRunning(_ swiftyCam: SwiftyCamViewController) {
        print("Session did stop running")
        captureButton.buttonEnabled = false
    }
    
    
    func swiftyCam(_ swiftyCam: SwiftyCamViewController, didTake photo: UIImage) {
        captureButton.buttonEnabled = false
        imageSubject.onNext(photo)
    }
    
    func swiftyCam(_ swiftyCam: SwiftyCamViewController, didFocusAtPoint point: CGPoint) {
        print("Did focus at point: \(point)")
        focusAnimationAt(point)
    }
    
    func swiftyCamDidFailToConfigure(_ swiftyCam: SwiftyCamViewController) {
        let message = NSLocalizedString("Unable to capture media", comment: "Alert message when something goes wrong during capture session configuration")
        let alertController = UIAlertController(title: "AVCam", message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Alert OK button"), style: .cancel, handler: nil))
        present(alertController, animated: true, completion: nil)
    }
}

extension TakePhotoViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
// Local variable inserted by Swift 4.2 migrator.
let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)

        if let image = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.originalImage)] as? UIImage, self.imagePickerController == nil {
            imagePickerController = picker
            self.imageSubject.onNext(image)
        }
    }
}


// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
	return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKey(_ input: UIImagePickerController.InfoKey) -> String {
	return input.rawValue
}
