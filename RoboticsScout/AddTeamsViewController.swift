//
//  AddTeamsViewController.swift
//  RoboticsScout
//
//  Created by Edward Guo on 2016-04-16.
//  Copyright © 2016 Peiliang Guo. All rights reserved.
//

import UIKit
import Alamofire
import AERecord
import Groot

class AddTeamsViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    @IBOutlet weak var pickerView : UIPickerView!
    @IBOutlet weak var teamNumberField: UITextField!
    @IBOutlet weak var addButton: UIButton!
    
    let optionList = ["Team Number", "Science", "Technology", "Engineering", "Arts", "Math"]
    var requesting = false {
        didSet {
            dispatch_async(dispatch_get_main_queue(), {
                if self.requesting {
                    self.addButton.enabled = false
                } else {
                    self.addButton.enabled = true
                }
            })
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        pickerView.delegate = self
        pickerView.dataSource = self
        
        pickerView.reloadAllComponents()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return optionList.count
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return optionList[row]
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if row == 0 {
            teamNumberField.hidden = false
        } else {
            teamNumberField.hidden = true
        }
    }
    
    @IBAction func addTeams(sender: AnyObject) {
        if (!requesting) {
            requesting = true
            let selectedRow = pickerView.selectedRowInComponent(0)
            
            if (selectedRow > 0) {
                addTeamInDivision(selectedRow)
            } else if (teamNumberField.text != nil && !teamNumberField.text!.isEmpty) {
                addTeamWithNumber(teamNumberField.text!)
            } else {
                self.performSegueWithIdentifier("finishAddTeam", sender: self)
            }
        }
    }
    
    func addTeamInDivision(division: Int) {
        
        Alamofire.request(.GET, "https://4659warriors.com/divisions/\(division).json", parameters: WarriorServer.basicParams()).responseJSON {
            response in
            
            var succeed = false
            if response.response != nil {
                if response.response!.statusCode == 200 {
                    succeed = response.result.isSuccess
                }
            }
            
            if succeed {
                let result = response.result.value as! [String:AnyObject]
                
                self.createTeamsFromResponse(result["teams"] as! [AnyObject])
            } else {
                dispatch_async(dispatch_get_main_queue(), {
                    let alert = UIAlertController(title: "Network Connection", message: "Can't connect to server. Use Team Number to force add team.", preferredStyle: .Alert)
                    let dismiss = UIAlertAction(title: "Dismiss", style: .Cancel, handler: nil)
                    alert.addAction(dismiss)
                    self.presentViewController(alert, animated: true, completion: nil)
                    self.requesting = false
                })
            }
        }
        
    }
    
    func addTeamWithNumber(number: String) {
        var params = WarriorServer.basicParams()
        params["like"] = number
        
        Alamofire.request(.GET, "https://4659warriors.com/team_stats.json", parameters: params).responseJSON {
            response in
            
            var succeed = false
            if response.response != nil {
                if response.response!.statusCode == 200 {
                    succeed = response.result.isSuccess
                }
            }
            
            if succeed {
                self.createTeamsFromResponse(response.result.value as! [AnyObject])
            } else {
                let teamJSON = ["number":number, "team_name":number, "robot_score":0, "robot_rank":5000, "programming_score":0, "programming_rank":5000, "country":"N/A", "city":"N/A", "region":"N/A", "divison_name":"N/A", "actual_order":0]
                self.createTeamsFromResponse([teamJSON])
            }
            
            self.requesting = false
        }
        
    }
    
    func createTeamsFromResponse(teams: [AnyObject]) {
        
//        for rawTeam in teams {
//            let teamJSON = rawTeam as! [String:AnyObject]
//            let teamNumber = teamJSON["number"] as! String
//            
//            let team = TeamStat.firstOrCreateWithAttribute("number", value: teamNumber) as! TeamStat
//            
//            team.number = teamNumber
//            team.teamName = teamJSON["team_name"] as! String
//            team.remoteID = NSNumber(integer: (teamJSON["id"] as! Int))
//            
//            team.robotScore = NSNumber(integer: (teamJSON["robot_score"] as! Int))
//            team.robotRank = NSNumber(integer: (teamJSON["robot_rank"] as! Int))
//            
//            team.programmingScore = NSNumber(integer: (teamJSON["programming_score"] as! Int))
//            team.programmingRank = NSNumber(integer: (teamJSON["programming_rank"] as! Int))
//            
//            team.country = teamJSON["country"] as? String
//            team.city = teamJSON["city"] as? String
//            team.region = teamJSON["region"] as? String
//            
//            team.divisionName = teamJSON["division_name"] as? String
//            
//            if teamJSON["actual_order"] != nil {
//                team.actualOrder = NSNumber(integer: (teamJSON["actual_order"] as! Int))
//            }
//        }
        do {
            try GRTJSONSerialization.objectsWithEntityName("TeamStat", fromJSONArray: teams, inContext: AERecord.mainContext)
            AERecord.saveContextAndWait(AERecord.mainContext)
        } catch {
            print("\(error)")
        }
        
        dispatch_async(dispatch_get_main_queue(), {
            self.requesting = false
            self.performSegueWithIdentifier("finishAddTeam", sender: self)
        })
        
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
