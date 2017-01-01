//
//  DynamicLabel.swift
//  Snaps
//
//  Created by Frank Hu on 12/11/16.
//  Copyright © 2016 Sugarcube. All rights reserved.
//

import Foundation
import UIKit

open class DynamicLabel : UILabel, UIGestureRecognizerDelegate {
    
    
    
    //
    // Open / Public Variables and Methods
    //
    
    
    
    //Override UILabel Properties
    
    override open var text : String? {
        didSet { updateTextStorage() }
    }
    
    override open var attributedText: NSAttributedString? {
        didSet { updateTextStorage() }
    }
    
    override open var textColor: UIColor! {
        didSet { updateTextStorage() }
    }
    
    override open var font: UIFont! {
        didSet { updateTextStorage() }
    }
    
    override open var textAlignment: NSTextAlignment {
        didSet { updateTextStorage() }
    }
    
    override open var numberOfLines: Int {
        didSet { textContainer.maximumNumberOfLines = numberOfLines }
    }
    //Override Properties End
    
    
    //Delegate
    public var delegate : DynamicLabelDelegate?
    
    //Defines which types are parsed
    public var enabledParses : [ParseElement] = [.hash, .mention, .url] {
        didSet {
            cleanAttributes()
            updateTextStorage()
        }
    }
    
    // Custom styles
    
    //Runs sizeToFit() when update text
    open var autoFitToSize : Bool = true
    
    open var lineSpacing : Float = 0 {
        didSet { updateTextStorage() }
    }
    
    open var inset : UIEdgeInsets = UIEdgeInsetsMake(10.0, 10.0, 10.0, 10.0) {
        didSet { setNeedsDisplay() }
    }
    
    //Parse type color associations
    open var hashColor = ParseColor.hash {
        didSet { updateFontColor(type: AttributeType.hash, color: hashColor) }
    }
    
    open var mentionColor = ParseColor.mention {
        didSet { updateFontColor(type: AttributeType.mention, color: mentionColor) }
    }
    
    open var urlColor = ParseColor.url {
        didSet { updateFontColor(type: AttributeType.url, color: urlColor) }
    }
    
    open var customColor = ParseColor.custom {
        didSet { updateFontColor(type: AttributeType.custom, color: customColor) }
    }
    
    
    // Public Methods
    
    
    //** Edit Block **//
    //Use to minimize # of parses while configuring label styles
    /*
        Usage:
     
        label.editStyles { label in
            label.enabledParses = [...]
            label.text = "..."
            
            ...etc
        }
     
    */
    @discardableResult
    open func editStyles(_ block: (_ label: DynamicLabel) -> ()) -> DynamicLabel {
        editable = false
        block(self)
        editable = true
        updateTextStorage()
        return self
    }
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open override func drawText(in rect: CGRect) {
        let range = NSRange(location: 0, length: textStorage.length)
        
        let newRect = UIEdgeInsetsInsetRect(rect, inset)
        textContainer.size = newRect.size
        originPoint = textOrigin(inRect: newRect)
        
        layoutManager.drawBackground(forGlyphRange: range, at: originPoint)
        layoutManager.drawGlyphs(forGlyphRange: range, at: originPoint)
    }
    
    open override func textRect(forBounds bounds: CGRect, limitedToNumberOfLines numberOfLines: Int) -> CGRect {
        
        let insetRect = UIEdgeInsetsInsetRect(bounds, inset)
        let textRect = super.textRect(forBounds: insetRect, limitedToNumberOfLines: numberOfLines)
        
        let invertedInset = UIEdgeInsetsMake(-inset.top, -inset.left, -inset.bottom, -inset.right)
        
        return UIEdgeInsetsInsetRect(textRect, invertedInset)
        
    }
    
    
    
    //
    // Internal Variables and Methods
    //
    
    
    
    //Keeps track of text origin
    internal var originPoint = CGPoint(x: 0, y: 0)
    
    
    //Internal Methods
    
    
    //Handler for UITap
    internal func handleTap(sender: UITapGestureRecognizer) {
        
        //If there is no delegate, end function
        guard let interface = delegate else {
            return
        }
        
        //Call delegate func to notify which label was tapped
        interface.didTapOnLabel?(label: self)
        
        //No matching keyword -> no proper response
        guard let matchedKeywords = matchedStrings else {
            return
        }
        
        var location = sender.location(in: self)
        
        //Considers offsets
        location.x -= originPoint.x
        location.y -= originPoint.y
        
        let characterIndex = layoutManager.characterIndex(for: location, in: textContainer, fractionOfDistanceBetweenInsertionPoints: nil)
        
        guard characterIndex < textStorage.length else {
            return
        }
        
        //Get the keyword
        var matched : String?
        for word in matchedKeywords {
            if word.value.indexIsWithin(forIndex: characterIndex) {
                matched = word.key
            }
        }
        
        for parse in enabledParses {
            
            let type = parse.getAttributeName()
            
            //Check if attribute exists at the tapped index before other checks
            //Also gets pattern (if custom type)
            guard let value = attributedText?.attribute(type, at: characterIndex, effectiveRange: nil), let pattern = value as? String else {
                continue
            }
            
            //Check if keyword exists
            guard let keyword = matched else {
                interface.getError?(error: "Keyword is missing!")
                continue
            }
            
            outerLoop: for patternType in patternTypes {
                if patternType == parse {
                    //Call any pattern handler delegation method
                    interface.didSelectPattern?(keyword: keyword, label: self, type: patternType)
                    break outerLoop
                }
            }
            
            //Calls specific delegate method
            switch parse {
            case .hash:
                interface.hashtagHandler?(keyword: keyword, label: self)
            case .mention:
                interface.mentionHandler?(keyword: keyword, label: self)
            case .url:
                if interface.urlCustomHandler != nil {
                    interface.urlCustomHandler!(keyword: keyword, label: self)
                } else {
                    interface.urlDefaultHandler(keyword: keyword, label: self)
                }
            case .custom(let str):
                if pattern == str {
                    interface.customHandler?(keyword: keyword, pattern: pattern, label: self)
                }
            }

        }
    }
    
    
    
    //
    // Private Variables and Methods
    //
    

    
    //Determines if text should parse and update
    //True -> parse and update
    fileprivate var editable : Bool = true
    
    //Used in finding origin of text
    fileprivate var heightCorrection: CGFloat = 0
    
    //Define pattern types
    fileprivate let patternTypes : [PatternType] = [.hash, .mention, .url, .custom]
    
    //Text layout manager, storage, and container
    fileprivate let layoutManager = NSLayoutManager()
    fileprivate var textContainer = NSTextContainer()
    fileprivate var textStorage = NSTextStorage()
    
    //Contains all the matched words with its range values
    fileprivate var matchedStrings : [String : MatchIndex]?
    
    //Holds the range of matched words
    //Used to fetch the matched words upon user tap
    fileprivate struct MatchIndex {
        var length : Int
        var location : Int
        
        func indexIsWithin(forIndex index: Int) -> Bool {
            if index <= location + length && index >= location {
                return true
            } else {
                return false
            }
        }
    }
    
    //Defines AttributeType and related font color
    fileprivate var AttributeColor : [String : UIColor] = [
        AttributeType.hash : ParseColor.hash,
        AttributeType.mention : ParseColor.mention,
        AttributeType.url : ParseColor.url,
        AttributeType.custom : ParseColor.custom
    ]
    
    
    // Private Methods
    
    
    //Initial setup
    fileprivate func setup() {
        //Add UIGestureTapRecognizer
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap))
        tap.delegate = self
        self.addGestureRecognizer(tap)
        isUserInteractionEnabled = true
        
        editable = false
        
        //Defaults
        self.lineBreakMode = .byWordWrapping
        self.numberOfLines = 0
        self.textColor = UIColor(red: 102.0/255, green: 117.0/255, blue: 127.0/255, alpha: 1)
        
        editable = true
        
        //Setup Layout Managers etc
        textStorage.addLayoutManager(layoutManager)
        layoutManager.addTextContainer(textContainer)
        textContainer.lineBreakMode = self.lineBreakMode
        textContainer.lineFragmentPadding = 0
    }
    
    //Updates text storage and runs regex matching
    fileprivate func updateTextStorage() {
        
        if !editable { return }
        
        guard let attributedText = attributedText, attributedText.length > 0 else {
            cleanAttributes()
            textStorage.setAttributedString(NSAttributedString())
            setNeedsDisplay()
            return
        }
        
        //Set style
        var mutableStr = setStyle(attributedString: attributedText)
        
        //Parse text
        mutableStr = match(string: mutableStr)
        textStorage.setAttributedString(mutableStr as NSAttributedString)
        
        editable = false
        self.attributedText = mutableStr as NSAttributedString
        if autoFitToSize {
            sizeToFit()
        }
        editable = true
        
        setNeedsDisplay()
    }
    
    //Setup styles (line breaks, alignment, lineSpacing)
    fileprivate func setStyle(attributedString: NSAttributedString) -> NSMutableAttributedString {
        
        let mutable = NSMutableAttributedString(attributedString: attributedString)
        
        var range = NSRange(location: 0, length: 0)
        var attribute = mutable.attributes(at: 0, effectiveRange: &range)
        
        let paragraphStyle = attribute[NSParagraphStyleAttributeName] as? NSMutableParagraphStyle ?? NSMutableParagraphStyle()
        
        paragraphStyle.lineBreakMode = self.lineBreakMode
        paragraphStyle.alignment = self.textAlignment
        paragraphStyle.lineSpacing = CGFloat(lineSpacing)
        
        attribute[NSParagraphStyleAttributeName] = paragraphStyle
        mutable.setAttributes(attribute, range: range)
        
        return mutable
    }
    
    //Search for regex match in text
    fileprivate func match(string: NSMutableAttributedString) -> NSMutableAttributedString {
        
        let nonMutableStr = (string as NSAttributedString).string
        
        for parse in enabledParses {
            
            guard let regex = parse.regex() else {
                continue
            }
            
            let matches = RegexParser.parse(regex: regex, string: nonMutableStr)
            
            for match in matches {
                
                let range = match.range
                //let associated = elementAssociation[parse.getAttributeName()]!
                
                //Get matched strings and trim off white spaces and new lines
                let matchedStr = string.attributedSubstring(from: range).string.trimmingCharacters(in: .whitespacesAndNewlines)
                
                //Populate matchedStrings dictionary
                if matchedStrings == nil {
                    matchedStrings = [matchedStr: MatchIndex(length: range.length, location: range.location)]
                } else {
                    matchedStrings![matchedStr] = MatchIndex(length: range.length, location: range.location)
                }
                
                var attributedValue = parse.getAttributeName()
                
                switch parse {
                case .custom(let value):
                    attributedValue = value!
                default:
                    break
                }
                
                string.addAttribute(parse.getAttributeName(), value: attributedValue, range: range)
                
                string.addAttribute(NSForegroundColorAttributeName, value: AttributeColor[parse.getAttributeName()]!, range: range)
            }
            
        }
        
        return string
    }
    
    //Removes all attributes
    fileprivate func cleanAttributes() {
        if let attributedText = self.attributedText, attributedText.length > 0 {
            textStorage.setAttributedString(self.attributedText!)
        }
        
        let resetAttributes = [NSForegroundColorAttributeName : textColor,
                               NSFontAttributeName : font]
        
        textStorage.setAttributes(resetAttributes, range: NSRange(location: 0, length: textStorage.length))
        
        //To prevent editable getting overwritten if execution was done in editStyle block
        let inEdit = editable
        editable = false
        
        self.attributedText = textStorage.attributedSubstring(from: NSRange(location: 0, length: textStorage.length))
        
        editable = inEdit
    }
    
    //Change pattern colors
    fileprivate func updateFontColor(type: String, color: UIColor) {
        
        //Update colors dictionary in case of a new parse
        AttributeColor[type]! = color
        
        textStorage.enumerateAttributes(
            in: NSRange(location: 0, length: textStorage.length),
            options: .longestEffectiveRangeNotRequired) {
                (attributes, range, stop) in
                if attributes[type] != nil {
                    self.textStorage.removeAttribute(NSForegroundColorAttributeName, range: range)
                    self.textStorage.addAttribute(NSForegroundColorAttributeName, value: color, range: range)
                }
        }
        
        setNeedsDisplay()
        
    }
    
    //Calculate text origin
    fileprivate func textOrigin(inRect rect: CGRect) -> CGPoint {
        
        let usedRect = layoutManager.usedRect(for: textContainer)
        heightCorrection = (rect.height -  usedRect.height) / 2
        
        let glyphOriginY = heightCorrection > 0 ? rect.origin.y + heightCorrection : rect.origin.y
        
        return CGPoint(x: rect.origin.x, y: glyphOriginY)
    }
    
    
}
