//
//  BridgeRequests.swift
//  HesperusBridgeConfigurator
//
//  Created by Khaos Tian on 1/30/16.
//  Copyright © 2016 Oltica. All rights reserved.
//

import Foundation

enum ConfigurationCommandType: String {
    case Negotiate = "Negotiate"
    case Interface = "Interface"
    case Terminate = "Terminate"
}

protocol BridgeRequest {
    func serializedData() -> NSData?
}


/**
 Negotiate Request
 
- parameters:
    - type: Negotiate
    - language: user preferred language
 */
struct NegotiateSessionRequest: BridgeRequest {
    let transactionID: Int
    let preferedLanguage = NSLocale.preferredLanguages().first!
    
    func serializedData() -> NSData? {
        let requestDict = [
            "tid": transactionID,
            "type": ConfigurationCommandType.Negotiate.rawValue,
            "language": preferedLanguage
        ]
        
        let requestData = try! NSJSONSerialization.dataWithJSONObject(requestDict, options: NSJSONWritingOptions())
        
        return requestData
    }
}

struct InterfaceRequest: BridgeRequest {
    let sessionUUID: String
    let transactionID: Int
    let response: [String: AnyObject]
    
    func serializedData() -> NSData? {
        let requestDict = [
            "tid": transactionID,
            "type": ConfigurationCommandType.Interface.rawValue,
            "sid": sessionUUID,
            "response": response
        ]
        
        let requestData = try! NSJSONSerialization.dataWithJSONObject(requestDict, options: NSJSONWritingOptions())
        
        return requestData
    }
}

struct TerminateRequest: BridgeRequest {
    let sessionUUID: String
    let transactionID: Int
    
    func serializedData() -> NSData? {
        let requestDict = [
            "tid": transactionID,
            "type": ConfigurationCommandType.Terminate.rawValue,
            "sid": sessionUUID
        ]
        
        let requestData = try! NSJSONSerialization.dataWithJSONObject(requestDict, options: NSJSONWritingOptions())
        
        return requestData
    }
}