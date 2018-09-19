//
//  ChangeVerificationPhotoViewController.swift
//  Vocal Voter
//
//  Created by Mobdev125 on 9/19/18.
//  Copyright © 2018 Mobdev125. All rights reserved.
//

import UIKit
import Domain
import RxSwift
import RxCocoa
import Material
import JGProgressHUD
import Kingfisher

class ChangeVerificationPhotoViewController: UIViewController {

    private let disposeBag = DisposeBag()
    
    var viewModel: ChangeVerificationPhotoViewModel!
    
    @IBOutlet weak var backButton: UIBarButtonItem!
    @IBOutlet weak var takePhotoButton: UIBarButtonItem!
    
    @IBOutlet weak var contentView: UIView!
    
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
    
    let hud = JGProgressHUD(style: .dark)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        backButton.image = Icon.cm.arrowBack
        takePhotoButton.image = Icon.cm.photoCamera
        
        self.view.backgroundColor = .black
        
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
            .mapToVoid().take(1)
            .asDriverOnErrorJustComplete()
        let input = ChangeVerificationPhotoViewModel.Input(
            initialTrigger: viewWillAppear,
            backTrigger: backButton.rx.tap.asDriver(),
            photoTrigger: takePhotoButton.rx.tap.asDriver())
        let output = viewModel.transform(input: input)
        
        output.back.drive().disposed(by: disposeBag)
        output.image.drive(imageBinding).disposed(by: disposeBag)
        output.imageUrl.drive(updateBinding).disposed(by: disposeBag)
        output.takePhoto.drive().disposed(by: disposeBag)
        output.updateVerificationPhoto.drive().disposed(by: disposeBag)
        output.deleteOldVerificationPhoto.drive(completedBinding).disposed(by: disposeBag)
        output.verificationPhoto.drive(verificationPhotoBinding).disposed(by: disposeBag)
        output.error.drive(errorBinding).disposed(by: disposeBag)
        output.activityIndicator.drive().disposed(by: disposeBag)
    }
    
    var imageBinding: Binder<UIImage> {
        return Binder(self, binding: { (vc, image) in
            vc.image = image
            vc.imageView.image = image
            vc.zoomingScrollView.maximumZoomScale = vc.maxZoomScale()
            
            vc.hud.textLabel.text = "Uploading verification photo..."
            vc.hud.show(in: self.view)
        })
    }
    
    var updateBinding: Binder<Void> {
        return Binder(self, binding: { (vc, _) in
            vc.hud.textLabel.text = "Updating..."
        })
    }
    
    var verificationPhotoBinding: Binder<String> {
        return Binder(self, binding: { (vc, verificationUrl) in
            vc.imageView.kf.setImage(with: URL(string: verificationUrl), placeholder: vc.image, options: nil, progressBlock: nil, completionHandler: { [unowned self] (image, error, cacheType, url) in
                self.image = image
                self.zoomingScrollView.maximumZoomScale = self.maxZoomScale()
            })
        })
    }
    
    var completedBinding: Binder<Void> {
        return Binder(self, binding: { (vc, _) in
            vc.hud.dismiss()
            let hud = JGProgressHUD(style: .dark)
            hud.indicatorView = JGProgressHUDSuccessIndicatorView()
            hud.textLabel.text = "Verification photo changed successfully!"
            hud.show(in: vc.view)
            hud.dismiss(afterDelay: 2.0, animated: true)
        })
    }
    
    var errorBinding: Binder<Error> {
        return Binder(self, binding: { (vc, error) in
            vc.hud.dismiss()
            vc.showErrorMsg(error.localizedDescription)
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
}

extension ChangeVerificationPhotoViewController: UIScrollViewDelegate {
    
    func viewForZooming(in _: UIScrollView) -> UIView? {
        return self.imageView
    }
}
