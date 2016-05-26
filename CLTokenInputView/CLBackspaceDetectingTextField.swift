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

class CLBackspaceDetectingTextField: UITextField {
    
    var myDelegate: CLBackspaceDetectingTextFieldDelegate? {
        get { return self.delegate as? CLBackspaceDetectingTextFieldDelegate }
        set { self.delegate = newValue }
    }
    
    override func deleteBackward() {
        
        if (self.text?.isEmpty ?? false){
            self.textFieldDidDeleteBackwards(self)
        }
        super.deleteBackward()
    }
    
    func textFieldDidDeleteBackwards(textField:UITextField) {
        
        myDelegate?.textFieldDidDeleteBackwards(textField)
        
    }
    
}