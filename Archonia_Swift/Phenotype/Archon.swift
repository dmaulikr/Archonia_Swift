//
//  Archon.swift
//  Archonia_Swift
//
//  Created by Rob Bishop on 8/2/17.
//  Copyright © 2017 Rob Bishop. All rights reserved.
//

import CoreGraphics
import Foundation
import GameplayKit
import SpriteKit

class Archon: Edible {
    var engine: Engine! = nil
    let genome: Genome
    let scene: GameScene
    let sprite: SKSpriteNode
    
    static var texturesLoaded = false
    static var spriteTexture: SKTexture!
    static var buttonTexture: SKTexture!
    
    init(inScene: GameScene) throws {
        Archon.loadTextures()
        
        genome = try Genome(inheritFrom: Genome.primordialGenome)
        
        scene = inScene
        
        sprite = SKSpriteNode(texture: Archon.spriteTexture)
        sprite.name = String(Axioms.nextUniqueObjectID())
        sprite.position = CGPoint.randomPoint(range: inScene.size)
        let hue = CGFloat(Axioms.randomFloat(CGFloat(0), CGFloat(360)))
        sprite.color = NSColor(hue: hue / 360, saturation: 1, brightness: 0.6, alpha: 1)
        sprite.colorBlendFactor = 1
        sprite.scale(to: sprite.size * 0.75)

        scene.addChild(sprite)

        let physicsBody = SKPhysicsBody(circleOfRadius: sprite.size.width / 2)
        physicsBody.contactTestBitMask = Axioms.PhysicsBitmask.Archon.rawValue | Axioms.PhysicsBitmask.Manna.rawValue
        physicsBody.collisionBitMask = 0
        physicsBody.categoryBitMask = Axioms.PhysicsBitmask.Archon.rawValue
        sprite.physicsBody = physicsBody
        
        engine = Engine(self)

        let sensorBody = setupButton()
        
        let connectionPoint = sprite.convert(CGPoint.zero, to: scene)
        let joint = SKPhysicsJointFixed.joint(withBodyA: physicsBody, bodyB: sensorBody, anchor: connectionPoint)
        scene.physicsWorld.add(joint)
        
        engine.launch()
    }
    
    static func isArchonBody(_ physicsBody: SKPhysicsBody) -> Bool {
        return (physicsBody.categoryBitMask & Axioms.PhysicsBitmask.Archon.rawValue) != 0
    }
    
    static func isArchonSensor(_ physicsBody: SKPhysicsBody) -> Bool {
        return (physicsBody.categoryBitMask & Axioms.PhysicsBitmask.Sensor.rawValue) != 0
    }
    
    static private func loadTextures() {
        guard !Archon.texturesLoaded else { return }
        
        Archon.spriteTexture = SKTexture(imageNamed: "archon15")
        Archon.buttonTexture = SKTexture(imageNamed: "button6")
        
        Archon.texturesLoaded = true
    }
    
    private func setupButton() -> SKPhysicsBody {
        let button = SKSpriteNode(texture: Archon.buttonTexture)
        button.zPosition = 1
        button.colorBlendFactor = 1
        button.color = .white
        sprite.addChild(button)
        
        let sensorBody = SKPhysicsBody(circleOfRadius: sprite.size.width * 2)
        sensorBody.contactTestBitMask = Axioms.PhysicsBitmask.Archon.rawValue | Axioms.PhysicsBitmask.Manna.rawValue
        sensorBody.collisionBitMask = 0
        sensorBody.categoryBitMask = Axioms.PhysicsBitmask.Sensor.rawValue
        
        button.physicsBody = sensorBody
        button.name = sprite.name!
        
        return sensorBody
    }
    
    func drawDebugLine(from: CGPoint, to: CGPoint, color: NSColor) {
        let linePath = CGMutablePath()
        linePath.move(to: from)
        linePath.addLine(to: to)
        
        let line = SKShapeNode(path: linePath)
        line.fillColor = color
        line.strokeColor = color
        line.alpha = 0
        scene.addChild(line)
        
        let fadeIn = SKAction.fadeIn(withDuration: 1)
        let fadeOut = SKAction.fadeOut(withDuration: 5)
        let remove = SKAction.removeFromParent()
        let sequence = SKAction.sequence([fadeIn, fadeOut, remove])
        line.run(sequence)
    }
}
