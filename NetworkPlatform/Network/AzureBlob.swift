//
//  AzureBlob.swift
//  NetworkPlatform
//
//  Created by Mobdev125 on 9/8/18.
//  Copyright © 2018 Mobdev125. All rights reserved.
//

import AZSClient
import RxSwift

final class AzureBlob {
    private let endPoint: String
    private let containerName: String
    private let connectionString: String
    
    var container: AZSCloudBlobContainer!
    
    init(_ endPoint: String,
         containerName: String,
         connectionString: String) {
        self.endPoint = endPoint
        self.containerName = containerName
        self.connectionString = connectionString

        let storageAccount: AZSCloudStorageAccount
        try! storageAccount = AZSCloudStorageAccount(fromConnectionString: connectionString)
        let blobClient = storageAccount.getBlobClient()
        container = blobClient.containerReference(fromName: containerName)
        
        let condition = NSCondition()
        var containerCreated = false
        
        container.createContainerIfNotExists(completionHandler: { (error, created) in
            containerCreated = true
            if error == nil {
                condition.lock()
                condition.signal()
                condition.unlock()
            }
        })
        
        condition.lock()
        while !containerCreated {
            condition.wait()
        }
        condition.unlock()
    }
    
    func uploadImageToBlobContainer(_ blobName: String, filePath: String) -> Observable<String> {
        let subject = PublishSubject<String>.init()
        let blob = container.blockBlobReference(fromName: blobName)
        blob.uploadFromFile(withPath: filePath) { [unowned self] (error) in
            if let error = error {
                subject.onError(error)
            }
            else {
                subject.onNext("\(self.endPoint)\(blobName)")
            }
        }
        return subject
    }
    
    func uploadImageToBlobContainer(_ blobName: String, data: Data) -> Observable<String> {
        let subject = PublishSubject<String>.init()
        let blob = container.blockBlobReference(fromName: blobName)
        blob.upload(from: data) { (error) in
            if let error = error {
                subject.onError(error)
            }
            else {
                subject.onNext("\(self.endPoint)\(blobName)")
            }
        }
        return subject
    }
    
    func deleteImageFromBlobContainer(_ blobName: String) -> Observable<Void> {
        let subject = PublishSubject<Void>.init()
        let blob = container.blockBlobReference(fromName: blobName)
        blob.delete { (error) in
            if let error = error {
                subject.onError(error)
            }
            else {
                subject.onNext(())
            }
        }
        return subject
    }
}
