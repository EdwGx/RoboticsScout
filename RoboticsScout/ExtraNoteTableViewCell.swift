//
//  ExtraNoteTableViewCell.swift
//  RoboticsScout
//
//  Created by Edward Guo on 2016-04-19.
//  Copyright © 2016 Peiliang Guo. All rights reserved.
//

import UIKit

class ExtraNoteTableViewCell: UITableViewCell {
    @IBOutlet weak var noteLabel: UILabel!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var naLabel: UILabel!
    
    var naRightConstrain: NSLayoutConstraint?
    var titleConstrain: NSLayoutConstraint?
    var noteConstrains = [NSLayoutConstraint]()
    
    var noteText: String? {
        didSet {
            updateNoteLabel()
        }
    }
    
    override var accessoryType: UITableViewCellAccessoryType {
        didSet {
            if accessoryType == .DisclosureIndicator {
                naRightConstrain?.constant = -8.0
            } else {
                naRightConstrain?.constant = 8.0
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        noteLabel.translatesAutoresizingMaskIntoConstraints = false
        
        titleConstrain = NSLayoutConstraint(item: self.contentView, attribute: .BottomMargin, relatedBy: .Equal, toItem: titleLabel, attribute: .Bottom, multiplier: 1.0, constant: 3.0)
        titleConstrain!.identifier = "titleBottom"
        
        for constraint in self.contentView.constraints {
            if constraint.identifier == nil {
                continue
            } else if constraint.identifier!.hasPrefix("note") {
                noteConstrains.append(constraint)
            } else if constraint.identifier == "naRight" {
                naRightConstrain = constraint
            }
        }
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func updateNoteLabel(){
        noteLabel.text = noteText
        
        let isNoteEmpty: Bool = (noteText == nil) || (noteText!.isEmpty)
        
        naLabel.hidden = !isNoteEmpty
        
        if isNoteEmpty {
            self.contentView.removeConstraints(noteConstrains)
            
            if noteLabel.superview != nil {
                noteLabel.removeFromSuperview()
            }
            
            self.contentView.addConstraint(titleConstrain!)
        } else {
            self.contentView.removeConstraint(titleConstrain!)
            if noteLabel.superview == nil {
                self.contentView.addSubview(noteLabel)
            }
            self.contentView.addConstraints(noteConstrains)
        }
        
    }

}
