//
//  CLBackspaceDetectingTextField.swift
//  CLTokenInputView
//
//  Created by Robert La Ferla on 1/13/16 from original ObjC version by Rizwan Sattar.
//  Copyright © 2016 Robert La Ferla. All rights reserved.
//

import Foundation
import UIKit

protocol CLBackspaceDetectingTextFieldDelegate: UITextFieldDelegate {
    func textFieldDidDeleteBackwards(textField:UITextField)
}

class CLBackspaceDetectingTextField: UITextField, CLBackspaceDetectingTextFieldDelegate {
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        if (range.length == 1 && string.isEmpty){
            //print("Used Backspace")
            self.textFieldDidDeleteBackwards(self)
        }
        return true
    }
    
    func textFieldDidDeleteBackwards(textField:UITextField) {
        
    }

    
}