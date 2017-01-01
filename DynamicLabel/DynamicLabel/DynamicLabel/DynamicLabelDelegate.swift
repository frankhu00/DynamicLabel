//
//  DynamicLabelDelegate.swift
//  Snaps
//
//  Created by Frank Hu on 12/20/16.
//  Copyright © 2016 Sugarcube. All rights reserved.
//

import Foundation

@objc public protocol DynamicLabelDelegate {
    
    //Returns error..debug only
    @objc optional func getError(error: String)
    
    //Returns label that is tapped on.
    //Does NOT require user to have tapped on a matching pattern
    @objc optional func didTapOnLabel(label: DynamicLabel)
    
    //Return keyword, label, and type of pattern upon ANY pattern tapped
    @objc optional func didSelectPattern(keyword: String, label: DynamicLabel, type: PatternType)
    
    //Return matching keyword & label upon hashtag pattern tapped
    @objc optional func hashtagHandler(keyword: String, label: DynamicLabel)
    
    //Return matching keyword & label upon mention pattern tapped
    @objc optional func mentionHandler(keyword: String, label: DynamicLabel)
    
    //Return matching keyword & label upon url pattern tapped
    //Overrides default URL handler upon method declaration
    //Can call urlDefaultHandler(keyword,label) inside customHandler
    @objc optional func urlCustomHandler(keyword: String, label: DynamicLabel)
    
    //Return matching keyword, pattern & label upon custom pattern tapped
    @objc optional func customHandler(keyword: String, pattern: String, label: DynamicLabel)
    
}

extension DynamicLabelDelegate {
    
    //Default implementation of URL handler
    public func urlDefaultHandler(keyword: String, label: DynamicLabel) {
        UIApplication.shared.open(URL(string: keyword)!, options: [:], completionHandler: nil)
    }
    
}
