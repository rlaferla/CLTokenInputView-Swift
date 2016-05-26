//
//  CLTokenView.swift
//  CLTokenInputView
//
//  Created by Robert La Ferla on 1/13/16 from original ObjC version by Rizwan Sattar.
//  Copyright © 2016 Robert La Ferla. All rights reserved.
//

import Foundation
import UIKit

protocol CLTokenViewDelegate {
    func tokenViewDidRequestDelete(tokenView:CLTokenView, replaceWithText replacementText:String?)
    func tokenViewDidRequestSelection(tokenView:CLTokenView)
}

class CLTokenView: UIView, UIKeyInput {
    var delegate: CLTokenViewDelegate?
    var selected: Bool! {
        didSet {
            if oldValue != self.selected {
                self.setSelectedNoCheck(self.selected, animated: false)
            }
        }
    }
    var hideUnselectedComma: Bool! {
        didSet {
            if oldValue != self.hideUnselectedComma {
                self.updateLabelAttributedText()
            }
        }
    }
    
    var backgroundView:UIView?
    var label:UILabel!
    var selectedBackgroundView:UIView!
    var selectedLabel:UILabel!
    var displayText:String!
    
    let PADDING_X = 4.0
    let PADDING_Y = 2.0
//    let UNSELECTED_LABEL_FORMAT = "%@, "
//    let UNSELECTED_LABEL_NO_COMMA_FORMAT = "%@"
    
    init(frame:CGRect, token: CLToken, font:UIFont?) {
        super.init(frame: frame)
        var tintColor:UIColor = UIColor(red: 0.08, green: 0.49, blue: 0.98, alpha: 1.0)
        tintColor = self.tintColor
        self.label = UILabel(frame: CGRect(x: PADDING_X, y: PADDING_Y, width: 0.0, height: 0.0))
        if font != nil {
            self.label.font = font
        }
        self.label.textColor = tintColor
        self.label.backgroundColor = UIColor.clearColor()
        self.addSubview(label)
        
        self.selectedBackgroundView = UIView(frame: CGRectZero)
        self.selectedBackgroundView.backgroundColor = tintColor
        self.selectedBackgroundView.layer.cornerRadius = 3.0
        self.addSubview(self.selectedBackgroundView)
        self.selectedBackgroundView.hidden = true
        
        self.selectedLabel = UILabel(frame: CGRect(x: PADDING_X, y: PADDING_Y, width: 0.0, height: 0.0))
        self.selectedLabel.font = self.label.font;
        self.selectedLabel.textColor = UIColor.whiteColor()
        self.selectedLabel.backgroundColor = UIColor.clearColor()
        self.addSubview(self.selectedLabel)
        self.selectedLabel.hidden = true
        
        self.selected = false
        
        self.displayText = token.displayText
        self.hideUnselectedComma = false
        self.updateLabelAttributedText()
        self.selectedLabel.text = token.displayText
        let tapRecognizer:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(CLTokenView.handleTapGestureRecognizer(_:)))
        self.addGestureRecognizer(tapRecognizer)
        self.setNeedsLayout()
    }

    convenience init(token: CLToken, font:UIFont?) {
        self.init(frame: CGRectZero, token: token, font: font)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func intrinsicContentSize() -> CGSize {
        let labelIntrinsicSize:CGSize = self.selectedLabel.intrinsicContentSize()
        return CGSize(width: Double(labelIntrinsicSize.width)+(2.0*PADDING_X), height: Double(labelIntrinsicSize.height)+(2.0*PADDING_Y))
    }
    
    override func sizeThatFits(size: CGSize) -> CGSize {
        let fittingSize = CGSize(width: Double(size.width)-(2.0*PADDING_X), height:Double(size.height)-(2.0*PADDING_Y))
        let labelSize = self.selectedLabel.sizeThatFits(fittingSize)
        return CGSize(width: Double(labelSize.width)+(2.0*PADDING_X), height:Double(labelSize.height)+(2.0*PADDING_Y))
    }
    
    override func tintColorDidChange() {
        super.tintColorDidChange()
        
        self.label.textColor = tintColor
        self.selectedBackgroundView.backgroundColor = tintColor
        self.updateLabelAttributedText()
    }
    
    
    func handleTapGestureRecognizer(sender:UIGestureRecognizer) {
        self.delegate?.tokenViewDidRequestSelection(self)
    }
    
    func setSelected(selectedBool:Bool, animated:Bool) {
        if (self.selected == selectedBool) {
            return
        }
        
        self.selected = selectedBool
        
        self.setSelectedNoCheck(selectedBool, animated: animated)
    }
    
    func setSelectedNoCheck(selectedBool:Bool, animated:Bool) {
        if selectedBool == true && !self.isFirstResponder() {
            self.becomeFirstResponder()
        }
        else if !selectedBool && self.isFirstResponder() {
            self.resignFirstResponder()
        }
        
        var selectedAlpha:CGFloat = 0.0
        if selectedBool == true {
            selectedAlpha = 1.0
        }
        
        if animated == true {
            if self.selected == true {
                self.selectedBackgroundView.alpha = 0.0
                self.selectedBackgroundView.hidden = false
                self.selectedLabel.alpha = 0.0
                self.selectedLabel.hidden = false
            }
            
            UIView.animateWithDuration(0.25, animations: { () -> Void in
                self.selectedBackgroundView.alpha = selectedAlpha
                self.selectedLabel.alpha = selectedAlpha
                }, completion: { (finished:Bool) -> Void in
                    if (!self.selected) {
                        self.selectedBackgroundView.hidden = true
                        self.selectedLabel.hidden = true
                    }
            })
        }
        else {
            self.selectedBackgroundView.hidden = !self.selected
            self.selectedLabel.hidden = !self.selected
        }
    }
    
    func updateLabelAttributedText() {
        var labelString:String!

        if self.hideUnselectedComma == true {
            labelString = "\(displayText)"
        }
        else {
            labelString = "\(displayText),"
        }
        
        let attributes = [ NSFontAttributeName: self.label.font, NSForegroundColorAttributeName: UIColor.lightGrayColor()]
        let attrString = NSMutableAttributedString(string: labelString, attributes: attributes)
        
        let tintRange = (labelString as NSString).rangeOfString(self.displayText)
        
        attrString.setAttributes([NSForegroundColorAttributeName: tintColor], range: tintRange)
        self.label.attributedText = attrString        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let bounds:CGRect = self.bounds
        
        self.backgroundView?.frame = bounds
        self.selectedBackgroundView.frame = bounds
        
        var labelFrame = CGRectInset(bounds, CGFloat(PADDING_X), CGFloat(PADDING_Y))
        self.selectedLabel.frame = labelFrame
        labelFrame.size.width += CGFloat(PADDING_X * 2.0)
        self.label.frame = labelFrame
    }
    
    
    func hasText() -> Bool {
        return true
    }
    
    func insertText(text: String) {
         self.delegate?.tokenViewDidRequestDelete(self, replaceWithText: text)
    }
    
    func deleteBackward() {
         self.delegate?.tokenViewDidRequestDelete(self, replaceWithText: nil)
    }
    
    override func canBecomeFirstResponder() -> Bool {
        return true
    }
    
    override func resignFirstResponder() -> Bool {
        let didResignFirstResponder = super.resignFirstResponder()
        self.setSelected(false, animated: false)
        return didResignFirstResponder
    }
    
    override func becomeFirstResponder() -> Bool {
        let didBecomeFirstResponder = super.becomeFirstResponder()
        self.setSelected(true, animated: false)
        return didBecomeFirstResponder
    }
    
    
}