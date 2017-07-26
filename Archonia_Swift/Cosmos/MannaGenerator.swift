//
//  MannaGenerator.swift
//  Archonia_Swift
//
//  Created by Rob Bishop on 7/24/17.
//  Copyright © 2017 Rob Bishop. All rights reserved.
//

import Foundation
import GameplayKit

class MannaGenerator {
    var manna = [String : MannaParticle]()
    var eatenManna = Set<String>()
    
    init(scene inScene: GameScene) {
        for _ in 0 ..< 500 {
            let name = String(Axioms.nextUniqueObjectID())

            manna[name] = MannaParticle(scene: inScene, name: name)
        }
    }
    
    func detectCollision(name inName : String) {
        guard let _ = manna[inName] else { fatalError("Manna not found?") }
        eatenManna.insert(inName)
    }
    
    func tick() {
        for name in eatenManna {
            guard let m = manna[name] else { fatalError("Manna not found?") }
            m.collisionDetected()
        }
        
        eatenManna.removeAll()
    }
}
