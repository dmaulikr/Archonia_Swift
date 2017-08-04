//
//  Archon.swift
//  Archonia_Swift
//
//  Created by Rob Bishop on 8/2/17.
//  Copyright © 2017 Rob Bishop. All rights reserved.
//

import Foundation
import GameplayKit
import SpriteKit

class Archon {
    var forager: Forager! = nil
    let scene: GameScene
    let sprite: SKSpriteNode
    
    static var texturesLoaded = false
    static var spriteTexture: SKTexture!
    static var buttonTexture: SKTexture!
    
    init(inScene: GameScene) {
        Archon.loadTextures()
        
        scene = inScene
        
        sprite = SKSpriteNode(texture: Archon.spriteTexture)
        sprite.name = String(Axioms.nextUniqueObjectID())
        sprite.position = CGPoint.randomPoint(range: inScene.size)
        sprite.color = NSColor(hue: 240 / 360, saturation: 1, brightness: 0.6, alpha: 1)
        sprite.colorBlendFactor = 1

        scene.addChild(sprite)

        let physicsBody = SKPhysicsBody(circleOfRadius: sprite.size.width / 2)
        physicsBody.contactTestBitMask = 0//Axioms.PhysicsBitmask.Archon.rawValue | Axioms.PhysicsBitmask.Manna.rawValue
        physicsBody.collisionBitMask = 0//Axioms.PhysicsBitmask.Archon.rawValue
        physicsBody.categoryBitMask = 0//Axioms.PhysicsBitmask.Archon.rawValue
        sprite.physicsBody = physicsBody

        let sensorBody = setupButton()
        
        let connectionPoint = sprite.convert(CGPoint.zero, to: scene)
        let joint = SKPhysicsJointFixed.joint(withBodyA: physicsBody, bodyB: sensorBody, anchor: connectionPoint)
        scene.physicsWorld.add(joint)
        
        forage(firstTime: true)
    }
    
    static private func loadTextures() {
        guard !Archon.texturesLoaded else { return }
        
        Archon.spriteTexture = SKTexture(imageNamed: "archon15")
        Archon.buttonTexture = SKTexture(imageNamed: "button6")
        
        Archon.texturesLoaded = true
    }
    
    private func forage(firstTime: Bool) {
        var actions = [SKAction]()
        
        if firstTime { forager = Forager(self) }
        else { actions.append(SKAction.wait(forDuration: 1.5, withRange: 3)) }
        
        forager.tick()
        
        let distance = Double(forager.targetPosition.getDistanceTo(sprite.position))
        let speed = 50.0
        
        let move = SKAction.move(to: forager.targetPosition, duration: distance / speed)
        
        let next = SKAction.run {
            self.sprite.removeAllActions()
            self.forage(firstTime: false)
        }
        
        let movementSequence = SKAction.sequence([move, next])
        
        actions.append(movementSequence)
        
        sprite.run(SKAction.sequence(actions))
    }
    
    private func setupButton() -> SKPhysicsBody {
        let button = SKSpriteNode(texture: Archon.buttonTexture)
        button.zPosition = 1
        button.colorBlendFactor = 1
        button.color = .white
        sprite.addChild(button)
        
        let sensorBody = SKPhysicsBody(circleOfRadius: sprite.size.width)
        sensorBody.contactTestBitMask = 0//Axioms.PhysicsBitmask.Manna.rawValue
        sensorBody.collisionBitMask = 0
        sensorBody.categoryBitMask = 0//Axioms.PhysicsBitmask.Sensor.rawValue
        
        button.physicsBody = sensorBody
        button.name = sprite.name!
        
        return sensorBody
    }
}
