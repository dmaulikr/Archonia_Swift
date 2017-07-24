//
//  MannaParticle.swift
//  Archonia_Swift
//
//  Created by Rob Bishop on 7/24/17.
//  Copyright © 2017 Rob Bishop. All rights reserved.
//

import Foundation
import SpriteKit

class MannaParticle {
    var sprite: SKShapeNode
    
    init(scene inScene : GameScene, name inName : String, x inX : Double, y inY : Double) {
        sprite = SKShapeNode(circleOfRadius: 0.5);
        sprite.position = CGPoint(x: inX, y: inY);
        sprite.fillColor = .white
        
        sprite.name = inName
        
        let physicsBody = SKPhysicsBody(circleOfRadius: 0.5)
        physicsBody.contactTestBitMask = Axioms.PhysicsBitmask.Archon.rawValue | Axioms.PhysicsBitmask.Sensor.rawValue
        physicsBody.collisionBitMask = 0
        physicsBody.categoryBitMask = Axioms.PhysicsBitmask.Manna.rawValue
        sprite.physicsBody = physicsBody
        
        inScene.addChild(sprite)
    }
    
    func collisionDetected() {
        sprite.removeFromParent()
    }
}