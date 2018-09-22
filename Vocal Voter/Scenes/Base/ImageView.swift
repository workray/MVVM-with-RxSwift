//
//  ImageView.swift
//  Vocal Voter
//
//  Created by Mobdev125 on 9/21/18.
//  Copyright © 2018 Mobdev125. All rights reserved.
//

import UIKit
import Kingfisher

protocol ImageViewDelegate {
    func didLoadedImage(_ image: UIImage)
}
class ImageView: UIImageView {

    var delegate: ImageViewDelegate?
    
//    lazy var imageView: UIImageView = {
//        let view = UIImageView(frame: self.bounds)
//        view.backgroundColor = .clear
//        view.contentMode = .scaleAspectFill
//        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
//        return view
//    }()
    
    lazy var activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.white)
        indicator.center = self.center
        return indicator
    }()
    
    var indicatorStyle:UIActivityIndicatorView.Style {
        get {
            return self.activityIndicator.style
        }
        set {
            self.activityIndicator.style = newValue
        }
    }
    
//    override var contentMode: UIView.ContentMode {
//        get {
//            return imageView.contentMode
//        }
//        set {
//            imageView.contentMode = newValue
//        }
//    }
    
    override var image: UIImage? {
        didSet {
            if let task = imageTask {
                task.cancel()
                imageTask = nil
            }
            self.isHidden = false
            self.activityIndicator.isHidden = true
            self.activityIndicator.stopAnimating()
            
            guard let newImage = self.image else {
                return
            }
            
            if delegate != nil {
                delegate?.didLoadedImage(newImage)
            }
        }
    }
    var imageTask: RetrieveImageTask?
    var imageUrl: String? {
        didSet {
            guard let url = imageUrl else {
                return
            }
            if let task = imageTask {
                task.cancel()
            }
            self.isHidden = false
            activityIndicator.startAnimating()
            activityIndicator.isHidden = false
            imageTask = self.kf.setImage(with: URL(string: url), placeholder: self.image, options: nil, progressBlock: nil) {[unowned self] (image, error, cacheType, url) in
                self.imageTask = nil
                self.activityIndicator.isHidden = true
                self.activityIndicator.stopAnimating()
                if error != nil, let newImage = image {
                    self.image = newImage
                }
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        prepareLayout()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        prepareLayout()
    }
    
    private func prepareLayout() {
        self.addSubview(activityIndicator)
        
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        activityIndicator.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        
        self.isHidden = true
    }

}
