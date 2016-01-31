//
//  TextInputTableViewCell.swift
//  HesperusBridgeConfigurator
//
//  Created by Khaos Tian on 1/30/16.
//  Copyright © 2016 Oltica. All rights reserved.
//

import UIKit

class TextInputTableViewCell: UITableViewCell, UITextFieldDelegate {

    var inputID: String!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var textField: UITextField!
    
    weak var viewController: TextInputViewController?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func textFieldDidChange(sender: AnyObject) {
        viewController?.textFieldDidChange(inputID, text: textField.text)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        return true
    }
}
