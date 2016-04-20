//
//  TeamStat+CoreDataProperties.swift
//  RoboticsScout
//
//  Created by Edward Guo on 2016-04-20.
//  Copyright © 2016 Peiliang Guo. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension TeamStat {

    @NSManaged var actualOrder: NSNumber?
    @NSManaged var averageRating: NSNumber?
    @NSManaged var city: String?
    @NSManaged var country: String?
    @NSManaged var divisionName: String?
    @NSManaged var identifier: NSNumber?
    @NSManaged var number: String?
    @NSManaged var programmingRank: NSNumber?
    @NSManaged var programmingScore: NSNumber?
    @NSManaged var region: String?
    @NSManaged var robotRank: NSNumber?
    @NSManaged var robotScore: NSNumber?
    @NSManaged var teamName: String?
    @NSManaged var hasSelfEntry: NSNumber?
    @NSManaged var scoutingEntries: NSSet?

}
