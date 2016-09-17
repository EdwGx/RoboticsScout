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
//            succeed = true
//            let teamNumbers = ["2Z", "24B", "39", "64", "82M", "169A", "180", "217D", "241N", "288A", "333T", "359A", "400X", "563", "590", "675C", "750W", "889E", "973G", "1028A", "1064P", "1104V", "1138", "1233C", "1344", "1366", "1460A", "1497K", "1575C", "1670A", "1879B", "2011B", "2105C", "2131W", "2335", "2442C", "2576A", "2616F", "2886A", "2941A", "3273B", "3309A", "3396", "3815J", "3946E", "4029A", "4146V", "4194E", "4334A", "4478C", "4659D", "4815A", "4828S", "5062A", "5107C", "5221B", "5327C", "5454B", "5482C", "5689A", "5772C", "5776Z", "5937A", "6023S", "6106A", "6135K", "6272B", "6430B", "6659", "6740B", "6891", "7001D", "7121", "7232Z", "7439", "7612", "7682E", "7853", "7882B", "7972D", "8000D", "8059D", "8176A", "8430", "8585D", "8659G", "8739A", "8787C", "8900", "9020", "9090C", "9282", "9421", "9541", "9708", "9898C", "9964S", "32016A", "99153K", "99679J"]
//            var teams = [AnyObject]()
//            for number in teamNumbers {
//                teams.append(["number":number, "team_name":number, "robot_score":0, "robot_rank":5000, "programming_score":0, "programming_rank":5000, "country":"N/A", "city":"N/A", "region":"N/A", "division_name":"Engineering", "actual_order":0])
//            }
//            let result :[String:AnyObject] = ["teams": teams]
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
                let teamJSON = ["number":number, "team_name":number, "robot_score":0, "robot_rank":5000, "programming_score":0, "programming_rank":5000, "country":"N/A", "city":"N/A", "region":"N/A", "division_name":"N/A", "actual_order":0]
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
