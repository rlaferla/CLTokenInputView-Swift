//
//  CLToken.swift
//  CLTokenInputView
//
//  Created by Robert La Ferla on 1/13/16 from original ObjC version by Rizwan Sattar.
//  Copyright © 2016 Robert La Ferla. All rights reserved.
//

import Foundation

class CLToken {
    var displayText: String!
    var context:AnyObject?
}

extension CLToken: Equatable {}

func ==(lhs: CLToken, rhs: CLToken) -> Bool {
    if lhs.displayText == rhs.displayText && lhs.context?.isEqual(rhs.context) == true {
        return true
    }
    return false
}