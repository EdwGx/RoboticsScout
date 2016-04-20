//
//  TeamStat.swift
//  RoboticsScout
//
//  Created by Edward Guo on 2016-04-16.
//  Copyright © 2016 Peiliang Guo. All rights reserved.
//

import Foundation
import CoreData
import AERecord

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
    
    func updateAverageRating() {
        guard self.scoutingEntries != nil else { return }
        var sum: Float = 0.0
        var count = 0
        for entry in self.scoutingEntries! {
            if let rating = entry.valueForKey("rating") as? NSNumber {
                let ratingInt = rating.integerValue
                sum += Float(ratingInt) / 10.0
                count += 1
            }
        }
        if sum > 0 {
            self.averageRating = NSNumber(float: Float(sum) / Float(count))
        } else {
            self.averageRating = nil
        }
    }

}
