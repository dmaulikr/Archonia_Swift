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

class MannaParticle: Edible {
    var incarnationNumber: Int = 0
    var isBeingEaten = false
    var isCoherent = false
    let limitPoint: CGSize
    var sprite: SKSpriteNode
    
    init(scene inScene : GameScene, name inName : String) {
        sprite = SKSpriteNode(imageNamed: "manna2")
        sprite.colorBlendFactor = 1
        sprite.color = .white
        sprite.name = inName
        
        let physicsBody = SKPhysicsBody(rectangleOf: sprite.size)
        physicsBody.contactTestBitMask = 0
        physicsBody.collisionBitMask = 0
        physicsBody.categoryBitMask = Axioms.PhysicsBitmask.Manna.rawValue
        sprite.physicsBody = physicsBody
        
        inScene.addChild(sprite)
        limitPoint = inScene.size
        
        sprite.isUserInteractionEnabled = true

        cohere()
    }
    
    func beEaten() {
        guard !isBeingEaten else { return }
        
        isBeingEaten = true
        decohere()
    }
    
    func cohere() {
        isCoherent = true
        isBeingEaten = false

        sprite.position = CGPoint.randomPoint(range: limitPoint)

        let q = GKRandomDistribution(lowestValue: 10000, highestValue: 20000)
        let r = Float(q.nextInt())
        let s = TimeInterval(r / 1000.0)
        
        let w = SKAction.wait(forDuration: s)
        let d = SKAction.run({self.decohere()})
        let g = SKAction.sequence([w, d])
        
        sprite.removeAllActions()
        sprite.run(g)

        incarnationNumber = incarnationNumber &+ 1
    }
    
    func decohere() {
        guard isCoherent else { return }

        isCoherent = false
        
        let q = GKRandomDistribution(lowestValue: 500, highestValue: 2000)
        let r = Float(q.nextInt())
        let s = TimeInterval(r / 1000.0)
        
        let p = SKAction.run({self.sprite.position = CGPoint(x: -100, y: -100)})
        let w = SKAction.wait(forDuration: s)
        let d = SKAction.run({self.cohere()})
        let g = SKAction.sequence([p, w, d])
        
        sprite.removeAllActions()
        sprite.run(g)
    }
}
