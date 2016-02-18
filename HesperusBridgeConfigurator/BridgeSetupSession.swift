//
//  BridgeSetupSession.swift
//  HesperusBridgeConfigurator
//
//  Created by Khaos Tian on 1/30/16.
//  Copyright © 2016 Oltica. All rights reserved.
//

import UIKit
import HomeKit

protocol ConfigurableViewController {
    func configureViewControllerWithInfo(info: [String: AnyObject], session: BridgeSetupSession?)
}

class BridgeSetupSession {
    enum InterfaceType: String {
        case List = "list"
        case Input = "input"
        case Instruction = "instruction"
    }
    static let interfaceMap = [
        InterfaceType.List: "ListViewController",
        InterfaceType.Input: "TextInputViewController",
        InterfaceType.Instruction: "InstructionViewController"
    ]
    
    var name: String {
        get {
            return setupService.accessory?.name ?? "Unknown"
        }
    }
    
    var accessoryDelegate = AccessoryDelegate()
    
    var bridgeAccessory: HMAccessory!
    var setupService: HMService!
    
    var stateChar: HMCharacteristic!
    var versionChar: HMCharacteristic!
    var controlPointChar: HMCharacteristic!
    
    var navigationController: UINavigationController?
    
    var currentTransactionID: Int = 0
    var sessionUUID: String = ""
    
    var storyboard = UIStoryboard(name: "Main", bundle: nil)
    
    init?(service: HMService) {
        if service.serviceType != BridgeConfigurationServiceDef.ServiceUUID {
            return nil
        }
        
        if let accessory = service.accessory {
            self.bridgeAccessory = accessory
        } else {
            return nil
        }
        
        self.setupService = service
        
        if let stateChar = service.characteristics.filter({$0.characteristicType == BridgeConfigurationServiceDef.StateUUID}).first
        {
            self.stateChar = stateChar
            stateChar.enableNotification(true, completionHandler: {
                error in
                if let error = error {
                    NSLog("Error: \(error)")
                }
            })
        } else {
            return nil
        }
        
        if let versionChar = service.characteristics.filter({$0.characteristicType == BridgeConfigurationServiceDef.VersionUUID}).first
        {
            self.versionChar = versionChar
        } else {
            return nil
        }
        
        if let controlPointChar = service.characteristics.filter({$0.characteristicType == BridgeConfigurationServiceDef.ControlPointUUID}).first
        {
            self.controlPointChar = controlPointChar
            controlPointChar.enableNotification(true, completionHandler: {
                error in
                if let error = error {
                    NSLog("Error: \(error)")
                }
            })
        } else {
            return nil
        }
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "willEnterForeground:", name: UIApplicationWillEnterForegroundNotification, object: nil)
        
        self.accessoryDelegate.targetSession = self
        self.bridgeAccessory.delegate = self.accessoryDelegate
    }
    
    @objc func willEnterForeground(notification: NSNotification) {
        self.controlPointChar.readValueWithCompletionHandler({
            error in
            if let error = error {
                NSLog("Failed to update: \(error)")
            } else {
                if let data = self.controlPointChar.value as? NSData {
                    self.handleControlPointUpdate(data)
                }
            }
        })
    }
    
    func startSetupSession() -> UIViewController? {
        let request = NegotiateSessionRequest(transactionID: currentTransactionID)
        
        self.controlPointChar.writeValue(request.serializedData(), completionHandler: {
            error in
            if let error = error {
                NSLog("Error: \(error)")
            }
        })
        
        let loadingVC = self.storyboard.instantiateViewControllerWithIdentifier("LoadingViewController")
        self.navigationController = SetupNavigationViewController(rootViewController: loadingVC)
        return self.navigationController
    }
    
    func handleControlPointUpdate(data: NSData) {
        if let deserializedData = try? NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions()) as? [String: AnyObject], let response = deserializedData {
            if let tid = response["tid"] as? Int {
                if tid <= currentTransactionID {
                    // discard message
                    return
                }
                
                currentTransactionID = tid
                if let type = response["type"] as? String, let convertedType = ConfigurationCommandType(rawValue: type) {
                    switch convertedType {
                    case .Negotiate:
                        self.handleNegotiateResponse(response)
                    case .Interface:
                        self.handleInterfaceResponse(response)
                    case .Terminate:
                        self.handleTerminateResponse(response)
                    }
                }
            }
        }
    }
    
    func handleNegotiateResponse(response: [String: AnyObject]) {
        if let sid = response["sid"] as? String {
            self.sessionUUID = sid
        }
        
        if let attachment = response["attachment"] as? [String: AnyObject] {
            self.handleInterfaceResponse(attachment)
        }
    }
    
    func handleInterfaceResponse(response: [String: AnyObject]) {
        if let interfaceString = response["interface"] as? String,
            let targetInterface = InterfaceType(rawValue: interfaceString),
            let interfaceIdentifier = BridgeSetupSession.interfaceMap[targetInterface] {
            let viewController = self.storyboard.instantiateViewControllerWithIdentifier(interfaceIdentifier)
            
            if let viewController = viewController as? ConfigurableViewController {
                viewController.configureViewControllerWithInfo(response, session: self)
            }
            
            self.navigationController?.setViewControllers([viewController], animated: true)
        }
    }
    
    func handleTerminateResponse(response: [String: AnyObject]) {
        
    }
    
    func userSelectItemsWithIndexes(indexes: [Int]) {
        let request = InterfaceRequest(sessionUUID: self.sessionUUID,
                                       transactionID: self.currentTransactionID,
                                       response: ["selections": indexes])
        self.controlPointChar.writeValue(request.serializedData(), completionHandler: {
            error in
            if let error = error {
                NSLog("Error: \(error)")
            }
        })
        
        let loadingVC = self.storyboard.instantiateViewControllerWithIdentifier("LoadingViewController")
        self.navigationController?.setViewControllers([loadingVC], animated: true)
    }
    
    func userDidFinishInput(inputs: [String: String]) {
        let request = InterfaceRequest(sessionUUID: self.sessionUUID,
                                       transactionID: self.currentTransactionID,
                                       response: ["inputs": inputs])
        self.controlPointChar.writeValue(request.serializedData(), completionHandler: {
            error in
            if let error = error {
                NSLog("Error: \(error)")
            }
        })
        
        let loadingVC = self.storyboard.instantiateViewControllerWithIdentifier("LoadingViewController")
        self.navigationController?.setViewControllers([loadingVC], animated: true)
    }
    
    func userDidFinishViewInstruction() {
        let request = InterfaceRequest(sessionUUID: self.sessionUUID,
                                       transactionID: self.currentTransactionID,
                                       response: ["view": true])
        self.controlPointChar.writeValue(request.serializedData(), completionHandler: {
            error in
            if let error = error {
                NSLog("Error: \(error)")
            }
        })
        
        let loadingVC = self.storyboard.instantiateViewControllerWithIdentifier("LoadingViewController")
        self.navigationController?.setViewControllers([loadingVC], animated: true)
    }
    
    func userCancelSetupFromViewController(controller: UIViewController) {
        let request = TerminateRequest(sessionUUID: self.sessionUUID, transactionID: self.currentTransactionID)
        self.controlPointChar.writeValue(request.serializedData(), completionHandler: {
            error in
            if let error = error {
                NSLog("Error: \(error)")
            }
        })
    }
    
    func accessoryDidUpdateReachability(accessory: HMAccessory) {
        if !self.bridgeAccessory.reachable {
            if let navigationController = self.navigationController {
                navigationController.dismissViewControllerAnimated(true, completion: {
                    self.navigationController = nil
                })
            }
        }
    }
    
    func accessory(accessory: HMAccessory, service: HMService, didUpdateValueForCharacteristic characteristic: HMCharacteristic) {
        if characteristic == self.controlPointChar, let data = characteristic.value as? NSData {
            self.handleControlPointUpdate(data)
        }
    }
    
    class AccessoryDelegate: NSObject, HMAccessoryDelegate {
        weak var targetSession: BridgeSetupSession?
        
        func accessoryDidUpdateReachability(accessory: HMAccessory) {
            targetSession?.accessoryDidUpdateReachability(accessory)
        }
        
        func accessory(accessory: HMAccessory, service: HMService, didUpdateValueForCharacteristic characteristic: HMCharacteristic) {
            targetSession?.accessory(accessory, service: service, didUpdateValueForCharacteristic: characteristic)
        }
    }
}