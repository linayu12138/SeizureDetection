//
//  ViewController.swift
//  seizureDetection
//
//  Created by Danqiao Yu on 2/9/20.
//  Copyright © 2020 EEGIICs. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    
    @IBOutlet weak var termCheckBox: Checkbox!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    

    @IBAction func continueToMain(_ sender: UIButton) {
        if !termCheckBox.isChecked {
            let termAlert = UIAlertController(title: "Please agree to the terms and conditions before proceeding", message: "", preferredStyle: UIAlertController.Style.alert)
            termAlert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: { (action) in termAlert.dismiss(animated: true, completion: nil)}))
            self.present(termAlert, animated: true, completion: nil)
        }
    }
}

