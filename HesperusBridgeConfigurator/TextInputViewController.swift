//
//  TextInputViewController.swift
//  HesperusBridgeConfigurator
//
//  Created by Khaos Tian on 1/30/16.
//  Copyright © 2016 Oltica. All rights reserved.
//

import UIKit

class TextInputViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, ConfigurableViewController {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var inputTableView: UITableView!
    
    var configInfo: [String: AnyObject]?
    
    var items: [[String: AnyObject]]?
    weak var session: BridgeSetupSession?
    
    var inputs = [String: String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let configInfo = configInfo {
            self.configureViewControllerWithInfo(configInfo, session: nil)
        }
        
        self.navigationItem.hidesBackButton = true
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Cancel, target: self, action: "didPressCancel:")
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Next", style: .Done, target: self, action: "didPressDoneButton:")
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillChange:", name: UIKeyboardWillChangeFrameNotification, object: nil)
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
        NSNotificationCenter.defaultCenter().removeObserver(self)
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
        self.session?.userDidFinishInput(inputs)
    }
    
    func configureViewControllerWithInfo(info: [String: AnyObject], session: BridgeSetupSession?) {
        self.configInfo = info
        
        if let session = session {
            self.session = session
        }
        
        if let listItems = info["items"] as? [[String: AnyObject]] {
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
            
            self.inputTableView.reloadData()
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.items?.count ?? 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("InputCell", forIndexPath: indexPath) as! TextInputTableViewCell
        
        cell.viewController = self
        
        if let item = self.items?[indexPath.row] {
            if let title = item["title"] as? String {
                cell.titleLabel.text = title
            } else {
                cell.titleLabel.text = ""
            }
            
            if let placeholder = item["placeholder"] as? String {
                cell.textField.placeholder = placeholder
            } else {
                cell.textField.placeholder = nil
            }
            
            if let secure = item["secure"] as? Bool {
                cell.textField.secureTextEntry = secure
            } else {
                cell.textField.secureTextEntry = false
            }
            
            if let inputID = item["id"] as? String {
                cell.inputID = inputID
            } else {
                cell.inputID = nil
            }
        }
        
        return cell
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
    }
    
    func textFieldDidChange(fieldID: String, text: String?) {
        inputs[fieldID] = text
    }
    
    func keyboardWillShow(note: NSNotification) {
        if let keyboardSize = (note.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.CGRectValue() {
            dispatch_async(dispatch_get_main_queue()) {
                let targetInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardSize.height, right: 0)
                self.inputTableView.contentInset = targetInset
                self.inputTableView.scrollIndicatorInsets = targetInset
            }
        }
    }
    
    func keyboardWillHide(note: NSNotification) {
        dispatch_async(dispatch_get_main_queue()) {
            self.inputTableView.contentInset = UIEdgeInsetsZero
            self.inputTableView.scrollIndicatorInsets = UIEdgeInsetsZero
        }
    }
    
    func keyboardWillChange(note: NSNotification) {
        if let keyboardSize = (note.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.CGRectValue() {
            dispatch_async(dispatch_get_main_queue()) {
                let targetInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardSize.height, right: 0)
                self.inputTableView.contentInset = targetInset
                self.inputTableView.scrollIndicatorInsets = targetInset
            }
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