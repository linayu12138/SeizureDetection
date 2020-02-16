//
//  Checkbox.swift
//  seizureDetection
//
//  Created by Danqiao Yu on 2/10/20.
//  Copyright © 2020 EEGIICs. All rights reserved.
//

import UIKit

class Checkbox: UIButton {

    // Images
    let checkedImage = UIImage(named: "checked")
    let uncheckedImage = UIImage(named: "unchecked")
    
    //bool propety
    @IBInspectable var isChecked:Bool = false{
        didSet{
            self.updateImage()
        }
    }

    
    override func awakeFromNib() {
        self.addTarget(self, action: #selector(Checkbox.buttonClicked), for: UIControl.Event.touchUpInside)
        self.updateImage()
    }
    
    
    func updateImage() {
        if isChecked == true{
            self.setImage(checkedImage, for: .normal)
        }else{
            self.setImage(uncheckedImage, for: .normal)
        }

    }

    @objc func buttonClicked(sender:UIButton) {
        if(sender == self){
            isChecked = !isChecked
        }
    }
}
