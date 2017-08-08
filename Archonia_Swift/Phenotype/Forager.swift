//
//  Forager.swift
//  Archonia_Swift
//
//  Created by Rob Bishop on 7/25/17.
//  Copyright © 2017 Rob Bishop. All rights reserved.
//

import Foundation
import GameplayKit
import SpriteKit

class Forager {
    let archon: Archon
    let forageRadius: Double

    let relativePositions: [CGPoint]
    
    var searchAnchor = CGPoint.zero
    var targetPosition = CGPoint.zero
    var trail: CBuffer<CGPoint>!
    
    enum MovementConstraint { case random, upOnly, rightOnly, downOnly, leftOnly }
    
    init(_ inArchon : Archon) {
        archon = inArchon
        
        forageRadius = (archon.genome.genes["forageGridSize"]! as! ScalarGene).value
        
        var workPositions = [CGPoint]()
        for m in 0 ..< 8 {
            let p = CGPoint.fromPolar(r: forageRadius, theta: CGFloat(m) * (2 * CGFloat.pi) / 8)
            workPositions.append(p.floored())
        }
        
        relativePositions = workPositions
        reset()
    }
    
    func reset() {
        searchAnchor = archon.sprite.position
        trail = CBuffer<CGPoint>(baseElement: CGPoint(), howManyElements: 8)
    }
    
    func computeMovementConstraint() -> MovementConstraint {
        var constraint = MovementConstraint.random
        
        if archon.sprite.position.x - CGFloat(forageRadius) < 0 { constraint = .rightOnly }
        else if archon.sprite.position.x + CGFloat(forageRadius) > archon.scene.size.width { constraint = .leftOnly }
        
        if archon.sprite.position.y - CGFloat(forageRadius) < 0 { constraint = .upOnly }
        else if archon.sprite.position.y + CGFloat(forageRadius) > archon.scene.size.height { constraint = .downOnly }
        
        return constraint
    }
    
    func computeMovementTarget(_ constraint : MovementConstraint) {
        let bestChoices = populateMovementChoices(constraint)
        var acceptableChoices = [Int](), fallbacks = [Int]()
        var candidateTarget : CGPoint
        
        for i in 0 ..< bestChoices.count {
            candidateTarget = (relativePositions[bestChoices[i]] + searchAnchor).floored()
            
//            let sprite = SKSpriteNode(texture: Archon.buttonTexture)
//            sprite.colorBlendFactor = 1
//            sprite.position = candidateTarget
//            archon.scene.addChild(sprite)
//
//            let fade = SKAction.fadeOut(withDuration: 1)
//            let remove = SKAction.removeFromParent()
//            let sequence = SKAction.sequence([fade, remove])
//            sprite.run(sequence)
            
            if doWeRemember(candidateTarget) { /*sprite.color = .black;*/ fallbacks.append(bestChoices[i]) }
            else { /*sprite.color = .yellow;*/ acceptableChoices.append(bestChoices[i]) }
        }
        
        // If we're in up-only or down-only mode, we need to allow
        // for horizontal movement, in case we're crammed against
        // the top or bottom of the world
        fallbacks.append(2); fallbacks.append(6)
        
        if acceptableChoices.count > 0 {
            let d = GKRandomDistribution(lowestValue: 0, highestValue: acceptableChoices.count - 1);
            let c = d.nextInt()
            
            candidateTarget = (relativePositions[acceptableChoices[c]] + searchAnchor).floored()
        } else {
            let d = GKRandomDistribution(lowestValue: 0, highestValue: acceptableChoices.count - 1);
            let c = d.nextInt()
            
            candidateTarget = (relativePositions[fallbacks[c]] + searchAnchor).floored()
        }
        
        searchAnchor = candidateTarget
        trail.store(candidateTarget)
        
        targetPosition = candidateTarget
        
//        let sprite = SKSpriteNode(texture: Archon.buttonTexture)
//        sprite.colorBlendFactor = 1
//        sprite.color = .green
//        sprite.position = targetPosition
//        archon.scene.addChild(sprite)
//        
//        let wait = SKAction.wait(forDuration: 1)
//        let change = SKAction.run { sprite.color = .red }
//        let fade = SKAction.fadeOut(withDuration: 10)
//        let remove = SKAction.removeFromParent()
//        let sequence = SKAction.sequence([wait, change, fade, remove])
//        sprite.run(sequence)
    }
    
    func doWeRemember(_ targetPoint: CGPoint) -> Bool {
        var weRememberIt = false
        
        let _ = self.trail.forEach(callback: { (_: Int, rememberedPoint: CGPoint) -> Bool in
            if targetPoint.getDistanceTo(rememberedPoint) < CGFloat(forageRadius) {
                weRememberIt = true
                return false
            } else {
                return true
            }
        })
        
        return weRememberIt
    }
    
    func populateMovementChoices(_ constraint : MovementConstraint) -> [Int] {
        switch(constraint) {
        case .random:    return [0, 1, 2, 3, 4, 5, 6, 7]
        case .rightOnly: return [7, 0, 1]
        case .upOnly:    return [1, 2, 3]
        case .leftOnly:  return [3, 4, 5]
        case .downOnly:  return [5, 6, 7]
        }
    }
    
    func tick() {
        let constraint = computeMovementConstraint()
        computeMovementTarget(constraint)
    }
}
