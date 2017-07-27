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
        
        let distributionX = GKRandomDistribution(lowestValue: 0, highestValue: Int(size.width))
        let distributionY = GKRandomDistribution(lowestValue: 0, highestValue: Int(size.height))
        
        for _ in 0 ..< 1 {
            let name = String(Axioms.nextUniqueObjectID())
            archons[name] = Archon(scene: self, name: name, x: Double(distributionX.nextInt()), y: Double(distributionY.nextInt()))
        }
        
        physicsWorld.contactDelegate = self
    }
    
    override func update(_ currentTime: TimeInterval) {
        mannaGenerator.tick()
        
        for (_, archon) in archons { archon.tick() }
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        guard let nodeA = contact.bodyA.node, let nodeB = contact.bodyB.node else { return }
        
        enum ContactType { case None, SensorToManna, ArchonToManna }
        
        let normalize = { (nodeA : SKNode, bodyA : SKPhysicsBody, nodeB : SKNode, bodyB : SKPhysicsBody) ->
            (ContactType, String, String, SKPhysicsBody?) in
            if bodyA.categoryBitMask == Axioms.PhysicsBitmask.Sensor.rawValue &&
                bodyB.categoryBitMask == Axioms.PhysicsBitmask.Manna.rawValue {
                return (ContactType.SensorToManna, nodeA.name!, nodeB.name!, bodyB)
            }
            
            else if bodyB.categoryBitMask == Axioms.PhysicsBitmask.Sensor.rawValue &&
                bodyA.categoryBitMask == Axioms.PhysicsBitmask.Manna.rawValue {
                return (ContactType.SensorToManna, nodeB.name!, nodeA.name!, bodyA)
            }

            else if bodyA.categoryBitMask == Axioms.PhysicsBitmask.Archon.rawValue &&
                bodyB.categoryBitMask == Axioms.PhysicsBitmask.Manna.rawValue {
                return (ContactType.ArchonToManna, nodeA.name!, nodeB.name!, bodyB)
            }
                
            else if bodyB.categoryBitMask == Axioms.PhysicsBitmask.Archon.rawValue &&
                bodyA.categoryBitMask == Axioms.PhysicsBitmask.Manna.rawValue {
                return (ContactType.ArchonToManna, nodeB.name!, nodeA.name!, bodyA)
            }
            
            return (ContactType.None, "", "", nil)
        }
        
        let (contactType, archonName, mannaName, mannaBody) = normalize(nodeA, contact.bodyA, nodeB, contact.bodyB)
        
        switch(contactType) {
        case .None:
            fatalError("Contact between unknown nodes")
            
        case .SensorToManna:
            (archons[archonName])!.mannaSensed(mannaBody!)
            
        case .ArchonToManna:
            (archons[archonName])!.mannaTouched(mannaName)
            mannaGenerator.detectCollision(name: mannaName)
        }
    }
}
