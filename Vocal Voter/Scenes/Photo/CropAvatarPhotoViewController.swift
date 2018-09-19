//
//  PhotoViewController.swift
//  Vocal Voter
//
//  Created by Mobdev125 on 9/6/18.
//  Copyright © 2018 Mobdev125. All rights reserved.
//

import UIKit
import CropViewController
import RxSwift

class CropAvatarPhotoViewController: CropViewController {
    var imageSubject: PublishSubject<UIImage>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
    }
}

extension CropAvatarPhotoViewController: CropViewControllerDelegate {
    func cropViewController(_ cropViewController: CropViewController, didCropToCircularImage image: UIImage, withRect cropRect: CGRect, angle: Int) {
        assert(imageSubject != nil)
        imageSubject.onNext(image)
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
    
    func cropViewController(_ cropViewController: CropViewController, didCropToImage image: UIImage, withRect cropRect: CGRect, angle: Int) {
        assert(imageSubject != nil)
        imageSubject.onNext(image)
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
}


