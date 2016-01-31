//
//  InstructionViewController.swift
//  HesperusBridgeConfigurator
//
//  Created by Khaos Tian on 1/30/16.
//  Copyright © 2016 Oltica. All rights reserved.
//

import UIKit

class InstructionViewController: UIViewController, ConfigurableViewController {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var actionButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    weak var session: BridgeSetupSession?
    var configInfo: [String: AnyObject]?
    
    var actionURL: NSURL?

    override func viewDidLoad() {
        super.viewDidLoad()

        if let configInfo = configInfo {
            self.configureViewControllerWithInfo(configInfo, session: nil)
        }
        
        self.navigationItem.hidesBackButton = true
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Cancel, target: self, action: "didPressCancel:")
    }
    
    func didPressCancel(sender: AnyObject?) {
        self.dismissViewControllerAnimated(true, completion: {
            self.session?.userCancelSetupFromViewController(self)
        })
    }
    
    func didPressDoneButton(sender: AnyObject?) {
        self.session?.userDidFinishViewInstruction()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func configureViewControllerWithInfo(info: [String: AnyObject], session: BridgeSetupSession?) {
        self.configInfo = info
        
        if let session = session {
            self.session = session
        }
        
        if titleLabel != nil {
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
            
            if let showIndicator = info["showActivityIndicator"] as? Bool {
                if showIndicator {
                    self.activityIndicator.startAnimating()
                }
            }
            
            if let buttonText = info["buttonText"] as? String {
                self.actionButton.setTitle(buttonText, forState: .Normal)
            }
            
            if let actionURL = info["actionURL"] as? String {
                if let url = NSURL(string: actionURL) {
                    self.actionURL = url
                    self.actionButton.hidden = false
                }
            }
            
            if let showNextButton = info["showNextButton"] as? Bool {
                if showNextButton {
                    self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Next", style: .Done, target: self, action: "didPressDoneButton:")
                }
            }
            
            if let base64ImageData = info["heroImage"] as? String {
                if let data = NSData(base64EncodedString: base64ImageData, options: NSDataBase64DecodingOptions()),
                let heroImage = UIImage(data: data) {
                    self.imageView.image = heroImage
                    self.imageView.hidden = false
                }
            }
        }
    }
    
    @IBAction func didPressActionButton(sender: AnyObject) {
        if let actionURL = self.actionURL {
            UIApplication.sharedApplication().openURL(actionURL)
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
