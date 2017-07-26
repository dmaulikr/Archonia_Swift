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
    var timer : Timer?
    var showForagingDebug = false
    
    init(scene inScene : GameScene, name inName : String, x inX : Double, y inY : Double) {
        sprite = SKSpriteNode(imageNamed: "archon")
        sprite.scale(to: CGSize(width: 15, height: 15))
        sprite.position = CGPoint(x: inX, y: inY);
        sprite.color = NSColor(hue: 240 / 360, saturation: 1, brightness: 0.6, alpha: 1)
        sprite.colorBlendFactor = 1
        
        inScene.addChild(sprite)
        
        let physicsBody = SKPhysicsBody(circleOfRadius: 7.5)
        physicsBody.contactTestBitMask = Axioms.PhysicsBitmask.Manna.rawValue
        physicsBody.collisionBitMask = Axioms.PhysicsBitmask.Archon.rawValue
        physicsBody.categoryBitMask = Axioms.PhysicsBitmask.Archon.rawValue
        physicsBody.linearDamping = 200
        physicsBody.restitution = 0
        sprite.physicsBody = physicsBody
        
        let sensorBody = setupButton(name: inName)
        
        let connectionPoint = sprite.convert(CGPoint.zero, to: inScene)
        let joint = SKPhysicsJointFixed.joint(withBodyA: physicsBody, bodyB: sensorBody, anchor: connectionPoint)
        inScene.physicsWorld.add(joint)
        
        sprite.name = inName;
        
        setupGrid(scene: inScene);
        
        forager = Forager(self)

        let q = GKRandomDistribution(lowestValue: 500, highestValue: 2000)
        let s = Float(q.nextInt())
        let r = TimeInterval(s / 1000.0)
        timer = Timer.scheduledTimer(timeInterval: r, target: self, selector: #selector(tick), userInfo: nil, repeats: true)
    }
    
    @objc private func tick() {
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
        
        let impulse = XY(forager!.targetPosition - XY(sprite.position)).normalized() * 100
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
        let button = SKSpriteNode(imageNamed: "archon")
        button.scale(to: CGSize(width: 50, height: 50))
        button.colorBlendFactor = 1
        button.color = .white
        sprite.addChild(button)
        
        let sensorBody = SKPhysicsBody(circleOfRadius: 100)
        sensorBody.contactTestBitMask = Axioms.PhysicsBitmask.Manna.rawValue
        sensorBody.collisionBitMask = 0
        sensorBody.categoryBitMask = Axioms.PhysicsBitmask.Sensor.rawValue
        button.physicsBody = sensorBody
        
        button.name = inName
        
        return sensorBody
    }
    
    func mannaSensed(_ mannaBody : SKPhysicsBody) {
        #if false
        let myBody = sprite.physicsBody!

        let x = mannaBody.node!.position.x - myBody.node!.position.x
        let y = mannaBody.node!.position.y - myBody.node!.position.y
        
        let v = CGVector(dx: x, dy: y)
        let a = sqrt(pow(v.dx, 2) + pow(v.dy, 2))
        let b = CGVector(dx: v.dx / a * 50, dy: v.dy / a * 50)
        
        myBody.velocity = CGVector.zero
        
        let name = (sprite.name)!
        let button = sprite.childNode(withName: name)!
        button.physicsBody!.velocity = CGVector.zero
        
        myBody.applyImpulse(b)
        #endif
    }
}
