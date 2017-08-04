//
//  Axioms.swift
//  Archonia_Swift
//
//  Created by Rob Bishop on 7/24/17.
//  Copyright © 2017 Rob Bishop. All rights reserved.
//

import Foundation
import GameplayKit

struct Axioms {
    static var uniqueObjectID = 0
    
    enum PhysicsBitmask: UInt32 {
        case Archon = 1
        case Sensor = 2
        case Manna = 4
    }
    
    static func nextUniqueObjectID() -> Int {
        uniqueObjectID = uniqueObjectID &+ 1
        return uniqueObjectID
    }
    
    static func randomDouble(_ min: Double, _ max: Double) -> Double {
        return ((max - min) * Double(GKRandomDistribution(lowestValue: 0, highestValue: 99).nextUniform())) + min
    }
    
    static func randomFloat(_ min: Float, _ max: Float) -> Float {
        return ((max - min) * GKRandomDistribution(lowestValue: 0, highestValue: 99).nextUniform()) + min
    }
    
    static func randomFloat(_ min: CGFloat, _ max: CGFloat) -> Float {
        return (Float(max - min) * GKRandomDistribution(lowestValue: 0, highestValue: 99).nextUniform()) + Float(min)
    }
    
    static func randomInt(_ min: Int, _ max: Int) -> Int {
        return GKRandomDistribution(lowestValue: min, highestValue: max - 1).nextInt()
    }
    
    static func randomBool() -> Bool {
        return GKRandomDistribution(lowestValue: 0, highestValue: 1).nextBool()
    }
}
