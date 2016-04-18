//
//  TeamStat.swift
//  RoboticsScout
//
//  Created by Edward Guo on 2016-04-16.
//  Copyright © 2016 Peiliang Guo. All rights reserved.
//

import Foundation
import CoreData


class TeamStat: NSManagedObject {

// Insert code here to add functionality to your managed object subclass
    var location: String {
        get {
            if city != nil && region != nil {
                return "\(city!), \(region!)"
            } else if city != nil {
                return "\(city!), N/A"
            } else if city != nil {
                return "N/A \(region!)"
            } else {
                return "N/A"
            }
        }
    }

}
