# DynamicLabel
DynamicLabel is an iOS UILabel that allows user interaction with various custom pattern-matching including #hashtag, @mention, and URL links. This is made using other similar modules as references, most notably [ActiveLabel](https://github.com/optonaut/ActiveLabel.swift) by Optonaut.

## Important Properties and Method
#### delegate : DynamicLabelDelegate
Contains methods that is used to notify the controller when tap event happens.
See Delegation Methods for more detail

#### enabledParses : [ParseElement]
Array that defines what type of parses DynamicLabel will operate on.
Possible values: ParseElement.hash, ParseElement.mention, ParseElement.url, ParseElement.custom(:String)
Default: [.hash, .mention, .url]

#### Font colors: hashColor, mentionColor, urlColor, customColor
These variable defines the font color that will be applied to the corresponding match types.
Default values are defined in DataConstant.swift

#### editStyle(block)
A method that is used to edit the style of the label without invoking regular expression parsing. This is used to minimize redundant parses while customizing the label style.

### Delegation Methods

#### hashHandler(keyword: String, label: DynamicLabel)
Fired when user taps on a matching pattern that is identified to be a hashtag pattern.

#### mentionHandler(keyword: String, label: DynamicLabel)
Fired when user taps on a matching pattern that is identified to be a mention pattern.

#### urlDefaultHandler(keyword: String, label: DynamicLabel)
Default implementation of url handler which opens up the URL in Safari.
Can be accessed via self.urlDefaultHandler(keyword,label)

#### urlCustomHandler(keyword: String, label: DynamicLabel)
Custom implementation of url handler. If this method is defined, the default url handler will be overwritten.

#### customHandler(keyword: String, pattern: String, label: DynamicLabel)
Fired when user taps on a matching custom pattern.
The pattern argument can be used to identify which custom pattern is matched.

#### didTapOnLabel(label: DynamicLabel)
Fired upon user tapping on a DynamicLabel. This event will fire regardless if user did or did not tap on a matching pattern.

#### didSelectPattern(keyword: String, label: DynamicLabel, type: PatternType)
Fired upon user tapping on ANY matching pattern.
Type argument corresponds to either of four types: .hash, .mention, .url, or .custom


## Example Usage
```swift
import DynamicLabel
//Implement DynamicLabelDelegate on view controller

//Custom regular expression patterns
let customPattern1 = "\\sPattern1\\s"
let customPattern2 = "\\sPattern2\\s"
let customPattern3 = "\\sPattern3\\s"

let label = DynamicLabel()

/*
	Editing label style block
	This is to minimize redundant regular expression parses while editing  label styles
	Can do without
*/
label.editStyles { label in
	
	//Extend DynamicLabelDelegate for callback funcs
	label.delegate = self

	//Defines normal text color
	label.textColor = UIColor.cyan

	label.text = "This is Pattern1 with Pattern2 and one more Pattern3 all the while having one URL: https://google.com; two @hashtags, @hohoho; three @mentions, @super, @bananaCafe; and normal text"

	//Set frame.size.width to specify max width
	label.frame.size.width = 200

	//Defines types of parses active
	label.enabledParses = [ .hash,
							.mention,
							.url,
							.custom(customPattern1),
							.custom(customPattern2),
							.custom(customPattern3) ]

	/*
		Defines font color that is associated with each type of parsing
		Others include: mentionColor, urlColor, customColor
		Default values in DataConstants file (along with regex patterns)
	*/
	label.hashColor = UIColor.lightGray

	//Spacings, margins, text wrap modes, and other thingys
	label.lineSpacing = 5 //default: 0
	label.inset = UIEdgeInsetsMake(0,0,0,0) //default: all 10
	label.lineBreakMode = .byWordWrapping //default
	label.numberOfLines = 0 //default
	label.textAlignment = .center //default: w/e UILabel default is
	/*
		Turn off auto execute sizeToFit() upon text update or re-parse
		If autoFitToSize is off: need to call sizeToFit() manually if no bounds or frame is supplied
		Call sizeToFit() outside of editStyles block to let it properly fit to correct size after all styles are in place
	*/
	label.autoFitToSize = false //default: true
	//other styles here
}

//Call sizeToFit here if needed
label.sizeToFit()

view.addSubview(label)


//---------------------//

/*
	Delegation Methods
	These are optional implementations
	No implementation means only URL matching (if delegate is set)
*/


func didTapOnLabel(label: DynamicLabel) {
	/*
		Returns label that call this func
		Calls upon label tapped.
		Does NOT have to tap on a matching pattern.
	*/
}

func didSelectPattern(keyword: String, label: DynamicLabel, type: PatternType) {
	/*
		Returns matching keyword, label, and type of parsing that triggered it (four only: .hash, .metion, .url, .custom)
		Calls only upon having a matching keyword tapped. 
		A universal callback method for all parse types
	*/
}

func hashtagHandler(keyword: String, label: DynamicLabel) {
	/*
		Calls when hashtag matching is tapped.
		Same for mention but with 
		func mentionHandler(keyword,label) 
	*/
}

func urlCustomHandler(keyword: String, label: DynamicLabel) {
	/*
		Defining this delegate method will override default url handler method
		Can access default method by calling
		self.urlDefaultHandler(keyword, label)
		The default handler just opens up URL in Safari
	*/
}

func customHandler(keyword: String, pattern: String, label: DynamicLabel) {
	/*
		Calls only when a custom defined pattern is tapped
		Can differentiate between custom patterns via "pattern" variable
	*/
	switch pattern {
	case customPattern1:
		print("do custom 1")
	case customPattern2:
		print("do custom 2")
	case customPattern3:
		print("do custom 3")
	default:
		return
	}
}
```
