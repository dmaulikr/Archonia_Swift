//
//  GameScene.swift
//  Archonia_Swift
//
//  Created by Rob Bishop on 7/24/17.
//  Copyright © 2017 Rob Bishop. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    var archon: Archon!
    
    override func didMove(to view: SKView) {
        let distributionX = GKRandomDistribution(lowestValue: 0, highestValue: Int(size.width));
        let distributionY = GKRandomDistribution(lowestValue: 0, highestValue: Int(size.height));
        
        archon = Archon(scene: self, x: Double(distributionX.nextInt()), y: Double(distributionY.nextInt()));
    }
    
    override func update(_ currentTime: TimeInterval) {
    }
}
