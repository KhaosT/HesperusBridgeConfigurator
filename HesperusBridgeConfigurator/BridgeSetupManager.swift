//
//  BridgeSetupManager.swift
//  HesperusBridgeConfigurator
//
//  Created by Khaos Tian on 1/30/16.
//  Copyright © 2016 Oltica. All rights reserved.
//

import Foundation
import HomeKit

class BridgeConfigurationServiceDef {
    static let ServiceUUID = "49FB9D4D-0FEA-4BF1-8FA6-E7B18AB86DCE"
    static let StateUUID = "77474A2F-FA98-485E-97BE-4762458774D8"
    static let VersionUUID = "FD9FE4CC-D06F-4FFE-96C6-595D464E1026"
    static let ControlPointUUID = "5819A4C2-E1B0-4C9D-B761-3EB1AFF43073"
}

class BridgeSetupManager {
    static let sharedManager = BridgeSetupManager()
    static let didUpdateSessionsNotification: String = "BridgeSetupManagerDidUpdateSessions"
    
    var homeManager: HMHomeManager
    var homeManagerDelegate: HomeManagerDelegate
    
    var currentHome: HMHome? {
        didSet {
            self.updateConfigurableAccessories()
        }
    }
    
    var configurableSessions = [BridgeSetupSession]()
    
    init() {
        self.homeManager = HMHomeManager()
        self.homeManagerDelegate = HomeManagerDelegate()
        self.homeManagerDelegate.targetManager = self
        self.homeManager.delegate = self.homeManagerDelegate
    }
    
    func handleHomeManagerUpdate() {
        self.currentHome = homeManager.primaryHome
    }
    
    func updateConfigurableAccessories() {
        guard let home = currentHome else {
            configurableSessions.removeAll()
            return
        }
        
        configurableSessions = home.accessories.flatMap({
            accessory in
            if let service = accessory.services.filter({$0.serviceType == BridgeConfigurationServiceDef.ServiceUUID}).first {
                return BridgeSetupSession(service: service)
            }
            
            return nil
        })
        
        NSNotificationCenter.defaultCenter().postNotificationName(BridgeSetupManager.didUpdateSessionsNotification, object: self)
    }
    
    class HomeManagerDelegate: NSObject, HMHomeManagerDelegate {
        weak var targetManager: BridgeSetupManager?
        
        func homeManagerDidUpdateHomes(manager: HMHomeManager) {
            targetManager?.handleHomeManagerUpdate()
        }
        
        func homeManagerDidUpdatePrimaryHome(manager: HMHomeManager) {
            targetManager?.handleHomeManagerUpdate()
        }
    }
}
