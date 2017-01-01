//
//  DataConstants.swift
//  Snaps
//
//  Created by Frank Hu on 12/21/16.
//  Copyright © 2016 Sugarcube. All rights reserved.
//

import Foundation
import UIKit


//Defines regular expression patterns
internal struct Pattern {
    static let hash = "(?:^|\\s|$)#[\\p{L}0-9_]*"
    static let mention = "(?:^|\\s|$|[.])@[\\p{L}0-9_]*"
    static let url = "(^|\\s)?" + "((https?://|www\\.|pic\\.)[-\\w;/?:@&=+$\\|\\_.!~*\\|'()\\[\\]%#,☺]+[\\w/#](\\(\\))?)" + "(?=$|[\\s',\\|\\(\\).:;?\\-\\[\\]>\\)])"
}

//Defines the names of custom attributes
internal struct AttributeType {
    static let hash = "HashtagAttribute"
    static let mention = "MentionAttribute"
    static let url = "URLAttribute"
    static let custom = "CustomAttribute"
    static let list = [hash, mention, url, custom]
}

//Defines colors for corresponding parse types
internal struct ParseColor {
    static let hash = UIColor(red: 85.0/255, green: 172.0/255, blue: 238.0/255, alpha: 1)
    static let mention = UIColor(red: 238.0/255, green: 85.0/255, blue: 96.0/255, alpha: 1)
    static let url = UIColor(red: 85.0/255, green: 238.0/255, blue: 151.0/255, alpha: 1)
    static let custom = UIColor.black
}


