//
//  ViewController.swift
//  CLTokenInputView
//
//  Created by Robert La Ferla on 1/13/16 from original ObjC version by Rizwan Sattar.
//  Copyright © 2016 Robert La Ferla. All rights reserved.
//

import UIKit

class ViewController: UIViewController, CLTokenInputViewDelegate, UITableViewDataSource, UITableViewDelegate {
    var names:[String] = []
    var filteredNames:[String] = []
    var selectedNames:[String] = []
    @IBOutlet var tableView:UITableView!
    @IBOutlet var tokenInputView: CLTokenInputView!
    @IBOutlet var secondTokenInputView: CLTokenInputView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.navigationItem.title = "Token Input Test";

        names.appendContentsOf([
            "Robert La Ferla",
            "Brenden Mulligan",
            "Cluster Labs, Inc.",
            "Pat Fives",
            "Rizwan Sattar",
            "Taylor Hughes"])
        
        let infoButton:UIButton = UIButton(type: .InfoDark)
        infoButton.translatesAutoresizingMaskIntoConstraints = false
        infoButton.addTarget(self, action: #selector(ViewController.onFieldInfoButtonTapped(_:)), forControlEvents: .TouchUpInside)
        self.tokenInputView.fieldName = NSLocalizedString("To:", comment: "")
        self.tokenInputView.fieldView = infoButton;
        self.tokenInputView.placeholderText = "Enter a name";
        self.tokenInputView.accessoryView = self.contactAddButton();
        self.tokenInputView.drawBottomBorder = true;
        self.tokenInputView.delegate = self
        
        self.secondTokenInputView.fieldName = NSLocalizedString("Cc:", comment: "")
        self.secondTokenInputView.drawBottomBorder = true;
        self.secondTokenInputView.delegate = self;
        self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "Cell")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(animated: Bool) {
        if !self.tokenInputView.isEditing() {
            self.tokenInputView.beginEditing()
        }
        super.viewDidAppear(animated)
    }
    
    //MARK: CLTokenInputViewDelegate
    
    func tokenInputView(aView: CLTokenInputView, didChangeText text: String) {
       // print("tokenInputView(didChangeText text:\(text))")
        if text == "" {
            self.filteredNames = []
            self.tableView.hidden = true
        }
        else {
            let predicate:NSPredicate = NSPredicate(format: "self contains[cd] %@", argumentArray: [text])
            self.filteredNames = self.names.filter { predicate.evaluateWithObject($0) }
            self.tableView.hidden = false
        }
        self.tableView.reloadData()
    }
    
    func tokenInputView(aView:CLTokenInputView, didAddToken token:CLToken) {
            self.selectedNames.append(token.displayText)
    }

    func tokenInputView(aView:CLTokenInputView, didRemoveToken token:CLToken) {
        let idx:Int? = self.selectedNames.indexOf(token.displayText)
        self.selectedNames.removeAtIndex(idx!)
    }
    
    func tokenInputView(aView: CLTokenInputView, tokenForText text: String) -> CLToken? {
        //print("tokenInputView(tokenForText)")
        if self.filteredNames.count > 0 {
            let matchingName:String = self.filteredNames[0]
            let match:CLToken = CLToken()
            match.displayText = matchingName
            match.context = nil
            return match
        }
        return nil
    }
    
    func tokenInputViewDidEndEditing(aView: CLTokenInputView) {
        aView.accessoryView = nil
    }
    
    func tokenInputViewDidBeginEditing(aView: CLTokenInputView) {
        aView.accessoryView = self.contactAddButton()
        self.view.layoutIfNeeded()
    }
    
    func tokenInputView(aView:CLTokenInputView, didChangeHeightTo height:CGFloat) {
        
    }
    
    //MARK: UITableViewDataSource
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //print("numberOfRowsInSection \(self.filteredNames.count)")

        return self.filteredNames.count
    }

    
    func tableView(aTableView: UITableView, cellForRowAtIndexPath anIndexPath: NSIndexPath) -> UITableViewCell {
        //print("cellForRowAtIndexPath")
        
        let cell = aTableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: anIndexPath)
        let name:String = self.filteredNames[anIndexPath.row]
        cell.textLabel!.text = name
        
        //print("name = \(name)  cell=\(cell)")
        if self.selectedNames.contains(name) {
            cell.accessoryType = .Checkmark
        }
        else {
            cell.accessoryType = .None
        }
        return cell
    }
    
    //MARK: UITableViewDelegate
    
    func tableView(aTableView: UITableView, didSelectRowAtIndexPath anIndexPath: NSIndexPath) {
        aTableView.deselectRowAtIndexPath(anIndexPath, animated: true)
        let name:String = self.filteredNames[anIndexPath.row]
        let token:CLToken = CLToken()
        token.displayText = name
        token.context = nil
        if self.tokenInputView.isEditing() {
            self.tokenInputView.addToken(token)
        }
        else if self.secondTokenInputView.isEditing() {
            self.secondTokenInputView.addToken(token)
        }
    }
    
    //
    
    func onFieldInfoButtonTapped(sender:UIControl) {
        let alertController = UIAlertController(title: "Field Info Button", message: "This view is optional and can be a UIButton, etc.", preferredStyle: .Alert)
        
        let OKAction = UIAlertAction(title: "OK", style: .Default) { (action) in
            // ...
        }
        alertController.addAction(OKAction)
        
        self.presentViewController(alertController, animated: true) {
            // ...
        }
    }
    
    func onAccessoryContactAddButtonTapped(sender:UIControl) {
        let alertController = UIAlertController(title: "Accessory View Button", message: "This view is optional and can be a UIButton, etc.", preferredStyle: .Alert)
        
        let OKAction = UIAlertAction(title: "OK", style: .Default) { (action) in
            // ...
        }
        alertController.addAction(OKAction)
        
        self.presentViewController(alertController, animated: true) {
            // ...
        }
    }
    
    //
    
    func contactAddButton() -> UIButton {
        let contactAddButton:UIButton = UIButton(type: .ContactAdd)
        contactAddButton.addTarget(self, action: #selector(ViewController.onAccessoryContactAddButtonTapped(_:)), forControlEvents: .TouchUpInside)
        return contactAddButton
    }
    
}

