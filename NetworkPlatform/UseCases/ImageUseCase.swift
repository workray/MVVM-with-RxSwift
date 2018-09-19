//
//  ImageUseCase.swift
//  NetworkPlatform
//
//  Created by Mobdev125 on 9/8/18.
//  Copyright © 2018 Mobdev125. All rights reserved.
//

import UIKit
import Domain
import RxSwift

class ImageUseCase: Domain.ImageUseCase {
    
    private let blob: AzureBlob
    
    init(blob: AzureBlob) {
        self.blob = blob
    }
    
    func uploadImage(_ blobName: String, filePath: String) -> Observable<String> {
        return blob.uploadImageToBlobContainer(blobName, filePath: filePath)
    }
    
    func uploadImage(_ blobName: String, data: Data) -> Observable<String> {
        return blob.uploadImageToBlobContainer(blobName, data:data)
    }
    
    func deleteImage(_ imageUrl: String) -> Observable<Void> {
        return blob.deleteImageFromBlobContainer(imageUrl)
    }
}
