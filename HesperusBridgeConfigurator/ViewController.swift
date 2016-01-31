//
//  ViewController.swift
//  HesperusBridgeConfigurator
//
//  Created by Khaos Tian on 1/30/16.
//  Copyright © 2016 Oltica. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var sessionsTableView: UITableView!
    var noticeLabel: UILabel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "handleSessionsUpdate:", name: BridgeSetupManager.didUpdateSessionsNotification, object: nil)
        // Do any additional setup after loading the view, typically from a nib.
    }

    func handleSessionsUpdate(notification: NSNotification) {
        self.updateBackgroundNotice(BridgeSetupManager.sharedManager.configurableSessions.count == 0)
        sessionsTableView.reloadData()
    }
    
    func updateBackgroundNotice(display: Bool) {
        if display {
            if self.noticeLabel == nil {
                self.noticeLabel = UILabel(frame: CGRectZero)
                self.noticeLabel!.textColor = UIColor.lightGrayColor()
                self.noticeLabel!.font = UIFont.systemFontOfSize(17.0, weight: UIFontWeightRegular)
                self.noticeLabel!.textAlignment = NSTextAlignment.Center
                self.noticeLabel!.numberOfLines = 0
                self.noticeLabel!.text = "No configurable bridge available."
            }
            self.sessionsTableView.backgroundView = self.noticeLabel
        } else {
            self.noticeLabel?.removeFromSuperview()
            self.sessionsTableView.backgroundView = nil
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return BridgeSetupManager.sharedManager.configurableSessions.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("DefaultCell", forIndexPath: indexPath)
        
        let session = BridgeSetupManager.sharedManager.configurableSessions[indexPath.row]
        cell.textLabel?.text = session.name
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let session = BridgeSetupManager.sharedManager.configurableSessions[indexPath.row]
        if let vc = session.startSetupSession() {
            self.presentViewController(vc, animated: true, completion: nil)
        }
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
}

