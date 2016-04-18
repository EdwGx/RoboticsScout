//
//  TeamDetailViewController.swift
//  RoboticsScout
//
//  Created by Edward Guo on 2016-04-16.
//  Copyright © 2016 Peiliang Guo. All rights reserved.
//

import UIKit

class TeamDetailViewController: UITableViewController {
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        refreshData()
        
        extraNoteTextView.contentInset = UIEdgeInsets(top: -8, left: -4, bottom: 0, right: 0)
        
        tableView.estimatedRowHeight = 44.0
        tableView.rowHeight = UITableViewAutomaticDimension
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl?.addTarget(self, action: #selector(self.doRefresh(_:)), forControlEvents: .ValueChanged)
    }
    
    func refreshData() {
        guard let team = teamStat else { return }
        
        navigationItem.title = team.number
        
        teamNameLabel.text = team.teamName
        teamLocationLabel.text = team.location
        teamCountryLabel.text = team.country
        
        scoutingEntryCountLabel.text = "0 entries"
        
        if team.robotRank != nil && team.robotScore != nil {
            robotSkillsRankLabel.text = "#\(team.robotRank!)"
            robotSkillsScoreLabel.text = "\(team.robotScore!)"
        }
        
        if team.programmingRank != nil && team.programmingScore != nil {
            programmingSkillsRankLabel.text = "#\(team.programmingRank!)"
            programmingSkillsScoreLabel.text = "\(team.programmingScore!)"
        }
        
        
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
            if let fullName = WarriorServer.remoteFullName() {
                return "\(fullName) (UNSYNCABLE)"
            } else {
                return "You (UNSYNCABLE)"
            }
        default:
            return super.tableView(tableView, titleForHeaderInSection: section)
        }
    }
    
    func doRefresh(sender: UIRefreshControl) {
        print("Refresh")
        sender.endRefreshing()
    }
}
