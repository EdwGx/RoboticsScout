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

class TeamDetailViewController: UITableViewController, NSFetchedResultsControllerDelegate {
    @IBOutlet weak var teamNameLabel: UILabel!
    @IBOutlet weak var teamLocationLabel: UILabel!
    
    @IBOutlet weak var teamCountryLabel: UILabel!
    @IBOutlet weak var scoutingEntryCountLabel: UILabel!
    
    @IBOutlet weak var robotSkillsRankLabel: UILabel!
    @IBOutlet weak var robotSkillsScoreLabel: UILabel!
    
    @IBOutlet weak var programmingSkillsRankLabel: UILabel!
    @IBOutlet weak var programmingSkillsScoreLabel: UILabel!
    
    @IBOutlet weak var extraNoteTextView: UITextView!
    @IBOutlet weak var extraNoteCell: UITableViewCell!
    
    var teamStat: TeamStat?
    var currentScoutingEntry: ScoutingEntry?
    var manger = ScoutingEntryManger()
    var fetchedResultsController: NSFetchedResultsController?
    
    override func viewDidLoad() {
        loadDefaultScoutingEntry()
        
        super.viewDidLoad()
        
        refreshData()
        
        let predicate = ScoutingEntry.createPredicateForAttributes(["teamStat": teamStat!])
        let request = ScoutingEntry.createFetchRequest(predicate: predicate, sortDescriptors: nil)
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: request,
                                                              managedObjectContext: AERecord.defaultContext,
                                                              sectionNameKeyPath: nil,
                                                              cacheName: nil)
        fetchedResultsController!.delegate = self
        
        
        extraNoteTextView.contentInset = UIEdgeInsets(top: -8, left: -4, bottom: 0, right: 0)
        
        tableView.estimatedRowHeight = 44.0
        tableView.rowHeight = UITableViewAutomaticDimension
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl?.addTarget(self, action: #selector(self.doRefresh(_:)), forControlEvents: .ValueChanged)
    }
    
    func loadDefaultScoutingEntry() {
        currentScoutingEntry = ScoutingEntry.firstOrCreateWithAttributes(["teamStat": teamStat!, "selfEntry":true])
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
        
        if indexPath.section == 1 && currentScoutingEntry!.selfEntry!.boolValue {
            cell.accessoryType = .DisclosureIndicator
            
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
                    detailDescription = String(count: currentScoutingEntry!.rating!.integerValue, repeatedValue: Character("★"))
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
                extraNoteTextView.text = detailDescription
            }
        }
        return cell
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.section == 1 && indexPath.row == 1 {
            extraNoteCell.layoutIfNeeded()
            let width = extraNoteCell.contentView.frame.size.width
            
            let textViewHeight = extraNoteTextView.sizeThatFits(CGSize(width: width, height: CGFloat.max)).height
            return (48.0 + textViewHeight)
        } else {
            return super.tableView(tableView, heightForRowAtIndexPath: indexPath)
        }
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
        if indexPath.section == 1 {
            let attributeName = manger.attributes[indexPath.row]
            if indexPath.row == 1 {
                performSegueWithIdentifier("editExtraNote", sender: self)
            } else if let options = manger.attributeOptions[attributeName] {
                presentAlertSheetForIndexPath(indexPath, options: options)
            } else {
                presentAlertControllerForIndexPath(indexPath, isStringInput: false)
            }
        }
    }
    
    func presentAlertControllerForIndexPath(indexPath: NSIndexPath, isStringInput: Bool) {
        let attributeName = manger.attributes[indexPath.row]
        let displayName = manger.displayNames[indexPath.row]
        
        let alert = UIAlertController(title: displayName, message: nil, preferredStyle: .Alert)
        
        alert.addTextFieldWithConfigurationHandler { (field) in
            field.autocorrectionType = .No
            field.autocapitalizationType = .None
            
            if isStringInput {
                field.keyboardType = .Default
            } else {
                field.keyboardType = .NumbersAndPunctuation
            }
        }
        
        let done = UIAlertAction(title: "Done", style: .Default) { [weak self, weak alert](action) in
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), {
                if self != nil && alert != nil {
                    let text = alert?.textFields![0].text
                    if text != nil && !text!.isEmpty {
                        if isStringInput {
                            dispatch_async(dispatch_get_main_queue(), {
                                self!.currentScoutingEntry?.setValue(text, forKey: attributeName)
                            })
                        } else if let integer = Int(text!) {
                            let number = NSNumber(integer: integer)
                            self!.currentScoutingEntry?.setValue(number, forKey: attributeName)
                        }
                        self!.currentScoutingEntry?.setValue(true, forKey: "changed")
                        self!.currentScoutingEntry?.setValue(false, forKey: "newEntry")
                        
                        AERecord.saveContextAndWait()
                    }
                }
            })
        }
        alert.addAction(done)
        
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
                        
                        AERecord.saveContextAndWait()
                    })
                }
            }
            dispatch_async(dispatch_get_main_queue(), {
                self!.tableView.deselectRowAtIndexPath(indexPath, animated: true)
            })
        }
        for option in displayOptions {
            let action = UIAlertAction(title: option, style: .Default, handler: handler)
            alert.addAction(action)
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: .Cancel) { [weak self](action) in
            dispatch_async(dispatch_get_main_queue(), {
                self!.tableView.deselectRowAtIndexPath(indexPath, animated: true)
            })
        }
        alert.addAction(cancel)
        
        self.presentViewController(alert, animated: true, completion: nil)
        
    }
    
    func doRefresh(sender: UIRefreshControl) {
        print("Refresh")
        sender.endRefreshing()
    }
}
