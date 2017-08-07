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

struct Forager {
    let archon: Archon
    let forageRadius: Double

    let relativePositions: [CGPoint]
    
    var searchAnchor: CGPoint
    var targetPosition: CGPoint
    var trail: CBuffer<CGPoint>!
    
    enum MovementConstraint { case random, upOnly, rightOnly, downOnly, leftOnly }
    
    init(_ inArchon : Archon) {
        archon = inArchon
        searchAnchor = archon.sprite.position
        targetPosition = CGPoint.zero
        trail = CBuffer<CGPoint>(baseElement: CGPoint(), howManyElements: 8)
        
        forageRadius = (archon.genome.genes["forageGridSize"]! as! ScalarGene).value
        
        var workPositions = [CGPoint]()
        for m in 0 ..< 8 {
            let p = CGPoint.fromPolar(r: forageRadius, theta: CGFloat(m) * (2 * CGFloat.pi) / 8)
            workPositions.append(p.floored())
        }
        
        relativePositions = workPositions
    }
    
    func computeMovementConstraint() -> MovementConstraint {
        var constraint = MovementConstraint.random
        
        if archon.sprite.position.x - CGFloat(forageRadius) < 0 { constraint = .rightOnly }
        else if archon.sprite.position.x + CGFloat(forageRadius) > archon.scene.size.width { constraint = .leftOnly }
        
        if archon.sprite.position.y - CGFloat(forageRadius) < 0 { constraint = .upOnly }
        else if archon.sprite.position.y + CGFloat(forageRadius) > archon.scene.size.height { constraint = .downOnly }
        
        return constraint
    }
    
    mutating func computeMovementTarget(_ constraint : MovementConstraint) {
        let bestChoices = populateMovementChoices(constraint)
        var acceptableChoices = [Int](), fallbacks = [Int]()
        var candidateTarget : CGPoint
        
        for i in 0 ..< bestChoices.count {
            candidateTarget = (relativePositions[bestChoices[i]] + searchAnchor).floored()
            
            if doWeRemember(candidateTarget) { fallbacks.append(bestChoices[i]) }
            else { acceptableChoices.append(bestChoices[i]) }
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
    
    mutating func tick() {
        let constraint = computeMovementConstraint()
        computeMovementTarget(constraint)
    }
}
