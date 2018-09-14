//
//  ImageUseCase.swift
//  Domain
//
//  Created by Mobdev125 on 9/7/18.
//  Copyright © 2018 Mobdev125. All rights reserved.
//

import UIKit
import RxSwift

public protocol ImageUseCase {
    func uploadImage(_ blobName: String, filePath: String) -> Observable<String>
    
    func uploadImage(_ blobName: String, data: Data) -> Observable<String>
    
    func deleteImage(_ blobName: String) -> Observable<Void>
}
