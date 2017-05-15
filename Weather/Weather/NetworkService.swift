//
//  NetworkPovider.swift
//  Weather
//
//  Created by WELLINGTON BARBOSA on 24/02/17.
//  Copyright © 2017 WELLINGTON BARBOSA. All rights reserved.
//

import Foundation 
import UIKit

enum NetError : Error, CustomStringConvertible {
    case NotFound(Int)
    case Forbidden(Int)
    case ServerResponseError(Int)
    case FatalError(String)
    case Unknown
    
    var description:String {
        
        switch self {
            case let .NotFound(statusCode):
                return "Página não encontrada (Erro \(statusCode))"
            case let .Forbidden(statusCode):
                return "Acesso não permitido (Erro \(statusCode))"
            case let .ServerResponseError(statusCode):
                return "Servidor não está respondendo no momento (Erro \(statusCode))"
            case let .FatalError(errorDescription):
                return "Fatal error: \(errorDescription)"
            default:
                return "Erro desconhecido"
        }
    }
}

struct Parser {
    
    func parseData(rawData: NSData) -> [String : AnyObject]? {
        do {
            if let json = try JSONSerialization.jsonObject(with: rawData as Data, options: JSONSerialization.ReadingOptions.allowFragments) as? [String : AnyObject] {
                return json
            }
        } catch let error as NSError {
            print(error.description)
        }
        
        print("cannot serialize data returned in especified format")
        return nil
    }
}

protocol NetworkServiceDelegate {
    func callback(url: String, data: AnyObject?, error: Error?)
}

class NetworkService: NSObject, URLSessionDataDelegate {
    
    private var dataTask : URLSessionDataTask?
    private var delegate: NetworkServiceDelegate?
    
    init(delegate: NetworkServiceDelegate){
        self.delegate = delegate
    }
    
    func requestData(request:NSMutableURLRequest) {
        let configuration = URLSessionConfiguration.background(withIdentifier: (request.url?.absoluteString)!)
        let session = URLSession(configuration: configuration, delegate: self, delegateQueue: OperationQueue())
        group.enter()
        dataTask = session.dataTask(with: request as URLRequest)
        dataTask?.resume()
    }
    
    let semaphore = DispatchSemaphore(value: 0)
    
    let group = DispatchGroup()
    
    func bulkRequestData(requests: [NSMutableURLRequest], downloadCallback: @escaping (Bool)->()) {
        for request in requests {
            let session = URLSession.shared
            group.enter()
            session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) in
                debugPrint("session.dataTask")
                session.finishTasksAndInvalidate()
                let url = request.url?.absoluteString
                self.update(url: url!, data: data, response: response, error: error)
                self.group.leave()
            }).resume()
        }
        group.notify(queue: DispatchQueue.main, execute: {
            print("All Done");
            downloadCallback(true)
        })
    }
    
    func cancel(){
        dataTask?.cancel()
    }
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data){
        debugPrint("urlSession: didReceive")
        let url = dataTask.currentRequest?.url?.absoluteString
        dataTask.cancel()
        session.finishTasksAndInvalidate()
        group.leave()
        update(url: url!, data: data, response: dataTask.response, error: dataTask.error)
    }
    
    private func update(url: String, data: Data?, response: URLResponse?, error: Error?) {
        if  let _error = error {
            delegate?.callback(url: url, data: nil, error: NetError.FatalError((_error.localizedDescription)))
            return
        }
        
        if let _response = response as? HTTPURLResponse {
            switch _response.statusCode {
                
            case 200..<300:
                delegate?.callback(url: url, data: data as AnyObject, error: nil)
            case 401:
                delegate?.callback(url: url, data: nil, error: NetError.Forbidden(_response.statusCode))
            case 404:
                delegate?.callback(url: url, data: nil, error: NetError.NotFound(_response.statusCode))
            case let x where x >= 500:
                delegate?.callback(url: url, data: nil, error: NetError.ServerResponseError(_response.statusCode))
            default:
                delegate?.callback(url: url, data: "anything happened and I don know what!" as AnyObject?, error: NetError.Unknown)
            }
        } else {
            delegate?.callback(url: url, data: "no response from server." as AnyObject?, error: NetError.Unknown)
        }
    }
}
