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
    var timer: Timer? = nil
    var isCoherent = false
    
    init(scene inScene : GameScene, name inName : String) {
        sprite = SKSpriteNode(imageNamed: "archon")
        sprite.scale(to: CGSize(width: 1.75, height: 1.75))
        sprite.colorBlendFactor = 1
        
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
    
    @objc func cohere() {
        let p = GKRandomDistribution(lowestValue: 0, highestValue: Int(limitPoint.width))
        sprite.position = CGPoint(x: p.nextInt(), y: p.nextInt())

        let q = GKRandomDistribution(lowestValue: 10000, highestValue: 20000)
        let s = Float(q.nextInt())
        let r = TimeInterval(s / 1000.0)
        timer = Timer.scheduledTimer(timeInterval: r, target: self, selector: #selector(expire), userInfo: nil, repeats: false)
        
        sprite.color = .white
        
        isCoherent = true
    }
    
    func decohere() {
        guard isCoherent else { return }
        
        if let t = timer { t.invalidate() }

        sprite.position = CGPoint(x: -100, y: -100)
        sprite.color = .red
        
        let q = GKRandomDistribution(lowestValue: 500, highestValue: 2000)
        let s = Float(q.nextInt())
        let r = TimeInterval(s / 1000.0)
        timer = Timer.scheduledTimer(timeInterval: r, target: self, selector: #selector(cohere), userInfo: nil, repeats: false)
        
        isCoherent = false
    }
    
    @objc func expire() {
        decohere()
    }
    
    func collisionDetected() {
        decohere()
    }
}
