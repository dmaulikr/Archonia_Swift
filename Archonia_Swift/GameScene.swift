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
    var creepers = [String : Creeper]()
    var mannaGenerator : MannaGenerator!
    
    override func didMove(to view: SKView) {
        mannaGenerator = MannaGenerator(scene: self)
        
//        for _ in 0 ..< 1 {
//            let name = String(Axioms.nextUniqueObjectID())
//            archons[name] = Archon(scene: self, name: name)
//        }
        
        let texture = SKTexture(imageNamed: "creeper")

        for _ in 0 ..< 250 {
            let creeper = Creeper(inScene: self, inTexture: texture)
            creepers[creeper.sprite.name!] = creeper
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
            if mannaGenerator.detectCollision(name: mannaName) {
                (archons[archonName])!.mannaTouched(mannaName)
            }
        }
    }
}
