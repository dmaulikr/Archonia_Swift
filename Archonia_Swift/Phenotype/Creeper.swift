//
//  Creeper.swift
//  Archonia_Swift
//
//  Created by Rob Bishop on 8/2/17.
//  Copyright © 2017 Rob Bishop. All rights reserved.
//

import Foundation
import GameplayKit
import SpriteKit

extension CGSize {
    static func *(lhs : CGSize, rhs : NSNumber) -> CGSize { return CGSize(width: lhs.width * CGFloat(rhs), height: lhs.height * CGFloat(rhs)) }
}

class Creeper {
    var forager: Forager! = nil
    let originalSize: CGSize
    let scene: GameScene
    let sprite: SKSpriteNode
    let nose: SKNode
    
    init(inScene: GameScene) {
        scene = inScene
        
        sprite = SKSpriteNode(imageNamed: "creeper")
        sprite.name = String(Axioms.nextUniqueObjectID())
        sprite.position = XY.randomPoint(range: inScene.size).toCGPoint()
        sprite.color = NSColor(hue: 240 / 360, saturation: 1, brightness: 0.6, alpha: 1)
        sprite.colorBlendFactor = 1

        originalSize = sprite.size
        sprite.scale(to: sprite.size * 0.02)

        scene.addChild(sprite)
        
        nose = SKNode()
        nose.position = CGPoint(x: 0, y: originalSize.height / 2)
        sprite.addChild(nose)
        
        forage(firstTime: true)
    }
    
    func forage(firstTime: Bool) {
        var actions = [SKAction]()
        
        if firstTime { forager = Forager(self) }
        else { actions.append(SKAction.wait(forDuration: 1.5, withRange: 3)) }
        
        let shorten = SKAction.resize(toHeight: originalSize.height * 0.75, duration: 0.5)
        let restore = SKAction.resize(toHeight: originalSize.height, duration: 0.5)
        
        let animationSequence = SKAction.sequence([shorten, restore])
        let animationRepeat = SKAction.repeatForever(animationSequence)
        
        forager.tick()
        
        let distance = forager.targetPosition.getDistanceTo(XY(sprite.position))
        let speed = 10.0
        
        let move = SKAction.move(to: forager.targetPosition.toCGPoint(), duration: distance / speed)
        
        let next = SKAction.run {
            self.sprite.removeAllActions()
            self.forage(firstTime: false)
        }
        
        let movementSequence = SKAction.sequence([move, next])
        
        let movementGroup = SKAction.group([animationRepeat, movementSequence])
        
        actions.append(movementGroup)
        
        sprite.run(SKAction.sequence(actions))
    }
}
