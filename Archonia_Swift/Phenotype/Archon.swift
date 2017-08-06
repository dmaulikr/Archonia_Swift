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

class Archon {
    var forager: Forager! = nil
    let genome: Genome
    let scene: GameScene
    var sensedManna = [(MannaParticle, CGPoint)]()
    var sensedMannaIndex = 0
    let sprite: SKSpriteNode
    var state: State = .Foraging
    
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
        physicsBody.collisionBitMask = Axioms.PhysicsBitmask.Archon.rawValue
        physicsBody.categoryBitMask = Axioms.PhysicsBitmask.Archon.rawValue
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
    
    // Should be private, but Swift 3 won't let us access it from the extension;
    // the Swift 4 doc suggests that this will be fixed soon
    func forage(firstTime: Bool) {
        var actions = [SKAction]()
        
        if firstTime { forager = Forager(self) }
        else { actions.append(SKAction.wait(forDuration: 1.5, withRange: 3)) }
        
        forager.tick()
        
        let p = sprite.position
        let distance = Double(forager.targetPosition.getDistanceTo(p))
        let speed = (genome.genes["speed"]! as! ScalarGene).value
        let duration = distance / speed
        
        let move = SKAction.move(to: forager.targetPosition, duration: duration)
        let next = SKAction.run { self.forage(firstTime: false) }
        
        let movementSequence = SKAction.sequence([move, next])
        
        actions.append(movementSequence)
        
        sprite.run(SKAction.sequence(actions))
        
        state = .Foraging
        
//        drawDebugLine(from: sprite.position, to: forager.targetPosition, color: .green)
    }
    
    private func setupButton() -> SKPhysicsBody {
        let button = SKSpriteNode(texture: Archon.buttonTexture)
        button.zPosition = 1
        button.colorBlendFactor = 1
        button.color = .white
        sprite.addChild(button)
        
        let sensorBody = SKPhysicsBody(circleOfRadius: sprite.size.width * 2)
        sensorBody.contactTestBitMask = Axioms.PhysicsBitmask.Manna.rawValue
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

// Sense & contact manna & other archons

extension Archon {
    enum State { case Foraging, PursuingManna }
    
    func sense(_ otherArchon: Archon) {
//        print("Archon \(sprite.name!) sensing archon \(otherArchon.sprite.name!)")
    }
    
    func sense(_ mannaParticle: MannaParticle) {
//        print("Archon \(sprite.name!) sensing manna \(mannaParticle.sprite.name!)")
        
        if state == .Foraging { sprite.removeAllActions(); state = .PursuingManna }
        
        // If we don't already know about this manna particle, append it to
        // our array of particles to pursue
        if sensedManna.index(where: { (alreadySensed, _) in
            return alreadySensed.sprite.name! == mannaParticle.sprite.name!
        }) == nil {
            sensedManna.append((mannaParticle, mannaParticle.sprite.position))
            
//            drawDebugLine(from: sprite.position, to: mannaParticle.sprite.position, color: .white)
        }
        
        // If we're not already pursuing, start another pursuit action
        if !sprite.hasActions() { pursueManna() }
    }

    func contact(_ otherArchon: Archon) {
//        print("Archon \(sprite.name!) contacting archon \(otherArchon.sprite.name!)")
    }
    
    func contact(_ mannaParticle: MannaParticle) {
//        print("Archon \(sprite.name!) contacting manna \(mannaParticle.sprite.name!)")
        mannaParticle.decohere()
    }
    
    func pursueManna() {
        if sensedMannaIndex < sensedManna.count {
            var actions = [SKAction]()
            let (mannaParticle, lastKnownPosition) = sensedManna[sensedMannaIndex]
            let currentPosition = mannaParticle.sprite.position
            
            sensedMannaIndex += 1   // For next time
            
            // That is, if the manna we sensed hasn't been eaten and
            // reincarnated somewhere else
            if currentPosition == lastKnownPosition {
                let distance = Double(currentPosition.getDistanceTo(sprite.position))
                let speed = (genome.genes["speed"]! as! ScalarGene).value
                let duration = distance / speed

                let move = SKAction.move(to: currentPosition, duration: duration)
                actions.append(move)
            }
            
            let next = SKAction.run { self.pursueManna() }
            actions.append(next)
            
            sprite.run(SKAction.sequence(actions))
        } else {
            sensedMannaIndex = 0
            sensedManna.removeAll(keepingCapacity: true)
            
            sprite.run(SKAction.run({ self.forage(firstTime: true) }))
        }
    }
}
