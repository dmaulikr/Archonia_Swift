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
    let squareSize = 30.0

    let relativePositions : [XY]
    let sprite : SKSpriteNode
    let scene : GameScene
    
    var searchAnchor : XY
    var targetPosition : XY
    var trail : CBuffer<XY>
    
    enum MovementConstraint { case random, upOnly, rightOnly, downOnly, leftOnly }
    
    init(_ archon : Archon) {
        relativePositions = [
            XY(0, squareSize), XY(squareSize, squareSize), XY(squareSize, 0),
            XY(squareSize, -squareSize), XY(0, -squareSize), XY(-squareSize, -squareSize),
            XY(-squareSize, 0), XY(-squareSize, squareSize)
        ]
        
        sprite = archon.sprite
        scene = sprite.parent as! GameScene
        
        searchAnchor = XY(sprite.position)
        targetPosition = searchAnchor
        trail = CBuffer<XY>(baseElement: XY(), howManyElements: 8)
    }

    init(_ creeper : Creeper) {
        relativePositions = [
            XY(0, squareSize), XY(squareSize, squareSize), XY(squareSize, 0),
            XY(squareSize, -squareSize), XY(0, -squareSize), XY(-squareSize, -squareSize),
            XY(-squareSize, 0), XY(-squareSize, squareSize)
        ]
        
        sprite = creeper.sprite
        scene = sprite.parent as! GameScene
        
        searchAnchor = XY(sprite.position)
        targetPosition = searchAnchor
        trail = CBuffer<XY>(baseElement: XY(), howManyElements: 8)
    }
    
    func computeMovementConstraint() -> MovementConstraint {
        var constraint = MovementConstraint.random
        
        if sprite.position.x < 0 { constraint = .rightOnly }
        else if sprite.position.x > scene.size.width { constraint = .leftOnly }
        
        if sprite.position.y < 0 { constraint = .upOnly }
        else if sprite.position.y > scene.size.height { constraint = .downOnly }
        
        return constraint
    }
    
    mutating func computeMovementTarget(_ constraint : MovementConstraint) {
        let bestChoices = populateMovementChoices(constraint)
        var acceptableChoices = [Int](), fallbacks = [Int]()
        var candidateTarget : XY
        
        for i in 0 ..< bestChoices.count {
            candidateTarget = relativePositions[bestChoices[i]] + searchAnchor
            
            if doWeRemember(point: candidateTarget) { fallbacks.append(bestChoices[i]) }
            else { acceptableChoices.append(bestChoices[i]) }
        }
        
        // If we're in up-only or down-only mode, we need to allow
        // for horizontal movement, in case we're crammed against
        // the top or bottom of the world
        fallbacks.append(2); fallbacks.append(6)
        
        if acceptableChoices.count > 0 {
            let d = GKRandomDistribution(lowestValue: 0, highestValue: acceptableChoices.count - 1);
            let c = d.nextInt()
            
            candidateTarget = relativePositions[acceptableChoices[c]] + searchAnchor
        } else {
            let d = GKRandomDistribution(lowestValue: 0, highestValue: acceptableChoices.count - 1);
            let c = d.nextInt()
            
            candidateTarget = relativePositions[fallbacks[c]] + searchAnchor
        }
        
        searchAnchor = candidateTarget
        trail.store(candidateTarget)
        
        targetPosition = candidateTarget
    }
    
    func doWeRemember(point: XY) -> Bool {
        var weRememberIt = false
        
        let _ = self.trail.forEach(callback: { (_: Int, value: XY) -> Bool in
            if point == value { weRememberIt = true; return false } else { return true }
        })
        
        return weRememberIt
    }
    
    func populateMovementChoices(_ constraint : MovementConstraint) -> [Int] {
        switch(constraint) {
        case .random:    return [0, 1, 2, 3, 4, 5, 6, 7]
        case .upOnly:
            return [0, 1, 7]
        case .rightOnly:
            return [1, 2, 3]
        case .downOnly:
            return [3, 4, 5]
        case .leftOnly:
            return [5, 6, 7]
        }
    }
    
    mutating func tick() {
        let constraint = computeMovementConstraint()
        computeMovementTarget(constraint)
    }
}
