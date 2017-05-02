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
    
    static func parseData(rawData: NSData) -> [String : AnyObject]? {
        
        do {
            if let json = try JSONSerialization.jsonObject(with: rawData as Data, options: JSONSerialization.ReadingOptions.allowFragments) as? [String : AnyObject] {
                return json
            } else {
                print("cannot serialize data returned in especified format")
            }
        } catch let error as NSError {
            print(error.description)
        }
        
        return nil
    }
}

class NetworkService: NSObject {
    static let sharedInstance = NetworkService()
    
    private override init(){
    }
    
    public func requestData(request:NSMutableURLRequest, callback:@escaping (AnyObject?, Error?)-> ()) {
        
        let session = URLSession.shared
        
        let task = session.dataTask(with: request as URLRequest) { (data, response, error) -> Void in
            
            if error != nil {
                callback(nil, NetError.FatalError((error?.localizedDescription)!))
                return
            }
            
            if let response = response as? HTTPURLResponse {
                
                switch response.statusCode {
                    
                case 200..<300:
                    callback(data as AnyObject, nil)
                case 401:
                    callback(nil, NetError.Forbidden(response.statusCode))
                case 404:
                    callback(nil, NetError.NotFound(response.statusCode))
                case let x where x >= 500:
                    callback(nil, NetError.ServerResponseError(response.statusCode))
                default:
                    callback("anything happened and I don know what!" as AnyObject?, NetError.Unknown)
                }
            } else {
                callback("no response from server." as AnyObject?, NetError.Unknown)
            }
        }
        
        task.resume()
    }
}
