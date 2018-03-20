//
//  Extensions.swift
//  My Magnetic Field
//
//  Created by Benjamin BARON on 3/17/18.
//  Copyright © 2018 Benjamin BARON. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    // From: https://gist.github.com/inder/40178b9c2ca798dd3427
    func addVisualConstraint(_ visualConstraints: String, views: [String:UIView]) {
        let constraints = NSLayoutConstraint.constraints(withVisualFormat: visualConstraints, options: NSLayoutFormatOptions(), metrics: nil, views: views)
        self.addConstraints(constraints)
    }
    
    func addVisualConstraint(_ visualConstraints: String, views: [String:UIView], options: NSLayoutFormatOptions) {
        let constraints = NSLayoutConstraint.constraints(withVisualFormat: visualConstraints, options: options, metrics: nil, views: views)
        self.addConstraints(constraints)
    }
}

extension UITableView {
    func keyboardRaised(height: CGFloat){
        self.contentInset.bottom = height
        self.scrollIndicatorInsets.bottom = height
    }
    
    func keyboardClosed() {
        self.contentInset.bottom = 0
        self.scrollIndicatorInsets.bottom = 0
        self.scrollRectToVisible(CGRect.zero, animated: true)
    }
}

extension Date {
    func dateToDayString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: self)
    }
    
    func dateToDayLetterString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "ccc d MMMM yyyy"
        return formatter.string(from: self)
    }
    
    func dateToTimePeriodString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: self)
    }
}
