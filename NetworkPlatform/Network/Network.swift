//
//  Network.swift
//  NetworkPlatform
//
//  Created by Mobdev125 on 2/13/18.
//  Copyright © 2018 Mobdev125. All rights reserved.
//

import Foundation
import Alamofire
import Domain
import RxAlamofire
import RxSwift
import ObjectMapper
import MicrosoftAzureMobile
import AZSClient

enum ErrorsToMappable: Error {
    case notMappable
    case unknown
}

final class Network<T: ImmutableMappable> {
    
    private let endPoint: String
    private let scheduler: ConcurrentDispatchQueueScheduler
    private let azureClient: MSClient
    
    init(_ endPoint: String) {
        self.endPoint = endPoint
        self.scheduler = ConcurrentDispatchQueueScheduler(qos: DispatchQoS(qosClass: DispatchQoS.QoSClass.background, relativePriority: 1))
        self.azureClient = MSClient(applicationURLString: endPoint)
    }
    
    // Azure Apis
    func getItemWithTable(_ tableName: String, itemId: String) -> Observable<T> {
        
        let publishSubject = PublishSubject<T>()
        let table = azureClient.table(withName: tableName);
        let predicate = NSPredicate(format: "id == %@", itemId)
        table.query(with: predicate).read { (result, error) in
            if let err = error {
                publishSubject.onError(err)
            }
            else if let json = result?.items?.first {
                do {
                    let item = try Mapper<T>().map(JSONObject: json)
                    publishSubject.onNext(item)
                }
                catch {
                    publishSubject.onError(ErrorsToMappable.notMappable)
                }
            }
        }
        return publishSubject
    }
    
    func getItemsWithTable(_ tableName: String, query: NSPredicate) -> Observable<[T]>{
        let publishSubject = PublishSubject<[T]>()
        let table = azureClient.table(withName: tableName);
        table.query(with: query).read { (result, error) in
            if let err = error {
                publishSubject.onError(err)
            }
            else {
                var items = [T]()
                if let array = result?.items {
                    do {
                        for dic in array {
                            let item = try Mapper<T>().map(JSONObject: dic)
                            items.append(item)
                        }
                    }
                    catch {
                        items.removeAll()
                        publishSubject.onError(ErrorsToMappable.notMappable)
                        return
                    }
                }
                publishSubject.onNext(items)
            }
        }
        return publishSubject
    }
    
    func postItemWithTable(_ tableName: String, item: [String: Any]) -> Observable<T> {
        let publishSubject = PublishSubject<T>()
        let table = azureClient.table(withName: tableName);
        table.insert(item) { (result, error) in
            if let err = error {
                publishSubject.onError(err)
            }
            else {
                do {
                    let item = try Mapper<T>().map(JSON: result as! [String : Any])
                    publishSubject.onNext(item)
                }
                catch {
                    publishSubject.onError(ErrorsToMappable.notMappable)
                }
            }
        }
        return publishSubject
    }
    
    func updateItemWithTable(_ tableName: String, item: [String: Any]) -> Observable<T> {
        let publishSubject = PublishSubject<T>()
        let table = azureClient.table(withName: tableName);
        table.update(item) { (result, error) in
            if let err = error {
                publishSubject.onError(err)
            }
            else {
                do {
                    let item = try Mapper<T>().map(JSON: result as! [String : Any])
                    publishSubject.onNext(item)
                }
                catch {
                    publishSubject.onError(ErrorsToMappable.notMappable)
                }
            }
        }
        return publishSubject
    }
    
    func deleteItemWithTable(_ tableName: String, itemId: String) -> Observable<Void> {
        let publishSubject = PublishSubject<Void>()
        let table = azureClient.table(withName: tableName);
        table.delete(withId: itemId) { (result, error) in
            if let err = error {
                publishSubject.onError(err)
            }
            else {
                publishSubject.onNext(())
            }
        }
        return publishSubject
    }
    
    // Rest APIs
    func getItems(_ path: String) -> Observable<[T]> {
        let absolutePath = "\(endPoint)/\(path)"
        return RxAlamofire
            .json(.get, absolutePath)
            .debug()
            .observeOn(scheduler)
            .map({ json -> [T] in
                return try Mapper<T>().mapArray(JSONObject: json)
            })
    }
    
    func getItem(_ path: String, itemId: String) -> Observable<T> {
        let absolutePath = "\(endPoint)/\(path)/\(itemId)"
        return RxAlamofire
            .request(.get, absolutePath)
            .debug()
            .observeOn(scheduler)
            .map({ json -> T in
                return try Mapper<T>().map(JSONObject: json)
            })
    }
    
    func postItem(_ path: String, parameters: [String: Any]) -> Observable<T> {
        let absolutePath = "\(endPoint)/\(path)"
        return RxAlamofire
            .requestJSON(HTTPMethod.post, absolutePath, parameters: parameters, encoding: JSONEncoding.default, headers: ["Content-Type" : "application/json"])
            .debug()
            .observeOn(scheduler)
            .map({ (response, json) -> T in
//                print(json)
//                if let dic = json as? [String: Any], let error = dic["error"] {
//                    throw NSError(domain: "", code: response.statusCode, userInfo: ["error": error])
//                }
                return try Mapper<T>().map(JSONObject: json)
            })
    }
    
    func updateItem(_ path: String, itemId: String, parameters: [String: Any]) -> Observable<T> {
        let absolutePath = "\(endPoint)/\(path)/\(itemId)"
        return RxAlamofire
            .request(.put, absolutePath, parameters: parameters)
            .debug()
            .observeOn(scheduler)
            .map({ json -> T in
                return try Mapper<T>().map(JSONObject: json)
            })
    }
    
    func deleteItem(_ path: String, itemId: String) -> Observable<T> {
        let absolutePath = "\(endPoint)/\(path)/\(itemId)"
        return RxAlamofire
            .request(.delete, absolutePath)
            .debug()
            .observeOn(scheduler)
            .map({ json -> T in
                return try Mapper<T>().map(JSONObject: json)
            })
    }
}
