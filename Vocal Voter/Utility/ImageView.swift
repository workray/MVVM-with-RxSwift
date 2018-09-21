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
    func didLoadedImage()
}
class ImageView: UIView {

    var delegate: ImageViewDelegate?
    
    lazy var imageView: UIImageView = {
        let view = UIImageView(frame: self.bounds)
        view.backgroundColor = .clear
        view.contentMode = .scaleAspectFill
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]        
        return view
    }()
    
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
    
    override var contentMode: UIView.ContentMode {
        get {
            return imageView.contentMode
        }
        set {
            imageView.contentMode = newValue
        }
    }
    
    var image: UIImage? {
        get {
            return imageView.image
        }
        set {
            if let task = imageTask {
                task.cancel()
                imageTask = nil
            }
            imageView.image = newValue
            self.isHidden = false
            self.activityIndicator.isHidden = true
            self.activityIndicator.stopAnimating()
            
            if delegate != nil {
                delegate?.didLoadedImage()
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
            imageTask = imageView.kf.setImage(with: URL(string: url), placeholder: self.image, options: nil, progressBlock: nil) {[unowned self] (image, error, cacheType, url) in
                self.imageTask = nil
                self.activityIndicator.isHidden = true
                self.activityIndicator.stopAnimating()
                if error != nil {
                    self.image = image
                    if self.delegate != nil {
                        self.delegate?.didLoadedImage()
                    }
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
        self.addSubview(imageView)
        self.addSubview(activityIndicator)
        
        activityIndicator.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        activityIndicator.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        
        self.isHidden = true
    }

}
