//
//  ScoutingEntry+CoreDataProperties.swift
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

extension ScoutingEntry {

    @NSManaged var autonomousFieldPoints: NSNumber?
    @NSManaged var autonomousPreloadPoints: NSNumber?
    @NSManaged var autonomousReliability: String?
    @NSManaged var autonomousStrategy: String?
    @NSManaged var changed: NSNumber?
    @NSManaged var connectionIssues: String?
    @NSManaged var driveClearance: String?
    @NSManaged var driveConfiguration: String?
    @NSManaged var driveMotors: NSNumber?
    @NSManaged var driveMotorType: String?
    @NSManaged var driverConsistency: String?
    @NSManaged var driverIntelligence: String?
    @NSManaged var driveStalling: String?
    @NSManaged var driveWheels: NSNumber?
    @NSManaged var driveWheelType: String?
    @NSManaged var extraNote: String?
    @NSManaged var identifier: NSNumber?
    @NSManaged var intakeFlipCapacity: String?
    @NSManaged var intakeMotors: NSNumber?
    @NSManaged var intakeMotorType: String?
    @NSManaged var intakeType: String?
    @NSManaged var lift: String?
    @NSManaged var liftElevation: String?
    @NSManaged var liftMotors: NSNumber?
    @NSManaged var liftWorks: String?
    @NSManaged var memberName: String?
    @NSManaged var newEntry: NSNumber?
    @NSManaged var preloadsCapacity: String?
    @NSManaged var rating: NSNumber?
    @NSManaged var selfEntry: NSNumber?
    @NSManaged var shooterConsistency: String?
    @NSManaged var shooterMotors: NSNumber?
    @NSManaged var shooterRange: String?
    @NSManaged var shooterRPM: NSNumber?
    @NSManaged var shooterType: String?
    @NSManaged var teamStat: TeamStat?

}
