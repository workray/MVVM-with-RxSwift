//
//  VerificationPhotoViewController.swift
//  Vocal Voter
//
//  Created by Mobdev125 on 9/6/18.
//  Copyright © 2018 Mobdev125. All rights reserved.
//

import UIKit
import Domain
import RxSwift
import RxCocoa
import Material
import JGProgressHUD
import Kingfisher

class VerificationPhotoViewController: UIViewController {
    
    private let disposeBag = DisposeBag()
    
    var viewModel: VerificationPhotoViewModel!
    
    @IBOutlet weak var backButton: BackButton!
    @IBOutlet weak var imageButton: RaisedButton!
    @IBOutlet weak var doneButton: RaisedButton!
    @IBOutlet weak var contentView: UIView!
    
    let hud = JGProgressHUD(style: .dark)
    
    lazy var zoomingScrollView: UIScrollView = {
        let scrollView = UIScrollView(frame: self.contentView.bounds)
        scrollView.delegate = self
        scrollView.backgroundColor = .clear
        scrollView.alwaysBounceVertical = false
        scrollView.alwaysBounceHorizontal = false
        scrollView.showsVerticalScrollIndicator = true
        scrollView.flashScrollIndicators()
        scrollView.minimumZoomScale = 1.0
        scrollView.maximumZoomScale = self.maxZoomScale()
        scrollView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        return scrollView
    }()
    
    lazy var imageView: UIImageView = {
        let view = UIImageView(frame: self.contentView.bounds)
        view.backgroundColor = .clear
        view.contentMode = .scaleAspectFit
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.isUserInteractionEnabled = true
        
        return view
    }()
    
    var image: UIImage?
    
    func maxZoomScale() -> CGFloat {
        guard let image = self.imageView.image else { return 1 }
        
        var widthFactor = CGFloat(1.0)
        var heightFactor = CGFloat(1.0)
        if image.size.width > self.contentView.bounds.width {
            widthFactor = image.size.width / self.contentView.bounds.width
        }
        if image.size.height > self.contentView.bounds.height {
            heightFactor = image.size.height / self.contentView.bounds.height
        }
        
        return max(2.0, max(widthFactor, heightFactor))
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.view.backgroundColor = .black
        
        imageButton.image = Icon.cm.photoCamera?.tint(with: UIColor.white)
        
        self.zoomingScrollView.addSubview(self.imageView)
        self.contentView.addSubview(self.zoomingScrollView)
        
        let doubleTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(VerificationPhotoViewController.doubleTapAction))
        doubleTapRecognizer.numberOfTapsRequired = 2
        self.zoomingScrollView.addGestureRecognizer(doubleTapRecognizer)
        
        bindViewModel()
    }
    
    private func bindViewModel() {
        assert(viewModel != nil)
        let viewWillAppear = rx.sentMessage(#selector(UIViewController.viewWillAppear(_:)))
            .mapToVoid()
            .take(1)
            .asDriverOnErrorJustComplete()
        let doneTrigger = doneButton.rx.tap.flatMap { [unowned self] in
            return Driver.just(self.imageView.image != nil)
        }
        let input = VerificationPhotoViewModel.Input(initialTrigger: viewWillAppear,
                                            backTrigger: backButton.rx.tap.asDriver(),
                                            photoTrigger: imageButton.rx.tap.asDriver(),
                                            doneTrigger: doneTrigger.asDriverOnErrorJustComplete())
        let output = viewModel.transform(input: input)
        
        output.initial.drive().disposed(by: disposeBag)
        output.back.drive().disposed(by: disposeBag)
        output.photo.drive().disposed(by: disposeBag)
        output.profile.drive(profileBinding).disposed(by: disposeBag)
        output.done.drive(onNext: { [unowned self] (valid) in
            if (valid) {
                self.hud.textLabel.text = "Uploading user photo..."
                self.hud.show(in: self.view)
            }
            else {
                self.showErrorMsg("Verification photo should be existed!")
            }
        }).disposed(by: disposeBag)
        output.uploadUserPhoto.drive(onNext: { [unowned self] (profile) in
            self.hud.textLabel.text = "Uploading verification photo..."
        }).disposed(by: disposeBag)
        output.uploadVerificationPhoto.drive(onNext: { [unowned self] (profile) in
            self.hud.textLabel.text = "Registering..."
        }).disposed(by: disposeBag)
        output.registerUser.drive(onNext: { [unowned self] (profile) in
            self.hud.dismiss()
        }).disposed(by: disposeBag)
        output.error.drive(onNext: { [unowned self] (error) in
            self.hud.dismiss()
            self.showErrorMsg(error.localizedDescription)
        }).disposed(by: disposeBag)
        output.activityIndicator.drive().disposed(by: disposeBag)
    }
    
    var profileBinding: Binder<Profile> {
        return Binder(self, binding: { (vc, profile) in
            if profile.verificationPhoto != nil {
                vc.image = profile.verificationPhoto
                vc.display()
            }
            else if !profile.user.verificationUrl.isEmpty {
                vc.imageView.kf.setImage(with: URL(string: profile.user.verificationUrl))
                vc.zoomingScrollView.maximumZoomScale = self.maxZoomScale()
            }
        })
    }
    
    @objc func doubleTapAction(recognizer: UITapGestureRecognizer) {
        let zoomScale = self.zoomingScrollView.zoomScale == 1 ? self.maxZoomScale() : 1
        
        let touchPoint = recognizer.location(in: self.imageView)
        
        let scrollViewSize = self.imageView.bounds.size
        
        let width = scrollViewSize.width / zoomScale
        let height = scrollViewSize.height / zoomScale
        let originX = touchPoint.x - (width / 2.0)
        let originY = touchPoint.y - (height / 2.0)
        
        let rectToZoomTo = CGRect(x: originX, y: originY, width: width, height: height)
        
        self.zoomingScrollView.zoom(to: rectToZoomTo, animated: true)
    }
    
    func display() {
        if let image = image {
            self.imageView.image = image
            self.zoomingScrollView.maximumZoomScale = self.maxZoomScale()
        }
    }
}

extension VerificationPhotoViewController: UIScrollViewDelegate {
    
    func viewForZooming(in _: UIScrollView) -> UIView? {
        return self.imageView
    }
}
