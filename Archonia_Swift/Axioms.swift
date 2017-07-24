//
//  Axioms.swift
//  Archonia_Swift
//
//  Created by Rob Bishop on 7/24/17.
//  Copyright © 2017 Rob Bishop. All rights reserved.
//

import Foundation

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
}
