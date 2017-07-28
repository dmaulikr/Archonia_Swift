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
    
    func detectCollision(name inName : String) -> Bool {
        guard manna[inName] != nil else { fatalError("Manna not found?") }
        
        if eatenManna.contains(inName) { return false }
        else { eatenManna.insert(inName); return true }
    }
    
    func tick() {
        for name in eatenManna {
            guard let m = manna[name] else { fatalError("Manna not found?") }
            m.collisionDetected()
        }
        
        eatenManna.removeAll()
    }
    
    func getMannaParticle(_ name: String) -> MannaParticle {
        guard let p = manna[name] else { fatalError("wtf?") }
        return p
    }
}
