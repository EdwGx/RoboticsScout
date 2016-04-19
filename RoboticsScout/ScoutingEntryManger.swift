//
//  ScoutingEntryManger.swift
//  RoboticsScout
//
//  Created by Edward Guo on 2016-04-17.
//  Copyright © 2016 Peiliang Guo. All rights reserved.
//

import UIKit

class ScoutingEntryManger: NSObject {
    
    var attributes = [
        "rating",
        "extraNote",
        
        "driveMotors",
        "driveMotorType",
        "driveWheels",
        "driveWheelType",
        "driveConfiguration",
        "driveClearance",
        
        "shooterType",
        "shooterMotors",
        "shooterRPM",
        
        "intakeType",
        "intakeMotors",
        "intakeMotorType",
        "intakeFlipCapacity",
        
        "lift",
        "liftMotors",
        "liftElevation",
        "liftWorks",
        
        "driverConsistency",
        "driverIntelligence",
        
        "preloadsCapacity",
        
        "shooterConsistency",
        "shooterRange",
        
        "autonomousStrategy",
        "autonomousPreloadPoints",
        "autonomousFieldPoints",
        "autonomousReliability",
        
        "driveStalling",
        "connectionIssues"
    ]
    
    let attributeOptions: [String:[String]] = [
        "driveMotorType":["Torque", "Turbo", "Speed"],
        "driveWheelType":["Traction", "Omni", "Mecanum"],
        "driveConfiguration":["Regular", "Holonomic", "Tank"],
        "driveClearance":["Yes", "No"],
        
        "shooterType":["Linear Puncher", "Single Flywheel", "Double Flywheel", "Catapult"],
        
        "intakeType":["Universal", "Rollers with Flaps"],
        "intakeMotorType":["Fast", "Normal", "Slow"],
        "intakeFlipCapacity":[],
        
        "lift":["Yes", "No"],
        "liftElevation":["High", "Low"],
        "liftWorks":["Yes", "No"],
        
        "driverConsistency":["Prefect", "Good", "Normal", "Bad"],
        "driverIntelligence":["Jesus", "Smart", "Okay", "Bad"],
        
        "preloadsCapacity":[],
        
        "shooterConsistency":["Prefect", "Good", "Normal", "Bad"],
        "shooterRange":["Long", "Mid", "Close", "Mix"],
        
        "autonomousStrategy":["Field", "Preload", "Mix", "None"],
        "autonomousReliability":["Prefect", "Good", "Normal", "Bad"],
        
        "driveStalling":["High", "Low"],
        "connectionIssues":["Yes", "No"]
                            ]
    
    var displayNames = [
        "Rating",
        "Extra Note",
        
        "Drive Motors",
        "Drive Motor Type",
        "Drive Wheels",
        "Drive Wheel Type",
        "Drive Configuration",
        "Drive Clearance",
        
        "Shooter Type",
        "Shooter Motors",
        "Shooter RPM",
        
        "Intake Type",
        "Intake Motors",
        "Intake Motor Type",
        "Intake Flip Capacity",
        
        "Lift",
        "Lift Motors",
        "Lift Elevation",
        "Lift Works",
        
        "Driver Consistency",
        "Driver Intelligence",
        
        "Preloads Capacity",
        
        "Shooter Consistency",
        "Shooter Range",
        
        "Autonomous Strategy",
        "Autonomous Preload Points",
        "Autonomous Field Points",
        "Autonomous Reliability",
        
        "Drive Stalling",
        "Connection Issues"
    ]
    
}
