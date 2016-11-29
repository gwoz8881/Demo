//
//  Global
//  Maverick poker
//
//  Created by Gary Wozniak on 20/02/2015.
//  Copyright (c) 2015 Maverick app. All rights reserved.
//

import Foundation
import Firebase

let delayQueue = dispatch_queue_create("DelayQueue", DISPATCH_QUEUE_SERIAL)
func delay(delay:Double, closure:()->()) {
    dispatch_after(
        dispatch_time(
            DISPATCH_TIME_NOW,
            Int64(delay * Double(NSEC_PER_SEC))
        ),
        delayQueue, closure)
}

let kFirebaseServerValueTimestamp = [".sv": "timestamp"]

let rootRef = FIRDatabase.database().reference()

extension String {
    subscript (i: Int) -> Character? {
        if i >= self.characters.count {
            return nil
        }
        return self[(self.startIndex.advancedBy(i))]
    }
    
    subscript (i: Int) -> String? {
        let c = self[i] as Character?
        if c == nil {
            return nil
        }
        return String(c!)
    }
    
    subscript (r: Range<Int>) -> String {
        let start = self.startIndex.advancedBy(r.startIndex)
        let end = self.startIndex.advancedBy(r.endIndex)
        return substringWithRange(Range(start: start, end: end))
    }
    
    func entireRange() -> Range<String.Index> {
        return Range(start:startIndex, end: endIndex)
    }
}

extension UIViewController {
    @IBAction func goBack(sender: AnyObject) {
        if self.navigationController != nil {
            self.navigationController?.popViewControllerAnimated(true)
        }
        else {
            self.dismissViewControllerAnimated(true, completion: nil)
        }
    }
}

extension UITableView {
    func scrollToBottom(animated: Bool=true) {
        let lastSection = (self.dataSource?.numberOfSectionsInTableView!(self) ?? 0) - 1
        let lastRow = (self.dataSource?.tableView(self, numberOfRowsInSection: lastSection) ?? 0) - 1
        if (lastSection < 0 || lastRow < 0) {
            return
        }
        let bottomIndex = NSIndexPath(forRow: lastRow, inSection: lastSection)
        self.scrollToRowAtIndexPath(bottomIndex, atScrollPosition: .Top, animated: animated)
    }
}

extension UIColor {
    func darkerColor(amount:CGFloat) -> UIColor{
        var h: CGFloat = 0, s: CGFloat = 0, b:CGFloat = 0, a: CGFloat = 0
        self.getHue(&h, saturation: &s, brightness: &b, alpha: &a)
        return UIColor(hue: h, saturation: s, brightness: b*(1.0-amount), alpha: a)
    }
    
}


