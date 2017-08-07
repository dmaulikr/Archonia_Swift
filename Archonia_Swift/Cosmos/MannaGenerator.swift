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
    
    func getMannaParticle(_ name: String) -> MannaParticle {
        guard let p = manna[name] else { fatalError("wtf?") }
        return p
    }
}
