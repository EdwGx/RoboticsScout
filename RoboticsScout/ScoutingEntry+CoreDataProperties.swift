//
//  ScoutingEntry+CoreDataProperties.swift
//  RoboticsScout
//
//  Created by Edward Guo on 2016-04-17.
//  Copyright © 2016 Peiliang Guo. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension ScoutingEntry {

    @NSManaged var rating: NSNumber?
    @NSManaged var extraNote: String?
    @NSManaged var identifier: NSNumber?
    @NSManaged var driveMotors: NSNumber?
    @NSManaged var driveMotorType: String?
    @NSManaged var driveWheels: NSNumber?
    @NSManaged var driveWheelType: String?
    @NSManaged var driveConfiguration: String?
    @NSManaged var driveClearance: String?
    @NSManaged var shooterType: String?
    @NSManaged var shooterMotors: NSNumber?
    @NSManaged var shooterRPM: NSNumber?
    @NSManaged var intakeType: String?
    @NSManaged var intakeFlipCapacity: String?
    @NSManaged var lift: String?
    @NSManaged var liftMotors: NSNumber?
    @NSManaged var liftElevation: String?
    @NSManaged var liftWorks: String?
    @NSManaged var driverConsistency: String?
    @NSManaged var driverIntelligence: String?
    @NSManaged var preloadsCapacity: String?
    @NSManaged var shooterConsistency: String?
    @NSManaged var shooterRange: String?
    @NSManaged var autonomousStrategy: String?
    @NSManaged var autonomousPreloadPoints: NSNumber?
    @NSManaged var autonomousFieldPoints: NSNumber?
    @NSManaged var autonomousReliability: String?
    @NSManaged var driveStalling: String?
    @NSManaged var connectionIssues: String?
    @NSManaged var changed: NSNumber?
    @NSManaged var memberName: String?
    @NSManaged var selfEntry: NSNumber?
    @NSManaged var teamStat: TeamStat?

}
