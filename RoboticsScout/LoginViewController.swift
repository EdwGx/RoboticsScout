//
//  LoginViewController.swift
//  RoboticsScout
//
//  Created by Edward Guo on 2016-04-16.
//  Copyright © 2016 Peiliang Guo. All rights reserved.
//

import UIKit
import Alamofire

class LoginViewController: UIViewController {

    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var loginButton: UIButton!
    
    @IBOutlet weak var identifierField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    @IBOutlet weak var identifierLabel: UILabel!
    @IBOutlet weak var passwordLabel: UILabel!
    
    var requesting = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        refreshData()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func nextField(sender: AnyObject) {
        passwordField.becomeFirstResponder()
    }
    
    @IBAction func login(sender: AnyObject) {
        identifierField.resignFirstResponder()
        passwordField.resignFirstResponder()
        
        if (!requesting) {
            if (identifierField.text != nil && passwordField.text != nil) {
                requesting = true
                
                let identifier = identifierField.text!
                let password = passwordField.text!
                
                let params = [ "identifier":identifier,
                               "password":password ]
                
                Alamofire.request(.POST, "https://4659warriors.com/signin.json",
                                  parameters: params).responseJSON
                    { response in
                        var succeed = false
                        if response.response != nil {
                            if response.response!.statusCode == 200 {
                                succeed = response.result.isSuccess
                            }
                        }
                        
                        let result = response.result
                        var loginSucceed = false
                        if succeed {
                            let value = result.value as! [String:AnyObject]
                            if (value["access"] as! Int) > 0 {
                                let defaults = NSUserDefaults.standardUserDefaults()
                                
                                defaults.setObject(identifier, forKey: "loginIdentifier")
                                defaults.setObject(password, forKey: "loginPassword")
                                defaults.setInteger(value["member_id"]! as! Int, forKey: "remoteMemberID")
                                defaults.setObject(value["member_full_name"] as! String, forKey: "remoteMemberFullName")
                                
                                defaults.setBool(true, forKey: "alreadyLogin")
                                loginSucceed = true
                            }
                        }
                        
                        if loginSucceed {
                            dispatch_async(dispatch_get_main_queue(), {
                                self.requesting = false
                                self.refreshData()
                            })
                        } else {
                            dispatch_async(dispatch_get_main_queue(), {
                                self.requesting = false
                                let alert = UIAlertController(title: "Can't Login", message: "Incorrect Identifier or Password. Unable to connect to server.", preferredStyle: .Alert)
                                let dismiss = UIAlertAction(title: "Dismiss", style: .Cancel, handler: nil)
                                alert.addAction(dismiss)
                                self.presentViewController(alert, animated: true, completion: nil)
                            })
                        }
                
                        
                    }
            }
            
        }
    }
    
    func refreshData() {
        if WarriorServer.alreadyLogin() {
            nameLabel.hidden = false
            
            identifierLabel.hidden = true
            identifierField.hidden = true
            passwordLabel.hidden = true
            passwordField.hidden = true
            loginButton.hidden = true
            
            nameLabel.text = WarriorServer.remoteFullName()
        } else {
            nameLabel.hidden = true
            
            identifierLabel.hidden = false
            identifierField.hidden = false
            passwordLabel.hidden = false
            passwordField.hidden = false
            loginButton.hidden = false
        }
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
