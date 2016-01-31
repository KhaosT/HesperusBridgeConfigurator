//
//  ListViewController.swift
//  HesperusBridgeConfigurator
//
//  Created by Khaos Tian on 1/30/16.
//  Copyright © 2016 Oltica. All rights reserved.
//

import UIKit

class ListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, ConfigurableViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var selectionTableView: UITableView!
    
    var configInfo: [String: AnyObject]?
    
    var items: [String]?
    weak var session: BridgeSetupSession?
    
    var selectedIndex = Set<Int>()
    var allowMultiple = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let configInfo = configInfo {
            self.configureViewControllerWithInfo(configInfo, session: nil)
        }
        
        self.navigationItem.hidesBackButton = true
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Cancel, target: self, action: "didPressCancel:")
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func didPressCancel(sender: AnyObject?) {
        self.dismissViewControllerAnimated(true, completion: {
            self.session?.userCancelSetupFromViewController(self)
        })
    }
    
    func didPressDoneButton(sender: AnyObject?) {
        self.session?.userSelectItemsWithIndexes(Array(self.selectedIndex))
    }
    
    func configureViewControllerWithInfo(info: [String: AnyObject], session: BridgeSetupSession?) {
        self.configInfo = info
        
        if let session = session {
            self.session = session
        }
        
        if let listItems = info["items"] as? [String] {
            self.items = listItems
        }
        
        if self.titleLabel != nil {
            if let title = info["title"] as? String {
                self.titleLabel.text = title
            } else {
                self.titleLabel.text = nil
            }
            
            if let detail = info["detail"] as? String {
                self.detailLabel.text = detail
            } else {
                self.detailLabel.text = nil
            }
            
            if let allowMultiple = info["allowMultipleSelection"] as? Bool {
                if allowMultiple {
                    self.allowMultiple = true
                    self.selectionTableView.allowsMultipleSelection = true
                    self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Next", style: .Done, target: self, action: "didPressDoneButton:")
                }
            }
            
            self.selectionTableView.reloadData()
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.items?.count ?? 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("DefaultCell", forIndexPath: indexPath)
        
        if let item = self.items?[indexPath.row] {
            cell.textLabel?.text = item
        }
        
        return cell
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if !allowMultiple {
            self.session?.userSelectItemsWithIndexes([indexPath.row])
        } else {
            self.selectedIndex.insert(indexPath.row)
        }
    }
    
    func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        if allowMultiple {
            self.selectedIndex.remove(indexPath.row)
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
