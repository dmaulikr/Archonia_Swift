//
//  GameScene.swift
//  Archonia_Swift
//
//  Created by Rob Bishop on 7/24/17.
//  Copyright © 2017 Rob Bishop. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    var archons = [String : Archon]()
    var mannaGenerator : MannaGenerator!
    
    override func didMove(to view: SKView) {
        mannaGenerator = MannaGenerator(scene: self)
        
        for _ in 0 ..< 25 {
            let archon = Archon(inScene: self)
            archons[archon.sprite.name!] = archon
        }
        
        physicsWorld.contactDelegate = self
        
        Cosmos.shared.momentOfCreation = false
    }
    
    override func update(_ currentTime: TimeInterval) {
        mannaGenerator.tick()
    }
}
