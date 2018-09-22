//
//  ImageViewController.swift
//  Vocal Voter
//
//  Created by Mobdev125 on 9/21/18.
//  Copyright © 2018 Mobdev125. All rights reserved.
//

import UIKit

class ImageViewController: UIViewController {

    lazy var zoomingScrollView: UIScrollView = {
        let scrollView = UIScrollView(frame: self.getContentView().bounds)
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
    
    lazy var imageView: ImageView = {
        let view = ImageView(frame: self.getContentView().bounds)
        view.backgroundColor = .clear
        view.contentMode = .scaleAspectFit
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.isUserInteractionEnabled = true
        view.indicatorStyle = .whiteLarge
        view.delegate = self
        
        return view
    }()
    
    func maxZoomScale() -> CGFloat {
        guard let image = self.imageView.image else { return 1 }
        
        var widthFactor = CGFloat(1.0)
        var heightFactor = CGFloat(1.0)
        if image.size.width > self.getContentView().bounds.width {
            widthFactor = image.size.width / self.getContentView().bounds.width
        }
        if image.size.height > self.getContentView().bounds.height {
            heightFactor = image.size.height / self.getContentView().bounds.height
        }
        
        return max(2.0, max(widthFactor, heightFactor))
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
    
    @objc func tapAction(recognizer: UITapGestureRecognizer) {
        guard let nav = self.navigationController else {
            return
        }
        nav.isNavigationBarHidden = !nav.isNavigationBarHidden
    }

    func getContentView() -> UIView {
        
        return UIView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .black
        
        self.zoomingScrollView.addSubview(self.imageView)
        self.getContentView().insertSubview(self.zoomingScrollView, at: 0)
        
        let doubleTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(doubleTapAction))
        doubleTapRecognizer.numberOfTapsRequired = 2
        self.zoomingScrollView.addGestureRecognizer(doubleTapRecognizer)
        
//        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapAction))
//        tapRecognizer.numberOfTapsRequired = 1
//        self.zoomingScrollView.addGestureRecognizer(tapRecognizer)
    }
}

extension ImageViewController: UIScrollViewDelegate {
    
    func viewForZooming(in _: UIScrollView) -> UIView? {
        return self.imageView
    }
}

extension ImageViewController: ImageViewDelegate {
    func didLoadedImage(_ image: UIImage) {
        self.zoomingScrollView.maximumZoomScale = self.maxZoomScale()
    }
}
