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
            do {
                let archon = try Archon(inScene: self)
                archons[archon.sprite.name!] = archon
            } catch BirthDefect.GeneValueLessThanZero {
                print("Birth defect")
            } catch {
                fatalError()
            }
        }
        
        physicsWorld.contactDelegate = self
        
        Cosmos.shared.momentOfCreation = false
    }
    
    override func mouseUp(with event: NSEvent) {
        scene!.isPaused = !scene!.isPaused
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        guard let nodeA = contact.bodyA.node, let nodeB = contact.bodyB.node else {
            fatalError("Unexpected 0")
        }
        
        if let archonA = archons[nodeA.name!] {
            if let archonB = archons[nodeB.name!] {
                if contact.bodyA.categoryBitMask == Axioms.PhysicsBitmask.Archon.rawValue {
                    archonA.contact(archonB)
                    archonB.contact(archonA)
                } else if contact.bodyA.categoryBitMask == Axioms.PhysicsBitmask.Sensor.rawValue {
                    archonA.sense(archonB)
                } else {
                    fatalError("Unexpected 1 \(nodeA.name!) - \(nodeB.name!)")
                }
            } else if let manna = mannaGenerator.manna[nodeB.name!] {
                if contact.bodyA.categoryBitMask == Axioms.PhysicsBitmask.Archon.rawValue {
                    archonA.engine.contactManna(manna)
                } else if contact.bodyA.categoryBitMask == Axioms.PhysicsBitmask.Sensor.rawValue {
                    archonA.engine.senseManna(manna)
                } else {
                    fatalError("Unexpected 2 \(nodeA.name!) - \(nodeB.name!)")
                }
            } else {
                fatalError("Unexpected 3")
            }
        } else if let manna = mannaGenerator.manna[nodeA.name!] {
            if let archon = archons[nodeB.name!] {
                if contact.bodyB.categoryBitMask == Axioms.PhysicsBitmask.Archon.rawValue {
                    archon.engine.contactManna(manna)
                } else if contact.bodyB.categoryBitMask == Axioms.PhysicsBitmask.Sensor.rawValue {
                    archon.engine.senseManna(manna)
                } else {
                    fatalError("Unexpected 4 \(nodeA.name!) - \(nodeB.name!)")
                }
            } else {
                fatalError("Unexpected 5")
            }
        } else {
            fatalError("Unexpected 6")
        }
    }
}
