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
    
    func didEnd(_ contact: SKPhysicsContact) {
        guard let nodeA = contact.bodyA.node, let nodeB = contact.bodyB.node else {
            fatalError("Unexpected 0")
        }
        
        if let archonA = archons[nodeA.name!], let archonB = archons[nodeB.name!] {
            archonA.engine.unsenseArchon(archonB)
            archonB.engine.unsenseArchon(archonA)
        }
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        guard let nodeA = contact.bodyA.node, let nodeB = contact.bodyB.node else {
            fatalError("Unexpected 0")
        }
        
        if let archonA = archons[nodeA.name!] {
            if let archonB = archons[nodeB.name!] {
                if Archon.isArchonSensor(contact.bodyA) && Archon.isArchonSensor(contact.bodyB) {
                    // Do nothing for sensor-sensor contact
                } else if Archon.isArchonBody(contact.bodyA) && Archon.isArchonBody(contact.bodyB) {
                    // Body-body contact is complicated
                } else if Archon.isArchonSensor(contact.bodyA) {
                    archonA.engine.senseArchon(archonB)
                } else if Archon.isArchonBody(contact.bodyA) {
                    archonB.engine.senseArchon(archonA)
                } else {
                    fatalError("Unexpected 1 \(nodeA.name!) - \(nodeB.name!)")
                }
            } else if let manna = mannaGenerator.manna[nodeB.name!] {
                if Archon.isArchonBody(contact.bodyA) {
                    archonA.engine.contactManna(manna)
                } else if Archon.isArchonSensor(contact.bodyA) {
                    archonA.engine.senseManna(manna)
                } else {
                    fatalError("Unexpected 2 \(nodeA.name!) - \(nodeB.name!)")
                }
            } else {
                fatalError("Unexpected 3")
            }
        } else if let manna = mannaGenerator.manna[nodeA.name!] {
            if let archon = archons[nodeB.name!] {
                if Archon.isArchonBody(contact.bodyB) {
                    archon.engine.contactManna(manna)
                } else if Archon.isArchonSensor(contact.bodyB) {
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
