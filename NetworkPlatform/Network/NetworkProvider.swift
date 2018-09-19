//
//  NetworkProvider.swift
//  NetworkPlatform
//
//  Created by Mobdev125 on 2/13/18.
//  Copyright © 2018 Mobdev125. All rights reserved.
//

import Domain

final class NetworkProvider {
    private let apiEndpoint: String
    
    private let blobEndPoint: String
    private let blobContainerName: String
    private let blobConnectionString: String
    
    let azureBlob: AzureBlob
    
    public init() {
        // Api
        apiEndpoint = "https://vocalvoter.azurewebsites.net"
        
        // Blob Storage
        blobEndPoint = "https://vocalvoterstorage.blob.core.windows.net/"
        blobContainerName = "vocalvoter-container"
        blobConnectionString = "DefaultEndpointsProtocol=https;AccountName=vocalvoterstorage;AccountKey=AhvTvaNvsz+WkbgODoA30PXSIM4QAbo19Fiff3aJBT1N2NyEvwwl0xWYtFk5QaesIDqUmO+NMxsqtbPNiCHXMA==;EndpointSuffix=core.windows.net"
        
        azureBlob = AzureBlob(blobEndPoint, containerName: blobContainerName, connectionString: blobConnectionString)
    }
    
    public func makeUsersNetwork() -> UsersNetwork {
        let network = Network<User>(apiEndpoint)
        return UsersNetwork(network: network)
    }
    
    public func makeImageNetwork() -> AzureBlob {
        return azureBlob
    }
    
    public func makeForgotPasswordNetwork() -> ForgotPasswordNetwork {
        let network = Network<Result>(apiEndpoint)
        return ForgotPasswordNetwork(network: network)
    }
}
