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
    var mannaGenerator : MannaGenerator?
    
    override func didMove(to view: SKView) {
        mannaGenerator = MannaGenerator(scene: self)
        
        let distributionX = GKRandomDistribution(lowestValue: 0, highestValue: Int(size.width))
        let distributionY = GKRandomDistribution(lowestValue: 0, highestValue: Int(size.height))
        
        for _ in 0 ..< 25 {
            let name = String(Axioms.nextUniqueObjectID())
            archons[name] = Archon(scene: self, name: name, x: Double(distributionX.nextInt()), y: Double(distributionY.nextInt()))
        }
        
        physicsWorld.contactDelegate = self
    }
    
    override func update(_ currentTime: TimeInterval) {
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        let show = { (node : SKNode, thisBody : SKPhysicsBody, otherBody : SKPhysicsBody) in
            guard let name = node.name else { fatalError("Contact with unnamed node?") }
            
            if let archon = self.archons[name] {
                if thisBody.categoryBitMask == Axioms.PhysicsBitmask.Sensor.rawValue {
                    archon.mannaSensed(otherBody);
                }
            } else if otherBody.categoryBitMask == Axioms.PhysicsBitmask.Archon.rawValue {
                self.mannaGenerator?.detectCollision(name: name);
            }
        }
        
        if let nodeA = contact.bodyA.node, let nodeB = contact.bodyB.node {
            show(nodeA, contact.bodyA, contact.bodyB);
            show(nodeB, contact.bodyB, contact.bodyA);
//            print("Node " + nodeA.name! + " contacted node " + nodeB.name!)
        }
    }
}
