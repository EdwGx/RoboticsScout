//
//  DataUpdate+CoreDataProperties.swift
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

extension DataUpdate {

    @NSManaged var lastFetchedAt: String?
    @NSManaged var name: String?

}
