//
//  CardView.swift
//  Maverick poker
//
//  Created by Gary Wozniak on 2/13/15.
//  Copyright (c) 2015 Maverick app. All rights reserved.
//

// A CardView is our main interface to a playing card.
// It can show a placeholder for a future card, a face-down card, or a face-up card.
// Setting `value` will usually make it show the card indicated by a two-character string.
// Reading `rank`, `suit`, or `color` will tell how it interpreted the `value` string.

import UIKit
import QuartzCore

private let rankMap:Dictionary<Character,String> = [
    "2": "2",
    "3": "3",
    "4": "4",
    "5": "5",
    "6": "6",
    "7": "7",
    "8": "8",
    "9": "9",
    "t": "10",
    "j": "J",
    "q": "Q",
    "k": "K",
    "a": "A"
]

private let suitMap:Dictionary<Character,String> = [
    "c": "♣︎",
    "d": "♦︎",
    "h": "♥︎",
    "s": "♠︎"
]

private let suitColorMap:Dictionary<Character,UIColor> = [
    "c": UIColor.blackColor(),//UIColor(red: 44/255, green: 62/255, blue: 80/255, alpha: 1),
    "d": UIColor.redColor(),//UIColor(red: 192/255, green: 57/255, blue: 43/255, alpha: 1),
    "h": UIColor.redColor(),//UIColor(red: 192/255, green: 57/255, blue: 43/255, alpha: 1),
    "s": UIColor.blackColor()//UIColor(red: 44/255, green: 62/255, blue: 80/255, alpha: 1),
]

private let borderColorMap:Dictionary<Character,UIColor> = [
    "c": UIColor(red: 72/255, green: 93/255, blue: 114/255, alpha: 1.0),
    "s": UIColor(red: 72/255, green: 93/255, blue: 114/255, alpha: 1.0),
    "d": UIColor(red: 231/255, green: 76/255, blue: 60/255, alpha: 1.0),
    "h": UIColor(red: 231/255, green: 76/255, blue: 60/255, alpha: 1.0),
]

class CardView: UIButton, FirebaseView {
   /*
    override init() {
        self.faceUp = false
        super.init()
        self.setupDisplay()
    }
  */
    required init?(coder aDecoder: NSCoder) {
        self.faceUp = true
        super.init(coder: aDecoder)
        self.setupDisplay()
    }
    
    var gradientLayer: CALayer?
    var suitSymbolTop : UILabel?
    var suitSymbolBottom : UILabel?
    
    @IBInspectable var topColor: UIColor = UIColor(red: 252/255, green: 252/255, blue: 252/255, alpha: 1.0)
    @IBInspectable var bottomColor: UIColor = UIColor(red: 225/255, green: 225/255, blue: 207/225, alpha: 1.0)
    func setupDisplay() {
        let cardGradient: CAGradientLayer = CAGradientLayer()
        cardGradient.frame = CGRect(origin: CGPoint(x: 0, y: 0), size: self.frame.size)
        cardGradient.colors = [topColor.CGColor, bottomColor.CGColor]
        cardGradient.cornerRadius = 4.0
        cardGradient.hidden = true
        self.layer.insertSublayer(cardGradient, atIndex: 0)
        self.gradientLayer = cardGradient

        self.suitSymbolTop = UILabel(frame: CGRectMake(0, 0, 20, 20))
        self.suitSymbolTop?.textAlignment = NSTextAlignment.Center
        self.suitSymbolTop?.font = UIFont(name: "HelveticaNeue-Bold", size: 20)
        self.suitSymbolTop?.hidden = true
        self.addSubview(suitSymbolTop!)
        
        self.suitSymbolBottom = UILabel(frame: CGRectMake(bounds.width-20, bounds.height-22, 20, 20))
        self.suitSymbolBottom?.textAlignment = NSTextAlignment.Center
        self.suitSymbolBottom?.font = UIFont(name: "HelveticaNeue-Light", size: 20)
        self.suitSymbolBottom?.hidden = true
        self.addSubview(suitSymbolBottom!)
        
        //Uncomment the following block to set card value attributedly
        /*
        var cardValue = UILabel(frame: CGRectMake(bounds.width/2-15, bounds.height/2-15, 30,30))
        cardValue.textAlignment = NSTextAlignment.Center
        cardValue.textColor = UIColor(red: 87/255, green: 86/255, blue: 88/255, alpha: 0.95)
        cardValue.font = UIFont(name: "HelveticaNeue-Medium", size: 29)
        cardValue.text = displayRank!
        self.addSubview(cardValue)
        */
        
        //Following block is used to change plain title programmatically
        /*
        self.titleLabel?.lineBreakMode = NSLineBreakMode.ByWordWrapping
        self.titleLabel?.textAlignment = NSTextAlignment.Center
        self.titleLabel?.textColor = UIColor.whiteColor()
        self.setTitle("", forState: .Normal)
        self.hidden = false
        self.enabled = false
        */
    }
    
    // MARK: - observers
    
    var observer: FirebaseObserver?
    var ref: FIRDatabaseReference? {
        didSet {
            observer = FirebaseObserver(ref:self.ref!, target:self, key:"card")
        }
    }
    var shownObserver: FirebaseObserver?
    var shownRef: FIRDatabaseReference? {
        didSet {
            // we use a callback to explicitly avoid setting faceUp to nil
            weak var this:CardView! = self
            shownObserver = FirebaseObserver(ref: self.shownRef!, callback: { (value) -> Void in
                if value != nil {
                    this.faceUp = value as! Bool
                }
            })
        }
    }
    
    // MARK: - properties

    var faceUp:Bool {
        didSet {
            if faceUp == true && shownRef != nil && ref != nil {
                // re-subscribe to value, since an earlier subscription may have been cancelled by permissions
                let oldRef = ref
                ref = oldRef
            }
            if faceUp == false {
                showBack()
            }
            else {
                showFront()
            }
        }
    }
    
    var card: String? {
        didSet {
            // if `card` is nil or invalid, show a placeholder for a card.
            // this might be because the data doesn't exist or we don't have permission to view it.
            if card == nil {
                showPlaceholder()
            }
            else {
                showFront()
            }
        }
    }
    
    var rank: Character? { return card?[0] }
    var suit: Character? { return card?[1] }
    var displayRank: String? { return rankMap[rank ?? "-"] }
    var displaySuit: String? { return suitMap[suit ?? "-"] }
    var displayColor: UIColor? { return suitColorMap[suit ?? "-"] }
    var borderColor: UIColor? { return borderColorMap[suit ?? "-"] }
    
    // MARK: - Display

    func showFront() {
        if displayRank == nil || displaySuit == nil || displayColor == nil {
            // the data is not formatted properly. don't change appearance.
            return
        }
        
        self.gradientLayer?.hidden = false

        suitSymbolTop?.text = displaySuit
        suitSymbolTop?.textColor = displayColor
        suitSymbolTop?.hidden = false

        suitSymbolBottom?.text = displaySuit
        suitSymbolBottom?.textColor = displayColor
        suitSymbolBottom?.hidden = false

        //let display = "\(displaySuit!)\n\(displayRank!)"
        let display = "\(displayRank!)"
        self.setTitle(display, forState: .Normal)
        
        self.layer.borderWidth = 1.0
        self.layer.borderColor = UIColor(red: 250/255, green: 250/255, blue: 250/255, alpha: 0.95).CGColor
        self.layer.cornerRadius = 4.0
        
        self.hidden = false
    }
    
    func showBack() {
        suitSymbolTop?.hidden = true
        suitSymbolBottom?.hidden = true
        self.gradientLayer?.hidden = true
        
        self.setTitle("", forState: .Normal)
        self.backgroundColor = UIColor.blueColor()
        self.layer.borderWidth = 1.0
        self.layer.borderColor = UIColor.whiteColor().CGColor

        self.hidden = false
    }
    
    @IBInspectable var placeHolderColor: UIColor = UIColor(red: 230/255, green: 230/255, blue: 230/255, alpha: 0.5)
    func showPlaceholder() {
        suitSymbolTop?.hidden = true
        suitSymbolBottom?.hidden = true
        self.gradientLayer?.hidden = true

        self.setTitle("", forState: .Normal)
        self.backgroundColor = placeHolderColor

        self.hidden = false
    }
    
    var dragStart: CGPoint = CGPoint(x: 0, y: 0)
}
