//
//  Archon.swift
//  Archonia_Swift
//
//  Created by Rob Bishop on 7/24/17.
//  Copyright © 2017 Rob Bishop. All rights reserved.
//

import Foundation
import GameplayKit
import SpriteKit

class Archon {
    var sprite : SKSpriteNode
    var grid = [SKSpriteNode]()
    var forager : Forager?
    let showForagingDebug = false
    var isForaging = false
    var isPursuingManna = false
    var isEatingManna = false
    var mannaToPursue: SKPhysicsBody?
    var mannaToEat = Set<String>()
    let foragingDelay: SKAction
    let mannaGenerator: MannaGenerator
    
    init(scene inScene : GameScene, name inName : String, x inX : Double, y inY : Double) {
        mannaGenerator = inScene.mannaGenerator!
        
        sprite = SKSpriteNode(imageNamed: "archon15")
        sprite.position = CGPoint(x: inX, y: inY);
        sprite.color = NSColor(hue: 240 / 360, saturation: 1, brightness: 0.6, alpha: 1)
        sprite.colorBlendFactor = 1
        
        inScene.addChild(sprite)
        
        let physicsBody = SKPhysicsBody(circleOfRadius: sprite.size.width / 2)
        physicsBody.contactTestBitMask = Axioms.PhysicsBitmask.Manna.rawValue
        physicsBody.collisionBitMask = Axioms.PhysicsBitmask.Archon.rawValue
        physicsBody.categoryBitMask = Axioms.PhysicsBitmask.Archon.rawValue
        physicsBody.linearDamping = 1
        physicsBody.restitution = 0
        sprite.physicsBody = physicsBody

        let q = GKRandomDistribution(lowestValue: 500, highestValue: 2000)
        let r = Float(q.nextInt())
        let s = TimeInterval(r / 1000.0)
        
        foragingDelay = SKAction.wait(forDuration: s)
        
        let sensorBody = setupButton(name: inName)
        
        let connectionPoint = sprite.convert(CGPoint.zero, to: inScene)
        let joint = SKPhysicsJointFixed.joint(withBodyA: physicsBody, bodyB: sensorBody, anchor: connectionPoint)
        inScene.physicsWorld.add(joint)
        
        sprite.name = inName;
        
        setupGrid(scene: inScene);
        
        setupForager()
    }
    
    private func setupForager() {
        if showForagingDebug { for i in 0 ..< 8 { grid[i].alpha = 0 } }

        forager = Forager(self)
        
        sprite.removeAllActions()
        
        let c = SKAction.run { self.forage() }
        let g = SKAction.sequence([foragingDelay, c])
        let f = SKAction.repeatForever(g)
        sprite.run(f)
        
        isForaging = true
    }
    
    private func forage() {
        forager!.tick()
        
        if showForagingDebug {
            let gridArrayIndex = forager!.trail.getIndexOfNewestElement()
            let square = grid[gridArrayIndex]
            square.position = forager!.targetPosition.toCGPoint()
            square.alpha = 1
            
            for i in 0 ..< 8 {
                let j = (gridArrayIndex + i + 1) % 8
                
                grid[j].alpha -= (1.0 / 8.0)
                if grid[j].alpha < 0 { grid[j].alpha = 0 }
            }
        }
        
        sprite.physicsBody?.velocity = CGVector.zero
        
        let name = (sprite.name)!
        let button = sprite.childNode(withName: name)!
        button.physicsBody!.velocity = CGVector.zero
        
        let impulse = XY(forager!.targetPosition - XY(sprite.position)).normalized()
        sprite.physicsBody?.applyImpulse(impulse.toCGVector())
    }
    
    private func setupGrid(scene inScene : GameScene) {
        if showForagingDebug {
            for _ in 0 ..< 8 {
                let square = SKSpriteNode(imageNamed: "grid")
                square.scale(to: CGSize(width: 30, height: 30))
                square.colorBlendFactor = 1
                square.color = .white
                square.position = sprite.position;
                
                inScene.addChild(square)
                
                grid.append(square)
            }
        }
    }
    
    private func setupButton(name inName : String) -> SKPhysicsBody {
        let button = SKSpriteNode(imageNamed: "button6")
        button.zPosition = 1
        button.colorBlendFactor = 1
        button.color = .white
        sprite.addChild(button)
        
        let sensorBody = SKPhysicsBody(circleOfRadius: sprite.size.width)
        sensorBody.contactTestBitMask = Axioms.PhysicsBitmask.Manna.rawValue
        sensorBody.collisionBitMask = 0
        sensorBody.categoryBitMask = Axioms.PhysicsBitmask.Sensor.rawValue
        sensorBody.linearDamping = 0
        
        button.physicsBody = sensorBody
        button.name = inName
        
        return sensorBody
    }
    
    func tick() {
        if mannaToPursue !== nil && !isPursuingManna { pursueManna() }
        if !mannaToEat.isEmpty { eatManna() }
    }
    
    func mannaSensed(_ mannaBody : SKPhysicsBody) {
        if mannaToPursue == nil { isPursuingManna = false }
        
        mannaToPursue = mannaBody
    }
    
    func mannaTouched(_ mannaName: String) {
        mannaToEat.insert(mannaName)
    }
    
    private func eatManna() {
        guard !mannaToEat.isEmpty else { return }
        
        let myBody = sprite.physicsBody!
        
        for mannaName in mannaToEat {
            let mannaParticle = mannaGenerator.getMannaParticle(mannaName)
            myBody.mass += mannaParticle.sprite.physicsBody!.mass / 10
        }

        mannaToEat.removeAll()
        
        print(sprite.name!, myBody.mass)
    }
    
    private func pursueManna() {
        guard let mannaBody = mannaToPursue else { fatalError("wtf?") }
        
        let myBody = sprite.physicsBody!

        let x = mannaBody.node!.position.x - myBody.node!.position.x
        let y = mannaBody.node!.position.y - myBody.node!.position.y
        
        let v = CGVector(dx: x, dy: y)
        let a = Double(sqrt(pow(v.dx, 2) + pow(v.dy, 2)))
        let b = XY(XY(v) / a).toCGVector()
        
        myBody.velocity = CGVector.zero
        
        let name = (sprite.name)!
        let button = sprite.childNode(withName: name)!
        button.physicsBody!.velocity = CGVector.zero
        
        myBody.applyImpulse(b)
        
        isPursuingManna = true
        mannaToPursue = nil
        
        sprite.removeAllActions()
        
        let c = SKAction.run { self.setupForager() }
        sprite.run(c)
    }
}
