//
//  TeamDetailViewController.swift
//  RoboticsScout
//
//  Created by Edward Guo on 2016-04-16.
//  Copyright © 2016 Peiliang Guo. All rights reserved.
//

import UIKit
import CoreData
import AERecord

class TeamDetailViewController: UITableViewController, ScoutingEntryMangerDelegate {
    @IBOutlet weak var teamNameLabel: UILabel!
    @IBOutlet weak var teamLocationLabel: UILabel!
    
    @IBOutlet weak var teamCountryLabel: UILabel!
    @IBOutlet weak var scoutingEntryCountLabel: UILabel!
    
    @IBOutlet weak var robotSkillsRankLabel: UILabel!
    @IBOutlet weak var robotSkillsScoreLabel: UILabel!
    
    @IBOutlet weak var programmingSkillsRankLabel: UILabel!
    @IBOutlet weak var programmingSkillsScoreLabel: UILabel!
    
    var teamStat: TeamStat?
    var currentScoutingEntry: ScoutingEntry?
    var manger = ScoutingEntryManger()
    
    override func viewDidLoad() {
        manger.delegate = self
        loadDefaultScoutingEntry()
        
        super.viewDidLoad()
        
        refreshData()
        
        tableView.estimatedRowHeight = 44.0
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl?.addTarget(self, action: #selector(self.doRefresh(_:)), forControlEvents: .ValueChanged)
    }
    
    func loadDefaultScoutingEntry() {
        currentScoutingEntry = ScoutingEntry.firstOrCreateWithAttributes(["teamStat": teamStat!, "selfEntry":true], predicateType: .AndPredicateType, context: AERecord.mainContext)
        manger.observingScoutingEntry = currentScoutingEntry
    }
    
    func scoutingEntry(scoutingEntry: ScoutingEntry, didChangedValues changedValues: [String : AnyObject]) {
        var reloadIndexPaths = [NSIndexPath]()
        for (key, _) in changedValues {
            if let index = manger.attributes.indexOf(key) {
                reloadIndexPaths.append(NSIndexPath(forRow: index, inSection: 1))
            }
        }
        tableView.reloadRowsAtIndexPaths(reloadIndexPaths, withRowAnimation: .None)
    }
    
    
    func refreshData() {
        guard let team = teamStat else { return }
        
        let presistedScoutingEntryCount = ScoutingEntry.countWithAttributes(["teamStat": team, "newEntry": false])
        
        navigationItem.title = team.number
        
        teamNameLabel.text = team.teamName
        teamLocationLabel.text = team.location
        teamCountryLabel.text = team.country
        
        if presistedScoutingEntryCount == 1 {
            scoutingEntryCountLabel.text = "1 entry"
        } else {
            scoutingEntryCountLabel.text = "0 entries"
        }
        
        if team.robotRank != nil && team.robotScore != nil {
            robotSkillsRankLabel.text = "#\(team.robotRank!)"
            robotSkillsScoreLabel.text = "\(team.robotScore!)"
        }
        
        if team.programmingRank != nil && team.programmingScore != nil {
            programmingSkillsRankLabel.text = "#\(team.programmingRank!)"
            programmingSkillsScoreLabel.text = "\(team.programmingScore!)"
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAtIndexPath: indexPath)
        
        if indexPath.section == 1 {
            if currentScoutingEntry!.selfEntry!.boolValue {
                cell.accessoryType = .DisclosureIndicator
            } else {
                cell.accessoryType = .None
            }
            
            var detailDescription: String
            
            if indexPath.row > 1 {
                let attributeName = manger.attributes[indexPath.row]
                
                switch  currentScoutingEntry?.valueForKey(attributeName) {
                case let number as NSNumber:
                    detailDescription = "\(number.integerValue)"
                case let string as String:
                    detailDescription = string
                default:
                    detailDescription = "N/A"
                }
                cell.detailTextLabel!.text = detailDescription
            } else if indexPath.row == 0 {
                if currentScoutingEntry!.rating != nil {
                    detailDescription = NSString(format: "%.1f/10 ★", Float(currentScoutingEntry!.rating!.integerValue) / 10.0) as String
                } else {
                    detailDescription = "N/A"
                }
                cell.detailTextLabel!.text = detailDescription
            } else {
                if currentScoutingEntry!.extraNote != nil {
                    detailDescription = currentScoutingEntry!.extraNote!
                } else {
                    detailDescription = ""
                }
                (cell as! ExtraNoteTableViewCell).noteText = detailDescription
            }
        }
        return cell
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 1:
            if let entry = currentScoutingEntry {
                if entry.selfEntry!.boolValue {
                    var nameSummary = ""
                    if let fullName = WarriorServer.remoteFullName() {
                        nameSummary += fullName
                    } else {
                        nameSummary = "Your entry"
                    }
                    
                    if entry.newEntry!.boolValue {
                        nameSummary += " (New)"
                    } else if entry.changed!.boolValue {
                        nameSummary += " (Changed)"
                    }
                    return nameSummary
                } else {
                    return entry.memberName
                }
            }
        default: break
            
        }
        return super.tableView(tableView, titleForHeaderInSection: section)
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 0 {
            if indexPath.row == 2 {
                presentActionSheetForShowingAllEntries()
                self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
            }
        } else {
            let attributeName = manger.attributes[indexPath.row]
            if indexPath.row == 1 {
                performSegueWithIdentifier("editExtraNote", sender: self)
            } else if let options = manger.attributeOptions[attributeName] {
                presentAlertSheetForIndexPath(indexPath, options: options)
            } else {
                presentAlertControllerForIndexPath(indexPath, isStringInput: false)
            }
            self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
        }
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.section == 1 && indexPath.row == 1 {
            return UITableViewAutomaticDimension
        } else {
            return super.tableView(tableView, heightForRowAtIndexPath: indexPath)
        }
    }
    
    func presentActionSheetForShowingAllEntries() {
        var entryNames = [String]()
        if let fullName = WarriorServer.remoteFullName() {
            entryNames.append(fullName)
        } else {
            entryNames.append("You")
        }
        
        let sortDescriptor = NSSortDescriptor(key: "memberName", ascending: true)
        if let entries = ScoutingEntry.allWithAttributes(["teamStat":teamStat!, "selfEntry":false], predicateType: .AndPredicateType, sortDescriptors: [sortDescriptor], context: AERecord.defaultContext) {
            let names: [String] = entries.map { ($0.valueForKey("memberName")! as! String) }
            entryNames += names
        }
        
        let alert = UIAlertController(title: "Choose Scouting Entry", message: nil, preferredStyle: .ActionSheet)
        
        let handler = {[weak self](action: UIAlertAction) -> Void in
            guard self != nil else { return }
            
            if let title = action.title {
                let entry: ScoutingEntry?
                if title == "You" {
                    entry = ScoutingEntry.firstWithAttributes(["teamStat": self!.teamStat!, "selfEntry": true], predicateType: .AndPredicateType, context: AERecord.mainContext)
                } else {
                    entry = ScoutingEntry.firstWithAttributes(["teamStat": self!.teamStat!, "memberName": title], predicateType: .AndPredicateType, context: AERecord.mainContext)
                }
                
                if entry != nil {
                    self!.reloadScoutingEntry(entry!)
                }
            }
        }
        
        for name in entryNames {
            let action = UIAlertAction(title: name, style: .Default, handler: handler)
            alert.addAction(action)
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        alert.addAction(cancel)
        
        self.presentViewController(alert, animated: true, completion: nil)
        
    }
    
    func reloadScoutingEntry(entry: ScoutingEntry) {
        self.currentScoutingEntry = entry
        self.manger.observingScoutingEntry = currentScoutingEntry
        
        let sections = NSIndexSet(index: 1)
        self.tableView.reloadSections(sections, withRowAnimation: .None)
        
    }
    
    func presentAlertControllerForIndexPath(indexPath: NSIndexPath, isStringInput: Bool) {
        let attributeName = manger.attributes[indexPath.row]
        let displayName = manger.displayNames[indexPath.row]
        let currentValue: String?
        
        switch self.currentScoutingEntry?.valueForKey(attributeName) {
        case let string as String:
            currentValue = string
        case let number as NSNumber:
            if attributeName == "rating" {
                currentValue = NSString(format: "%.1f", number.integerValue/10) as String
            } else {
                currentValue = "\(number.integerValue)"
            }
        default:
            currentValue = nil
        }
        
        let alert = UIAlertController(title: displayName, message: nil, preferredStyle: .Alert)
        
        alert.addTextFieldWithConfigurationHandler { (field) in
            field.text = currentValue
            
            field.autocorrectionType = .No
            field.autocapitalizationType = .None
            field.returnKeyType = .Done
            field.clearButtonMode = .Always
            
            if isStringInput {
                field.keyboardType = .Default
            } else {
                field.keyboardType = .NumbersAndPunctuation
            }
        }
        
        let done = UIAlertAction(title: "Done", style: .Default) { [weak self, weak alert](action) in
            let text = alert?.textFields![0].text
            guard text != nil && !text!.isEmpty else { return }
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), {
                guard self != nil else { return }
                
                if isStringInput {
                    dispatch_async(dispatch_get_main_queue(), {
                        self!.currentScoutingEntry?.setValue(text, forKey: attributeName)
                    })
                } else if attributeName == "rating" {
                    if var floatValue = Float(text!) {
                        floatValue = floatValue * 10.0
                        self!.currentScoutingEntry?.rating = NSNumber(integer: min(100, max(0, Int(floatValue))))
                        self!.currentScoutingEntry?.teamStat?.updateAverageRating()
                    }
                    
                } else if let integer = Int(text!) {
                    let number = NSNumber(integer: integer)
                    
                    self!.currentScoutingEntry?.setValue(number, forKey: attributeName)
                    
                }
                
                do {
                    try self!.currentScoutingEntry?.validateForUpdate()
                    self!.currentScoutingEntry?.setValue(true, forKey: "changed")
                    if self!.currentScoutingEntry!.newEntry!.boolValue {
                        self!.currentScoutingEntry!.setValue(false, forKey: "newEntry")
                        self!.currentScoutingEntry!.teamStat?.hasSelfEntry = true
                    }
                    
                    AERecord.saveContext(AERecord.mainContext)
                } catch let validationError as NSError {
                    let errors = validationError.userInfo[NSLocalizedDescriptionKey]
                    debugPrint("\(errors)")
                    
                } catch {
                    print("\(error)")
                }
            })
        }
        alert.addAction(done)
        
        let cancel = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        alert.addAction(cancel)
        
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func presentAlertSheetForIndexPath(indexPath: NSIndexPath, options: [String]) {
        let attributeName = manger.attributes[indexPath.row]
        let displayName = manger.displayNames[indexPath.row]
        let displayOptions = options + ["Other"]
        
        let alert = UIAlertController(title: displayName, message: nil, preferredStyle: .ActionSheet)
        
        let handler = {[weak self](action: UIAlertAction) -> Void in
            if let title = action.title {
                if title == "Other" {
                    self!.presentAlertControllerForIndexPath(indexPath, isStringInput: true)
                } else {
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), {
                        self!.currentScoutingEntry?.setValue(title, forKey: attributeName)
                        self!.currentScoutingEntry?.setValue(true, forKey: "changed")
                        self!.currentScoutingEntry?.setValue(false, forKey: "newEntry")
                        
                        AERecord.saveContext(AERecord.mainContext)
                    })
                }
            }
        }
        for option in displayOptions {
            let action = UIAlertAction(title: option, style: .Default, handler: handler)
            alert.addAction(action)
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        alert.addAction(cancel)
        
        self.presentViewController(alert, animated: true, completion: nil)
        
    }
    
    func doRefresh(sender: UIRefreshControl) {
        print("Refresh")
        sender.endRefreshing()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        super.prepareForSegue(segue, sender: sender)
        
        if segue.identifier == "editExtraNote" {
            let extraNoteVC = segue.destinationViewController as! ExtraNoteViewController
            extraNoteVC.currentScoutingEntry = self.currentScoutingEntry
        }
    }
}
