//
//  TeamListViewController.swift
//  RoboticsScout
//
//  Created by Edward Guo on 2016-04-15.
//  Copyright © 2016 Peiliang Guo. All rights reserved.
//

import UIKit
import CoreData
import AERecord
import AECoreDataUI

class TeamListViewController: CoreDataTableViewController, UISearchBarDelegate {
    var selectedTeamStat: TeamStat?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setFetchRequest(nil)
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl?.addTarget(self, action: #selector(self.doRefresh(_:)), forControlEvents: .ValueChanged)
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! TeamInfoCell
        if let frc = fetchedResultsController {
            if let object = frc.objectAtIndexPath(indexPath) as? TeamStat {
                cell.numberLabel.text = object.number
                cell.nameLabel.text = object.teamName
                
                cell.divisionName = object.divisionName
                if object.scoutingEntries != nil {
                    cell.numberOfEntries = object.scoutingEntries!.count
                } else {
                    cell.numberOfEntries = 0
                }
                
                cell.hasOwnEntry = object.hasSelfEntry!.boolValue
                
                cell.upcomingMatches = []
                
                cell.rating = object.averageRating?.floatValue
                
                if object.robotScore != nil {
                    cell.robotScoreLabel.text = "\(object.robotScore!)"
                }
                
                if object.programmingScore != nil {
                    cell.programmingScoreLabel.text = "\(object.programmingScore!)"
                }
            }
        }
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if let frc = fetchedResultsController {
            if let object = frc.objectAtIndexPath(indexPath) as? TeamStat {
                selectedTeamStat = object
                performSegueWithIdentifier("showTeam", sender: self)
            }
        }
    }
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // delete object
            if let team = fetchedResultsController?.objectAtIndexPath(indexPath) as? TeamStat {
                team.deleteFromContext()
                AERecord.saveContext()
            }
        }
    }
    
    @IBAction func unwindTeamList(segue: UIStoryboardSegue){
        
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        searchBar.text = nil
        setFetchRequest(nil)
        searchBar.resignFirstResponder()
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            setFetchRequest(nil)
        } else if searchText == "0" {
            //Load all empty entry
        } else {
            let predicate = NSPredicate(format: "(number CONTAINS[cd] %@) OR (divisionName CONTAINS[cd] %@) OR (teamName CONTAINS[cd] %@)", searchText, searchText, searchText)
            let sortDescriptors = [NSSortDescriptor(key: "actualOrder", ascending: true)]
            let request = TeamStat.createFetchRequest(predicate: predicate, sortDescriptors: sortDescriptors)
            
            setFetchRequest(request)
        }
    }
    
    func setFetchRequest(request: NSFetchRequest?) {
        let fetchRequest: NSFetchRequest
        if request == nil {
            let sortDescriptors = [NSSortDescriptor(key: "actualOrder", ascending: true)]
            fetchRequest = TeamStat.createFetchRequest(sortDescriptors: sortDescriptors)
        } else {
            fetchRequest = request!
        }
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: AERecord.defaultContext, sectionNameKeyPath: nil, cacheName: nil)
    }
    
    func doRefresh(sender: UIRefreshControl) {
        WarriorServer.sync { success in
            sender.endRefreshing()
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        super.prepareForSegue(segue, sender: sender)
        if segue.identifier == "showTeam" {
            if let teamDetailVC = segue.destinationViewController as? TeamDetailViewController {
                teamDetailVC.teamStat = selectedTeamStat
            }
        }
    }
}
