//
//  Archon.swift
//  Archonia_Swift
//
//  Created by Rob Bishop on 7/24/17.
//  Copyright © 2017 Rob Bishop. All rights reserved.
//

import Foundation
import SpriteKit

class Archon {
    var sprite: SKShapeNode?
    
    init(scene inScene : GameScene, x inX : Double, y inY : Double) {
        sprite = SKShapeNode(circleOfRadius: 7.5);
        sprite!.position = CGPoint(x: inX, y: inY);
        sprite!.fillColor = .white
        
        inScene.addChild(sprite!)
    }
}
