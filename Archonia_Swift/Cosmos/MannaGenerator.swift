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
    
    init(scene inScene: GameScene) {
        let size = inScene.size
        let distributionX = GKRandomDistribution(lowestValue: Int(0), highestValue: Int(size.width));
        let distributionY = GKRandomDistribution(lowestValue: Int(0), highestValue: Int(size.height));
        
        for _ in 0 ..< 500 {
            let x = Double(distributionX.nextInt())
            let y = Double(distributionY.nextInt())
            let name = String(Axioms.nextUniqueObjectID())

            manna[name] = MannaParticle(scene: inScene, name: name, x: x, y: y)
        }
    }
    
    func detectCollision(name inName : String) {
        guard let m = manna[inName] else { fatalError("Manna not found?") }
        m.collisionDetected()
        manna.removeValue(forKey: inName)
    }
}
