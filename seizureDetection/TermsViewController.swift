//
//  TermsViewController.swift
//  seizureDetection
//
//  Created by Danqiao Yu on 2/15/20.
//  Copyright © 2020 EEGIICs. All rights reserved.
//

import UIKit

class TermsViewController: UIViewController {

    @IBOutlet weak var termScrollView: UIScrollView!
    @IBOutlet weak var termLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        termScrollView.contentLayoutGuide.bottomAnchor.constraint(equalTo: termLabel.bottomAnchor).isActive = true
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
