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

class TeamListViewController: CoreDataTableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        refreshData()
    }
    
    func refreshData() {
        let sortDescriptors = [NSSortDescriptor(key: "number", ascending: true)]
        let request = TeamStat.createFetchRequest(sortDescriptors: sortDescriptors)
        fetchedResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: AERecord.defaultContext, sectionNameKeyPath: nil, cacheName: nil)
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as UITableViewCell
        if let frc = fetchedResultsController {
            if let object = frc.objectAtIndexPath(indexPath) as? TeamStat {
                cell.textLabel!.text = object.number
                cell.detailTextLabel!.text = "\(object.teamName) (\(object.divisionName))"
            }
        }
        return cell
    }
    
}
