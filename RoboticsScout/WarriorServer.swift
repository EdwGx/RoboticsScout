//
//  WarriorServer.swift
//  RoboticsScout
//
//  Created by Edward Guo on 2016-04-16.
//  Copyright © 2016 Peiliang Guo. All rights reserved.
//

import Foundation
import CoreData
import AERecord
import Alamofire
import Groot

class WarriorServer {
    static func identifier() -> String? {
        return NSUserDefaults.standardUserDefaults().objectForKey("loginIdentifier") as? String
    }
    
    static func password() -> String? {
        return NSUserDefaults.standardUserDefaults().objectForKey("loginPassword") as? String

    }
    
    static func remoteID() -> Int? {
        if alreadyLogin()  {
            return NSUserDefaults.standardUserDefaults().integerForKey("remoteMemberID")
        }
        return nil
    }
    
    static func remoteFullName() -> String? {
        return NSUserDefaults.standardUserDefaults().objectForKey("remoteMemberFullName") as? String
    
    }
    
    static func alreadyLogin() -> Bool {
        return NSUserDefaults.standardUserDefaults().boolForKey("alreadyLogin")
    }
    
    static func basicParams() -> [String:AnyObject] {
        let id = identifier()
        let pass = password()
        
        if (id != nil && pass != nil) {
            let params : [String:AnyObject] = ["api":"1", "identifier":id!, "password":pass!]
            
            return params
        } else {
            return [String:AnyObject]()
        }
    }
    
    static func lastFetched(name: String) -> String? {
        if let record = DataUpdate.firstWithAttribute("name", value: name) as? DataUpdate {
            return record.lastFetchedAt
        }
        return nil
    }
    
    static func setLastFetched(name: String, timestamp: String?) {
        if timestamp != nil {
            let record = DataUpdate.firstOrCreateWithAttribute("name", value: name) as! DataUpdate
            record.lastFetchedAt = timestamp!
        }
    }
    
    static func sync(completion: (success: Bool) -> Void) {
        syncTeamStat(true, completion: completion)
    }
    
    static func syncTeamStat(lastSuccess: Bool, completion: (success: Bool) -> Void) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)) {
            var placeholderTeamNumbers = Set<String>()
            
            if let placeholderTeams = TeamStat.allWithPredicate(NSPredicate(format: "identifier == nil")) {
                for team in placeholderTeams {
                    placeholderTeamNumbers.insert((team as! TeamStat).number!)
                }
            }
            
            var params = WarriorServer.basicParams()
            
            if let lastFetchedTeam = WarriorServer.lastFetched("TeamStat") {
                params["after"] = lastFetchedTeam
            }
            params["team_numbers"]  = placeholderTeamNumbers.joinWithSeparator(".")
            
            Alamofire.request(.GET, "https://4659warriors.com/team_stats.json", parameters: params).responseJSON(completionHandler: { (response) in
                
                var succeed = false
                if response.response != nil {
                    if response.response!.statusCode == 200 {
                        succeed = response.result.isSuccess
                    }
                }
                
                if succeed {
                    let teamJSON = response.result.value as! [[String:AnyObject]]
                    
                    if teamJSON.count > 0 {
                        let first = teamJSON[0]
                        setLastFetched("TeamStat", timestamp: first["fetchedAt"] as? String)
                    }
                    
                    for team in teamJSON {
                        let teamNumber = team["number"] as! String
                        
                        if placeholderTeamNumbers.contains(team["number"] as! String) {
                            if let oldTeam = TeamStat.firstWithAttribute("number", value: teamNumber) as? TeamStat {
                                oldTeam.identifier = NSNumber(integer: team["id"] as! Int)
                            }
                        } else if (TeamStat.countWithAttribute("number", value: teamNumber) ==  0) {
                            continue
                        }
                        
                        do {
                            try GRTJSONSerialization.objectWithEntityName("TeamStat", fromJSONDictionary: team, inContext: AERecord.defaultContext)
                        } catch {
                            succeed = false
                            print("\(error)")
                        }
                    }
                    
                    AERecord.saveContextAndWait()
                }
                
                syncCompleted(succeed && lastSuccess, completion: completion)
            })
            
        }
    }
    
    static func syncCompleted(lastSuccess: Bool, completion: (success: Bool) -> Void) {
        dispatch_async(dispatch_get_main_queue()) { 
            completion(success: (lastSuccess))
        }
    }
}