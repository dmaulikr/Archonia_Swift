//
//  XY.swift
//  Archonia_Swift
//
//  Created by Rob Bishop on 7/25/17.
//  Copyright © 2017 Rob Bishop. All rights reserved.
//

import CoreGraphics

struct XY {
    var x = 0.0, y = 0.0
    
    init() { x = 0; y = 0 }
    init(_ inX : Double, _ inY : Double) { x = inX; y = inY }
    init(_ inX : Float, _ inY : Float) { x = Double(inX); y = Double(inY) }
    init(_ inX : Int, _ inY : Int) { x = Double(inX); y = Double(inY) }
    init(_ point : XY) { x = point.x; y = point.y }
    init(_ point : CGPoint) { x = Double(point.x); y = Double(point.y) }
    init(_ size : CGSize) { x = Double(size.width); y = Double(size.height) }
    init(_ vector : CGVector) { x = Double(vector.dx); y = Double(vector.dy) }
    
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
    func normalized() -> XY { let m = getMagnitude(); return XY(x / m, y / m) }
    
    static func ==(lhs : XY, rhs : XY) -> Bool { return lhs.x == rhs.x && lhs.y == rhs.y }
    
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
    
    func toCGPoint() -> CGPoint { return CGPoint(x: x, y: y) }
    func toCGSize() -> CGSize { return CGSize(width: x, height: y) }
    func toCGVector() -> CGVector { return CGVector(dx: x, dy: y) }
    
    static func randomPoint(range: CGSize) -> XY {
        return XY(Axioms.randomFloat(0, range.width), Axioms.randomFloat(0, range.height))
    }
}
