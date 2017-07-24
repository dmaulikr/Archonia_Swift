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
    var sprite: SKShapeNode
    
    init(scene inScene : GameScene, name inName : String, x inX : Double, y inY : Double) {
        sprite = SKShapeNode(circleOfRadius: 7.5);
        sprite.position = CGPoint(x: inX, y: inY);
        sprite.fillColor = NSColor(hue: 240 / 360, saturation: 1, brightness: 0.6, alpha: 1)
        sprite.strokeColor = sprite.fillColor
        
        inScene.addChild(sprite)
        
        let button = SKShapeNode(circleOfRadius: 7.5 / 3)
        button.fillColor = .white
        sprite.addChild(button)
        
        let physicsBody = SKPhysicsBody(circleOfRadius: 7.5)
        physicsBody.contactTestBitMask = Axioms.PhysicsBitmask.Manna.rawValue
        physicsBody.collisionBitMask = 0
        physicsBody.categoryBitMask = Axioms.PhysicsBitmask.Archon.rawValue
        sprite.physicsBody = physicsBody
        
        let sensorBody = SKPhysicsBody(circleOfRadius: 15)
        sensorBody.mass = 0
        sensorBody.contactTestBitMask = Axioms.PhysicsBitmask.Manna.rawValue
        sensorBody.collisionBitMask = 0
        sensorBody.categoryBitMask = Axioms.PhysicsBitmask.Sensor.rawValue
        button.physicsBody = sensorBody
        
        let connectionPoint = sprite.convert(CGPoint.zero, to: inScene)
        let joint = SKPhysicsJointFixed.joint(withBodyA: physicsBody, bodyB: sensorBody, anchor: connectionPoint)
        inScene.physicsWorld.add(joint)
        
        sprite.name = inName;
        button.name = inName;
        
        let distributionX = GKRandomDistribution(lowestValue: Int(-1e2), highestValue: Int(1e2));
        let distributionY = GKRandomDistribution(lowestValue: Int(-1e2), highestValue: Int(1e2));
        
        let x = CGFloat(distributionX.nextInt())
        let y = CGFloat(distributionY.nextInt())
        
        sprite.physicsBody?.applyImpulse(CGVector(dx: x, dy: y))
    }
    
    func mannaSensed(_ mannaBody : SKPhysicsBody) {
        let myBody = sprite.physicsBody!
        print("Manna sensed; v = ", myBody.velocity.dx, ", ", myBody.velocity.dy);
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
    }
}