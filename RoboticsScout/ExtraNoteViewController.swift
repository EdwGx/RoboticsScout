//
//  ExtraNoteViewController.swift
//  RoboticsScout
//
//  Created by Edward Guo on 2016-04-18.
//  Copyright © 2016 Peiliang Guo. All rights reserved.
//

import UIKit
import AERecord

class ExtraNoteViewController: UIViewController, UITextViewDelegate {
    @IBOutlet weak var textView: UITextView!
    
    var currentScoutingEntry: ScoutingEntry?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        textView.text = currentScoutingEntry!.extraNote
        
        textView.delegate = self
        textView.becomeFirstResponder()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textViewDidEndEditing(textView: UITextView) {
        var text: String = textView.text
        if text.hasSuffix("\n") {
            var characters = text.characters
            characters.removeRange(text.characters.endIndex.predecessor()...text.characters.endIndex.predecessor())
            text = String(characters)
        }
        if let entry = currentScoutingEntry {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)) {
                entry.extraNote = text
                entry.changed = true
                entry.newEntry = false
                
                AERecord.saveContext(AERecord.mainContext)
            }
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.keyboardWillChangeFrame(_:)), name: UIKeyboardWillChangeFrameNotification, object: nil)
    }
    
    func keyboardWillChangeFrame(notification: NSNotification){
        let userInfo = notification.userInfo!
        let duration = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as! NSNumber).doubleValue
        let curve = UIViewAnimationCurve(rawValue: (userInfo[UIKeyboardAnimationCurveUserInfoKey] as! NSNumber).integerValue)!
        let frame = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
        let contentInsets = UIEdgeInsets(top: 0, left: 0, bottom: (frame.size.height - 49), right: 0)
        
        UIView.beginAnimations(nil, context: nil)
        UIView.setAnimationDuration(duration)
        UIView.setAnimationCurve(curve)
        UIView.setAnimationBeginsFromCurrentState(true)
        
        textView.contentInset = contentInsets
        textView.scrollIndicatorInsets = contentInsets
        
        UIView.commitAnimations()
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
