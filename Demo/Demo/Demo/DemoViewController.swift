//
//  DemoViewController.swift
//
//
//  Created by Frank Hu on 12/30/16.
//  Copyright © 2016 Sugarcube. All rights reserved.
//

import UIKit
import DynamicLabel

class DemoViewController: UIViewController, DynamicLabelDelegate {

    let text1 = "This is a sample @demo with #hashtag and #links to @google (https://google.com)!"
    
    let text2 = "Custom matches like (123) 111-7895 or $102.97 or &RNGBlessMe but not @mentions and #hashtags!"
    
    let text3 = "古池や蛙飛び込む水の音 ふるいけやかわずとびこむみずのおと @Haiku #Japanese &user123 but not links like https://google.com or $102.97. Oh &飛音 is cool"
    
    let pattern1 = "(\\s|\\()?\\d{3}\\)?\\s\\d{3}[\\s-]\\d{4}\\s*"
    let pattern2 = "(\\s|\\b)?[$](\\s)?(\\d)+([.]\\d{2})?"
    let pattern3 = "(?:^|\\s|$)&[\\p{L}0-9_]*"
    
    //(?:^|\\s|$)#[\\p{L}0-9_]*
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        setup()
    }

    func setup() {
        let xCenter = view.center.x
        
        let label1 = DynamicLabel()
        label1.frame.size.width = 200
        label1.center.x = xCenter
        label1.center.y = 60
        label1.delegate = self
        label1.text = text1
        
        //Use editStyles(block) to minimize redundant parses
        let label2 = DynamicLabel()
        label2.editStyles({label2 in
            label2.frame.size.width = 200
            label2.center.x = xCenter
            label2.center.y = 180
            
            label2.customColor = UIColor.cyan
            
            label2.delegate = self
            label2.text = text2
            label2.enabledParses = [.custom(pattern1), .custom(pattern2), .custom(pattern3)]
        })
        
        let label3 = DynamicLabel()
        label3.editStyles({label in
            label.frame.size.width = 200
            label.center.x = xCenter
            label.center.y = 340
            
            label.customColor = UIColor.magenta
            
            label.delegate = self
            label.text = text3
            label.enabledParses = [.custom(pattern3), .hash, .mention]
        })
        
        view.addSubview(label1)
        view.addSubview(label2)
        view.addSubview(label3)
    }
    
    
    //DynamicLabelDelegation Method
    
    func hashtagHandler(keyword: String, label: DynamicLabel) {
        alert(keyword)
    }
    
    func mentionHandler(keyword: String, label: DynamicLabel) {
        alert(keyword)
    }
    
    func urlCustomHandler(keyword: String, label: DynamicLabel) {
        alert("Custom URL handler with URL: \(keyword)")
        
        //Runs default url handler
        self.urlDefaultHandler(keyword: keyword, label: label)
    }
    
    func customHandler(keyword: String, pattern: String, label: DynamicLabel) {
        switch pattern {
        case pattern1:
            alert("Pattern 1 Matched. Keyword: \(keyword)")
        case pattern2:
            alert("Pattern 2 Matched. Keyword: \(keyword)")
        case pattern3:
            alert("Pattern 3 Matched. Keyword: \(keyword)")
        default:
            return
        }
    }
    
    func alert(_ message: String) {
        let alert = UIAlertController(title: "You clicked on", message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}

