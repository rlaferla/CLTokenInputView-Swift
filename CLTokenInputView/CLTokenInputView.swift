//
//  CLTokenInputView.swift
//  CLTokenInputView
//
//  Created by Robert La Ferla on 1/13/16 from original ObjC version by Rizwan Sattar.
//  Copyright © 2016 Robert La Ferla. All rights reserved.
//

import Foundation
import UIKit

protocol CLTokenInputViewDelegate: class {
    func tokenInputViewDidEndEditing(aView: CLTokenInputView)
    func tokenInputViewDidBeginEditing(aView: CLTokenInputView)
    func tokenInputView(aView:CLTokenInputView, didChangeText text:String)
    func tokenInputView(aView:CLTokenInputView, didAddToken token:CLToken)
    func tokenInputView(aView:CLTokenInputView, didRemoveToken token:CLToken)
    func tokenInputView(aView:CLTokenInputView, tokenForText text:String) -> CLToken?
    func tokenInputView(aView:CLTokenInputView, didChangeHeightTo height:CGFloat)
}

class CLTokenInputView: UIView, CLBackspaceDetectingTextFieldDelegate, CLTokenViewDelegate {
    weak var delegate:CLTokenInputViewDelegate?
    var fieldLabel:UILabel!
    var fieldView:UIView? {
        willSet {
            if self.fieldView != newValue {
                self.fieldView?.removeFromSuperview()
            }
        }
        
        didSet {
            if oldValue != self.fieldView {
                if (self.fieldView != nil) {
                    self.addSubview(self.fieldView!)
                }
                self.repositionViews()
            }
        }
    }
    var fieldName:String? {
        didSet {
            if oldValue != self.fieldName {
                self.fieldLabel.text = self.fieldName
                self.fieldLabel.sizeToFit()
                let showField:Bool = self.fieldName!.characters.count > 0
                self.fieldLabel.hidden = !showField
                if showField && self.fieldLabel.superview == nil {
                    self.addSubview(self.fieldLabel)
                }
                else if !showField && self.fieldLabel.superview != nil {
                    self.fieldLabel.removeFromSuperview()
                }
                
                if oldValue == nil || oldValue != self.fieldName {
                    self.repositionViews()
                }
            }
            
        }
    }
    var fieldColor:UIColor? {
        didSet {
            self.fieldLabel.textColor = self.fieldColor
        }
    }
    var placeholderText:String? {
        didSet {
            if oldValue != self.placeholderText {
                self.updatePlaceholderTextVisibility()
            }
        }
    }
    var accessoryView:UIView? {
        willSet {
            if self.accessoryView != newValue {
                self.accessoryView?.removeFromSuperview()
            }
        }
        
        didSet {
            if oldValue != self.accessoryView {
                if (self.accessoryView != nil) {
                    self.addSubview(self.accessoryView!)
                }
                self.repositionViews()
            }
        }
    }
    var keyboardType: UIKeyboardType! {
        didSet {
            self.textField.keyboardType = self.keyboardType;
        }
    }
    var autocapitalizationType: UITextAutocapitalizationType! {
        didSet {
            self.textField.autocapitalizationType = self.autocapitalizationType;
        }
    }
    var autocorrectionType: UITextAutocorrectionType! {
        didSet {
            self.textField.autocorrectionType = self.autocorrectionType;
        }
    }
    var tokenizationCharacters:Set<String> = Set<String>()
    var drawBottomBorder:Bool! {
        didSet {
            if oldValue != self.drawBottomBorder {
                self.setNeedsDisplay()
            }
        }
    }
    //var editing:Bool = false
    
    var tokens:[CLToken] = []
    var tokenViews:[CLTokenView] = []
    var textField:CLBackspaceDetectingTextField!
    var intrinsicContentHeight:CGFloat!
    var additionalTextFieldYOffset:CGFloat!
    
    let HSPACE:CGFloat = 0.0
    let TEXT_FIELD_HSPACE:CGFloat = 4.0 // Note: Same as CLTokenView.PADDING_X
    let VSPACE:CGFloat = 4.0
    let MINIMUM_TEXTFIELD_WIDTH:CGFloat = 56.0
    let PADDING_TOP:CGFloat = 10.0
    let PADDING_BOTTOM:CGFloat = 10.0
    let PADDING_LEFT:CGFloat = 8.0
    let PADDING_RIGHT:CGFloat = 16.0
    let STANDARD_ROW_HEIGHT:CGFloat = 25.0
    let FIELD_MARGIN_X:CGFloat = 4.0
    
    func commonInit() {
        self.textField = CLBackspaceDetectingTextField(frame: self.bounds)
        self.textField.translatesAutoresizingMaskIntoConstraints = false
        self.textField.backgroundColor = UIColor.clearColor()
        self.textField.keyboardType = .EmailAddress
        self.textField.autocorrectionType = .No
        self.textField.autocapitalizationType = .None
        self.textField.delegate = self
        //self.additionalTextFieldYOffset = 0.0
        self.additionalTextFieldYOffset = 1.5
        self.textField.addTarget(self, action: #selector(CLTokenInputView.onTextFieldDidChange(_:)), forControlEvents: .EditingChanged)
        self.addSubview(self.textField)
        
        self.fieldLabel = UILabel(frame: CGRectZero)
        self.fieldLabel.translatesAutoresizingMaskIntoConstraints = false
        self.fieldLabel.font = self.textField.font
        self.fieldLabel.textColor = self.fieldColor
        self.addSubview(self.fieldLabel)
        self.fieldLabel.hidden = true
        
        self.fieldColor = UIColor.lightGrayColor()

        self.intrinsicContentHeight = STANDARD_ROW_HEIGHT
        self.repositionViews()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.commonInit()
    }
    
    override func intrinsicContentSize() -> CGSize {
        return CGSizeMake(UIViewNoIntrinsicMetric, max(45, self.intrinsicContentHeight))
    }
    
    override func tintColorDidChange() {
        self.tokenViews.forEach { $0.tintColor = self.tintColor }
    }
    
    func addToken(token:CLToken) {
        if self.tokens.contains(token) {
            return
        }
        
        self.tokens.append(token)
        
        let tokenView:CLTokenView = CLTokenView(token: token, font: self.textField.font)
        tokenView.translatesAutoresizingMaskIntoConstraints = false
        tokenView.tintColor = self.tintColor
        tokenView.delegate = self
        
        let intrinsicSize:CGSize = tokenView.intrinsicContentSize()
        tokenView.frame = CGRect(x: 0.0, y: 0.0, width: intrinsicSize.width, height: intrinsicSize.height)
        self.tokenViews.append(tokenView)
        self.addSubview(tokenView)
        self.textField.text = ""
        self.delegate?.tokenInputView(self, didAddToken: token)
        self.onTextFieldDidChange(self.textField)
        
        self.updatePlaceholderTextVisibility()
        self.repositionViews()
        
    }
    
    func removeTokenAtIndex(index:Int) {
        if index == -1 {
            return
        }
        let tokenView = self.tokenViews[index]
        tokenView.removeFromSuperview()
        self.tokenViews.removeAtIndex(index)
        let removedToken = self.tokens[index]
        self.tokens.removeAtIndex(index)
        self.delegate?.tokenInputView(self, didRemoveToken: removedToken)
        self.updatePlaceholderTextVisibility()
        self.repositionViews()
    }
    
    func removeToken(token:CLToken) {
        let index:Int? = self.tokens.indexOf(token)
        if index != nil {
            self.removeTokenAtIndex(index!)
        }
    }
    
    func allTokens() -> [CLToken] {
        return Array(self.tokens)
    }
    
    func tokenizeTextfieldText() -> CLToken? {
        //print("tokenizeTextfieldText()")
        var token:CLToken? = nil
        
        let text:String = self.textField.text!
        if text.characters.count > 0  {
            token = self.delegate?.tokenInputView(self, tokenForText: text)
            if (token != nil) {
                self.addToken(token!)
                self.textField.text = ""
                self.onTextFieldDidChange(self.textField)
            }
        }
        
        return token
    }
    
    func repositionViews() {
        let bounds:CGRect = self.bounds
        let rightBoundary:CGFloat = CGRectGetWidth(bounds) - PADDING_RIGHT
        var firstLineRightBoundary:CGFloat = rightBoundary
        var curX:CGFloat = PADDING_LEFT
        var curY:CGFloat = PADDING_TOP
        var totalHeight:CGFloat = STANDARD_ROW_HEIGHT
        var isOnFirstLine:Bool = true
        
        
       // print("repositionViews curX=\(curX) curY=\(curY)")
        
        //print("self.frame=\(self.frame)")

        // Position field view (if set)
        if self.fieldView != nil {
            var fieldViewRect:CGRect = self.fieldView!.frame
            fieldViewRect.origin.x = curX + FIELD_MARGIN_X
            fieldViewRect.origin.y = curY + ((STANDARD_ROW_HEIGHT - CGRectGetHeight(fieldViewRect) / 2.0)) - PADDING_TOP
            self.fieldView?.frame = fieldViewRect
            
            curX = CGRectGetMaxX(fieldViewRect) + FIELD_MARGIN_X
           // print("fieldViewRect=\(fieldViewRect)")
        }
        
        // Position field label (if field name is set)
        if !(self.fieldLabel.hidden) {
            var fieldLabelRect:CGRect = self.fieldLabel.frame
            fieldLabelRect.origin.x = curX + FIELD_MARGIN_X
            fieldLabelRect.origin.y = curY + ((STANDARD_ROW_HEIGHT - CGRectGetHeight(fieldLabelRect) / 2.0)) - PADDING_TOP

            self.fieldLabel.frame = fieldLabelRect
            
            curX = CGRectGetMaxX(fieldLabelRect) + FIELD_MARGIN_X
            //print("fieldLabelRect=\(fieldLabelRect)")
        }

        // Position accessory view (if set)
        if self.accessoryView != nil {
            var accessoryRect:CGRect = self.accessoryView!.frame;
            accessoryRect.origin.x = CGRectGetWidth(bounds) - PADDING_RIGHT - CGRectGetWidth(accessoryRect)
            accessoryRect.origin.y = curY;
            self.accessoryView!.frame = accessoryRect;
            
            firstLineRightBoundary = CGRectGetMinX(accessoryRect) - HSPACE;
        }

        // Position token views
        var tokenRect:CGRect = CGRectNull
        for tokenView:CLTokenView in self.tokenViews {
            tokenRect = tokenView.frame
            
            let tokenBoundary:CGFloat = isOnFirstLine ? firstLineRightBoundary : rightBoundary
            if curX + CGRectGetWidth(tokenRect) > tokenBoundary {
                // Need a new line
                curX = PADDING_LEFT
                curY += STANDARD_ROW_HEIGHT + VSPACE
                totalHeight += STANDARD_ROW_HEIGHT
                isOnFirstLine = false
            }
            
            tokenRect.origin.x = curX
            // Center our tokenView vertically within STANDARD_ROW_HEIGHT
            tokenRect.origin.y = curY + ((STANDARD_ROW_HEIGHT - CGRectGetHeight(tokenRect)) / 2.0)
            tokenView.frame = tokenRect
            
            curX = CGRectGetMaxX(tokenRect) + HSPACE
        }
        
        // Always indent textfield by a little bit
        curX += TEXT_FIELD_HSPACE
        let textBoundary:CGFloat = isOnFirstLine ? firstLineRightBoundary : rightBoundary
        var availableWidthForTextField:CGFloat = textBoundary - curX;
        if availableWidthForTextField < MINIMUM_TEXTFIELD_WIDTH {
            isOnFirstLine = false
            curX = PADDING_LEFT + TEXT_FIELD_HSPACE
            curY += STANDARD_ROW_HEIGHT + VSPACE
            totalHeight += STANDARD_ROW_HEIGHT
            // Adjust the width
            availableWidthForTextField = rightBoundary - curX;
        }
        
        var textFieldRect:CGRect = self.textField.frame;
        textFieldRect.origin.x = curX
        textFieldRect.origin.y = curY + self.additionalTextFieldYOffset
        textFieldRect.size.width = availableWidthForTextField
        textFieldRect.size.height = STANDARD_ROW_HEIGHT
        self.textField.frame = textFieldRect
        
        let oldContentHeight:CGFloat = self.intrinsicContentHeight;
        self.intrinsicContentHeight = CGRectGetMaxY(textFieldRect)+PADDING_BOTTOM;
        self.invalidateIntrinsicContentSize()
        
        if oldContentHeight != self.intrinsicContentHeight {
            self.delegate?.tokenInputView(self, didChangeHeightTo: self.intrinsicContentSize().height)
        }
        self.setNeedsDisplay()
    }
    
    func updatePlaceholderTextVisibility() {
        if self.tokens.count > 0 {
            self.textField.placeholder = nil
        }
        else {
            self.textField.placeholder = self.placeholderText
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.repositionViews()
    }
    
    
    // MARK: CLBackspaceDetectingTextFieldDelegate
    
    func textFieldDidDeleteBackwards(textField: UITextField) {
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            if textField.text?.characters.count == 0 {
                let tokenView:CLTokenView? = self.tokenViews.last
                if tokenView != nil {
                    self.selectTokenView(tokenView!, animated: true)
                    self.textField.resignFirstResponder()
                }
            }
        }
    }
    
    //MARK: UITextFieldDelegate
    
    func textFieldDidBeginEditing(textField: UITextField) {
        //print("textFieldDidBeginEditing:")
        self.delegate?.tokenInputViewDidBeginEditing(self)
        
        self.tokenViews.last?.hideUnselectedComma = false
        self.unselectAllTokenViewsAnimated(true)
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        //print("textFieldDidEndEditing:")

        self.delegate?.tokenInputViewDidEndEditing(self)
        self.tokenViews.last?.hideUnselectedComma = true
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        //print("textFieldShouldReturn:")

        self.tokenizeTextfieldText()
        return false
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        //print("textField:shouldChangeCharactersInRange:replacementString:\(string)")

        if string.characters.count > 0 && self.tokenizationCharacters.contains(string) {
            self.tokenizeTextfieldText()
            return false
        }
        return true
    }
    
    func onTextFieldDidChange(sender:UITextField) {
       // print("onTextFieldDidChange")
        self.delegate?.tokenInputView(self, didChangeText: self.textField.text!)
    }
    
    
    func textFieldDisplayOffset() -> CGFloat {
        return CGRectGetMinY(self.textField.frame) - PADDING_TOP;
    }
    
    func text() -> String? {
        return self.textField.text
    }
    
    func tokenViewDidRequestDelete(tokenView:CLTokenView, replaceWithText replacementText:String?) {
        self.textField.becomeFirstResponder()
        if replacementText?.characters.count > 0 {
            self.textField.text = replacementText
        }
        let index:Int? = self.tokenViews.indexOf(tokenView)
        if index == nil {
            return
        }
        self.removeTokenAtIndex(index!)
    }
    
    func tokenViewDidRequestSelection(tokenView:CLTokenView) {
        self.selectTokenView(tokenView, animated:true)
    }
    
    func selectTokenView(tokenView:CLTokenView, animated aBool:Bool) {
        tokenView.setSelected(true, animated: aBool)
        for otherTokenView:CLTokenView in self.tokenViews {
            if otherTokenView != tokenView {
                otherTokenView.setSelected(false, animated: aBool)
            }
        }
    }
    
    func unselectAllTokenViewsAnimated(animated:Bool) {
        for tokenView:CLTokenView in self.tokenViews {
            tokenView.setSelected(false, animated: animated)
        }
    }
    
    
    //
    
    func isEditing() -> Bool {
        return self.textField.editing
    }
    
    func beginEditing() {
        self.textField.becomeFirstResponder()
        self.unselectAllTokenViewsAnimated(false)
    }
    
    func endEditing() {
        self.textField.resignFirstResponder()
    }
    
    //
    override func drawRect(rect: CGRect) {
        super.drawRect(rect)
        
        if self.drawBottomBorder == true {
            let context:CGContextRef? = UIGraphicsGetCurrentContext()
            CGContextSetStrokeColorWithColor(context, UIColor.lightGrayColor().CGColor)
            CGContextSetLineWidth(context, 0.5)
            
            CGContextMoveToPoint(context, CGRectGetWidth(self.bounds), self.bounds.size.height)
            CGContextAddLineToPoint(context, CGRectGetWidth(bounds), bounds.size.height);
            CGContextStrokePath(context)
        }
    }
    
}