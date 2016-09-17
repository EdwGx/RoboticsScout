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
                
                syncUploadingScoutingEntries(lastSuccess && succeed, completion: completion)
            })
            
        }
    }
    
    static func syncUploadingScoutingEntries(lastSuccess: Bool, completion: (success: Bool) -> Void) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)) {
            if let changedEntries = ScoutingEntry.allWithAttributes(["selfEntry":true, "changed":true]) {
                var entriesJSON = [[String:AnyObject]]()
                
                for object in changedEntries {
                    let entry = object as! ScoutingEntry
                    entry.changed = NSNumber(bool: false)
                    
                    var dictionary = JSONDictionaryFromObject(entry)
                    if entry.teamStat!.identifier != nil {
                        dictionary["team_stat_id"] = entry.teamStat!.identifier
                    } else if entry.teamStat!.number != nil {
                        dictionary["team_stat_number"] = entry.teamStat!.number
                    }
                    entriesJSON.append(dictionary)
                }
                
                AERecord.saveContextAndWait(AERecord.defaultContext)

                var params = WarriorServer.basicParams()
                params["scouting_entries"] = entriesJSON
                
                Alamofire.request(.POST, "https://4659warriors.com/scouting_entries/mass.json", parameters: params, encoding: .JSON, headers: ["Content-Type":"application/json"]).responseJSON(completionHandler: { (response) in
                    
                    var succeed = false
                    if response.response != nil {
                        if response.response!.statusCode == 200 {
                            succeed = response.result.isSuccess
                        }
                    }
                    
                    if succeed {
                        succeed = response.result.value!["success"] as! Bool
                        if let scoutingEntryIds = response.result.value!["scouting_entry_ids"] as? [AnyObject] {
                            for i in 0..<scoutingEntryIds.count {
                                if let entryId = scoutingEntryIds[i] as? Int {
                                    changedEntries[i].setValue(NSNumber(integer: entryId), forKey: "identifier")
                                }
                            }
                            
                            AERecord.saveContextAndWait(AERecord.defaultContext)
                        }
                    }
                    syncDownloadingScoutingEntries(lastSuccess && succeed, completion: completion)
                })
            
                
            } else {
                syncDownloadingScoutingEntries(false, completion: completion)
            }
            
        }
    }
    
    static func syncDownloadingScoutingEntries(lastSuccess: Bool, completion: (success: Bool) -> Void) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)) {
            var params = WarriorServer.basicParams()
            
//            if let lastFetchedTeam = WarriorServer.lastFetched("ScoutingEntries") {
//                params["after"] = lastFetchedTeam
//            }
            
            Alamofire.request(.GET, "https://4659warriors.com/scouting_entries.json", parameters: params).responseJSON(completionHandler: { (response) in
                
                var succeed = false
                if response.response != nil {
                    if response.response!.statusCode == 200 {
                        succeed = response.result.isSuccess
                    }
                }

                if succeed {
                    let scoutingEntryJSON = response.result.value as! [[String:AnyObject]]
                    
                    if scoutingEntryJSON.count > 0 {
                        let first = scoutingEntryJSON[0]
                        setLastFetched("ScoutingEntries", timestamp: first["fetchedAt"] as? String)
                    }
                    
                    for var entryJSON in scoutingEntryJSON {
                        do {
                            let identifier = NSNumber(integer: (entryJSON["team_stat_id"] as! Int) )
                            
                            if TeamStat.countWithAttribute("identifier", value: identifier) > 0 {
                                let scoutingEntry = try GRTJSONSerialization.objectWithEntityName("ScoutingEntry", fromJSONDictionary: entryJSON, inContext: AERecord.defaultContext) as! ScoutingEntry
                                
                                scoutingEntry.newEntry = NSNumber(bool: false)
                                scoutingEntry.selfEntry = NSNumber(bool: false)
                                scoutingEntry.changed = NSNumber(bool: false)
                                
                                if ((entryJSON["member_id"] as! Int) ==  remoteID()) {
                                   scoutingEntry.selfEntry = NSNumber(bool: true)
                                }
                                
                                scoutingEntry.teamStat!.updateAverageRating()
                            }
                        } catch {
                            succeed = false
                            print("\(error)")
                        }
                    }
                    
                    AERecord.saveContextAndWait(AERecord.defaultContext)
                }
                
                syncCompleted(lastSuccess && succeed, completion: completion)
            })

        }
    }
    
    static func syncCompleted(lastSuccess: Bool, completion: (success: Bool) -> Void) {
        dispatch_async(dispatch_get_main_queue()) { 
            completion(success: (lastSuccess))
        }
    }
}