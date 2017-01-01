//
//  ParseElement.swift
//  DynamicLabel
//
//  Created by Frank Hu on 12/21/16.
//  Copyright © 2016 Sugarcube. All rights reserved.
//

import Foundation

//Defines regular expression pattern types
@objc public enum PatternType : Int, Equatable {
    
    case hash = 0
    case mention = 1
    case url = 2
    case custom = 3
    
    static func ==(lhs: PatternType, rhs: ParseElement) -> Bool {
        switch (lhs, rhs) {
        case (PatternType.hash, ParseElement.hash),
             (PatternType.mention, ParseElement.mention),
             (PatternType.url, ParseElement.url),
             (PatternType.custom, ParseElement.custom(_)):
            return true
        default:
            return false
        }
    }
    
}

//Defines parse elements
public enum ParseElement : Equatable {

    case hash
    case mention
    case url
    case custom(String?)
    
    public static func ==(lhs: ParseElement, rhs: ParseElement) -> Bool {
        switch (lhs, rhs) {
        case (.hash, .hash),
             (.mention, .mention),
             (.url, .url),
             (.custom(_), .custom(_)):
            return true
        default:
            return false
        }
    }
    
    internal func regex() -> NSRegularExpression? {
        switch self {
        case .hash:
            return RegexParser.hashtag
        case .mention:
            return RegexParser.mention
        case .url:
            return RegexParser.url
        case .custom(let str):
            guard let pattern = str else {
                return nil
            }
            do {
                return try NSRegularExpression(pattern: pattern, options: .caseInsensitive)
            } catch {
                return nil
            }
        }
    }
    
    internal func getAttributeName() -> String {
        switch self {
        case .hash:
            return AttributeType.hash
        case .mention:
            return AttributeType.mention
        case .url:
            return AttributeType.url
        case .custom(_):
            return AttributeType.custom
        }
    }
}
