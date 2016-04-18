//
//  ScoutingEntryManger.swift
//  RoboticsScout
//
//  Created by Edward Guo on 2016-04-17.
//  Copyright © 2016 Peiliang Guo. All rights reserved.
//

import UIKit

class ScoutingEntryManger: NSObject {
    var stringAttributes = [
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
        "driverIntelligence":["Jesus", "Smart", "Okay", "Vidur"],
        
        "preloads_capacity":[],
        
        "shooterConsistency":["Prefect", "Good", "Normal", "Bad"],
        "shooterRange":["Long", "Mid", "Close", "Mix"],
        
        "autonomousStrategy":["Field", "Preload", "Mix", "None"],
        "autonomousReliability":["Prefect", "Good", "Normal", "Bad"],
        
        "driveStalling":["High", "Low"],
        "connectionIssues":["Yes", "No"]
                            ]
    
    
}
