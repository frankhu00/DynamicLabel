//
//  RegexParser.swift
//  Snaps
//
//  Created by Frank Hu on 12/21/16.
//  Copyright © 2016 Sugarcube. All rights reserved.
//

import Foundation

internal class RegexParser {
    
    static let hashtag : NSRegularExpression = try! NSRegularExpression(pattern: Pattern.hash, options: .caseInsensitive)
    
    static let mention : NSRegularExpression = try! NSRegularExpression(pattern: Pattern.mention, options: .caseInsensitive)
    
    static let url : NSRegularExpression = try! NSRegularExpression(pattern: Pattern.url, options: .caseInsensitive)
    
    static func parse(regex: NSRegularExpression, string: String) -> [NSTextCheckingResult] {
        return regex.matches(in: string, options: [], range: NSRange(location: 0, length: string.utf16.count))
    }
    
}
