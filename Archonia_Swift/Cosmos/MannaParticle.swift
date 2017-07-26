//
//  MannaParticle.swift
//  Archonia_Swift
//
//  Created by Rob Bishop on 7/24/17.
//  Copyright © 2017 Rob Bishop. All rights reserved.
//

import Foundation
import GameplayKit
import SpriteKit

class MannaParticle {
    var sprite: SKSpriteNode
    let limitPoint: CGSize
    var isCoherent = false
    
    init(scene inScene : GameScene, name inName : String) {
        sprite = SKSpriteNode(imageNamed: "archon")
        sprite.scale(to: CGSize(width: 1.75, height: 1.75))
        sprite.colorBlendFactor = 1
        sprite.color = .white
        sprite.name = inName
        
        let physicsBody = SKPhysicsBody(circleOfRadius: 0.5)
        physicsBody.contactTestBitMask = Axioms.PhysicsBitmask.Archon.rawValue | Axioms.PhysicsBitmask.Sensor.rawValue
        physicsBody.collisionBitMask = 0
        physicsBody.categoryBitMask = Axioms.PhysicsBitmask.Manna.rawValue
        sprite.physicsBody = physicsBody
        
        inScene.addChild(sprite)
        limitPoint = inScene.size
        
        cohere()
    }
    
    func cohere() {
        isCoherent = true

        let p = GKRandomDistribution(lowestValue: 0, highestValue: Int(limitPoint.width))
        sprite.position = CGPoint(x: p.nextInt(), y: p.nextInt())

        let q = GKRandomDistribution(lowestValue: 10000, highestValue: 20000)
        let r = Float(q.nextInt())
        let s = TimeInterval(r / 1000.0)
        
        let w = SKAction.wait(forDuration: s)
        let d = SKAction.run({self.decohere()})
        let g = SKAction.sequence([w, d])
        
        sprite.removeAllActions()
        sprite.run(g)
    }
    
    func decohere() {
        guard isCoherent else { return }

        isCoherent = false
        
        sprite.position = CGPoint(x: -100, y: -100)
        
        let q = GKRandomDistribution(lowestValue: 500, highestValue: 2000)
        let r = Float(q.nextInt())
        let s = TimeInterval(r / 1000.0)
        
        let w = SKAction.wait(forDuration: s)
        let d = SKAction.run({self.cohere()})
        let g = SKAction.sequence([w, d])
        
        sprite.removeAllActions()
        sprite.run(g)
    }
    
    func expire() {
        decohere()
    }
    
    func collisionDetected() {
        decohere()
    }
}
