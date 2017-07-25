//
//  XY.swift
//  Archonia_Swift
//
//  Created by Rob Bishop on 7/25/17.
//  Copyright © 2017 Rob Bishop. All rights reserved.
//

import Foundation

struct XY {
    var x = 0.0, y = 0.0
    
    init(_ inX : Double, _ inY : Double) { x = inX; y = inY }
    init(_ point : XY) { x = point.x; y = point.y }
    init(_ point : CGPoint) { x = Double(point.x); y = Double(point.y) }
    init(_ point : CGVector) { x = Double(point.dx); y = Double(point.dy) }
    
    static func +=(lhs : inout XY, rhs : XY) { lhs.x += rhs.x; lhs.y += rhs.y }
    static func -=(lhs : inout XY, rhs : XY) { lhs.x -= rhs.x; lhs.y -= rhs.y }
    static func *=(lhs : inout XY, rhs : Double) { lhs.x *= rhs; lhs.y *= rhs }
    static func /=(lhs : inout XY, rhs : Double) { lhs.x /= rhs; lhs.y /= rhs }
    mutating func floor() { x = Darwin.floor(x); y = Darwin.floor(y) }
    
    static func +(lhs : XY, rhs : XY) -> XY { return XY(lhs.x + rhs.x, lhs.y + rhs.y) }
    static func -(lhs : XY, rhs : XY) -> XY { return XY(lhs.x - rhs.x, lhs.y - rhs.y) }
    static func *(lhs : XY, rhs : Double) -> XY { return XY(lhs.x * rhs, lhs.y * rhs) }
    static func /(lhs : XY, rhs : Double) -> XY { return XY(lhs.x / rhs, lhs.y / rhs) }
    func floored() -> XY { return XY(Darwin.floor(x), Darwin.floor(y)) }
    
    func getSign() -> Int {
        let sx = (x == 0) ? 0 : Int(abs(x) / x)
        let sy = (y == 0) ? 0 : Int(abs(y) / y)
        
        if sx == 0 { return sy } else if sy == 0 { return sx } else { return sx * sy }
    }
    
    func getMagnitude() -> Double { return sqrt(pow(x, 2) + pow(y, 2)) }
    func getSignedMagnitude() -> Double { return getMagnitude() * Double(getSign()) }
    
    func getAngleFrom(_ otherPoint : XY) -> Double { return atan2(y - otherPoint.y, x - otherPoint.x) }
    func getAngleTo(_ otherPoint : XY) -> Double { return otherPoint.getAngleFrom(self) }
    
    func getDistanceTo(_ otherPoint : XY) -> Double { let a = XY(self - otherPoint); return a.getMagnitude() }
    
    static func fromPolar(r : Double, theta : Double) -> XY { return XY(cos(theta) * r, sin(theta) * r) }
}
