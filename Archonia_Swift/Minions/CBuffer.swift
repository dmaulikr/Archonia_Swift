//
//  CBuffer.swift
//  Archonia
//
//  Created by Rob Bishop on 7/3/17.
//  Copyright © 2017 Rob Bishop. All rights reserved.
//

import Foundation

enum ArchonsError: Error {
    case Error(String)
}

class CBuffer<T> {
    var empty: Bool
    var howManyElements: Int
    var indexForNextElement: Int
    var elements: [T]
    
    init(baseElement: T, howManyElements: Int) {
        self.empty = true
        self.indexForNextElement = 0
        self.elements = [T]()
        
        for _ in 0..<howManyElements { self.elements.append(baseElement) }
        
        self.howManyElements = howManyElements
    }
    
    func add(index: Int, howMany: Int) -> Int {
        guard self.elements.count > 0 else { fatalError("add(index:howMany:) can't work with an empty Cbuffer") }
        return (index + howMany + self.elements.count) % self.elements.count;
    }
    
    func advance() -> Void { advance(howMany: 1) }
    
    func advance(howMany: Int) -> Void {
        // Note the difference between this function and add(). To advance, we go
        // forward until the array is filled, then we circle back. The add() function
        // cares about how many elements are actually in the array
        self.indexForNextElement = (self.indexForNextElement + 1) % self.howManyElements;
    }
    
    func forEach(callback: (Int, T) -> Bool) -> Int {
        var ix = self.getIndexOfOldestElement()
        
        for _ in 0..<self.elements.count {
            let valueToPass = self.elements[ix]
            
            if callback(ix, valueToPass) == false { return ix }
            
            ix = self.add(index: ix, howMany: 1)
        }
        
        return 0
    }
    
    func getElementAt(ix: Int) -> T { let ix = self.add(index: ix, howMany: 0); return self.elements[ix] }
    
    func getIndexOfNewestElement() -> Int {
        guard self.elements.count > 0 else { fatalError("getIndexOfNewestElement() can't work with an empty Cbuffer"); }
        return (self.indexForNextElement + self.elements.count - 1) % self.elements.count
    }
    
    func getIndexOfOldestElement() -> Int {
        guard self.elements.count > 0 else { fatalError("getIndexOfOldestElement() can't work with an empty Cbuffer"); }
        return (self.elements.count == self.howManyElements) ? self.indexForNextElement : 0
    }
    
//    func getSpreadAt(index: Int, spread: Int) -> [T] {
//        guard self.elements.count >= spread else { fatalError("ASrray smaller than spread size") }
//        
//        // We want to return an index that is in the middle of the
//        // spread. If the spread is even, randomly choose one or the
//        // other element. If odd, just choose the center
//        var center = spread / 2
//        
//        if(spread % 2 == 0) { center += randomInt(min: -1, max: 0) }
//        
//        var result = [T]()
//        for i in 0..<spread {
//            let ix = self.add(index: index, howMany: i - center)
//            result.append(self.elements[ix])
//        }
//        
//        return result;
//    }
    
    func isEmpty() -> Bool { return self.empty }
    
    func reset() -> Void {
        self.empty = true
        self.indexForNextElement = 0
        self.elements = [T]()
    }
    
    func slice(start: Int, howMany: Int) throws -> [T] {
        guard self.elements.count > 0 else { throw ArchonsError.Error("Bad arguments to slice()") }
        
        var ix = 0
        
        if start >= 0 {
            ix = self.getIndexOfOldestElement()
        } else {
            ix = self.getIndexOfNewestElement()
            ix = self.add(index: ix, howMany: 1)
        }
        
        ix = self.add(index: ix, howMany: start)
        
        var slice = [T]()
        for _ in 0..<howMany {
            slice.append(self.elements[ix])
            ix = self.add(index: ix, howMany: 1)
        }
        
        return slice;
    }
    
    func store(_ valueToStore: T) -> Void {
        self.empty = false
        if self.elements.count < self.howManyElements {
            self.elements.append(valueToStore)
        } else {
            self.elements[self.indexForNextElement] = valueToStore
        }
        
        self.advance()
    }
}
