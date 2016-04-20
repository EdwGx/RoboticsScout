//
//  TeamInfoCell.swift
//  RoboticsScout
//
//  Created by Edward Guo on 2016-04-16.
//  Copyright © 2016 Peiliang Guo. All rights reserved.
//

import UIKit

class TeamInfoCell: UITableViewCell {
    
    @IBOutlet weak var numberLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet var upcomingMatchLabels: [UILabel]!
    @IBOutlet weak var robotScoreLabel: UILabel!
    @IBOutlet weak var programmingScoreLabel: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!
    
    var divisionName: String? { didSet { updateDescriptionLabel() } }
    var numberOfEntries: Int = 0 { didSet { updateDescriptionLabel() } }
    var hasOwnEntry: Bool = false { didSet { updateDescriptionLabel() } }
    
    var rating: Float? = nil {
        didSet {
            if rating != nil {
                ratingLabel.text = NSString(format: "%.1f/10 ★", rating!) as String
            } else {
                ratingLabel.text = "Not Rated"
            }
            
        }
    }
    
    var upcomingMatches: [String] = [] {
        didSet {
            for label in upcomingMatchLabels {
                label.text = ""
            }
            
            for i in 0..<upcomingMatches.count {
                upcomingMatchLabels[i].text = upcomingMatches[i]
            }
        }
    }
    
    func updateDescriptionLabel() {
        var description = ""
        
        
        
        if numberOfEntries == 1 {
            description += "1 entry - "
        } else {
            description += "\(numberOfEntries) entries - "
        }
        
        if hasOwnEntry {
            description += "✓ - "
        } else {
            description += "𐄂 - "
        }
        
        if divisionName != nil {
            description += "\(divisionName!)"
        } else {
            description += "N/A"
        }
        
        descriptionLabel.text = description
    }
}
