//
//  Gene.swift
//  Archonia_Swift
//
//  Created by Rob Bishop on 8/4/17.
//  Copyright © 2017 Rob Bishop. All rights reserved.
//

protocol Gene: class {
    var changeProbability: Double { get set }
    var changeRange: Double { get set }
}

extension Gene {
    func mutateMutatability(parentGene: Gene) {
        // Have to assign these first, before the mutation, because the
        // mutation function needs them in place before it can
        // operate properly.
        changeProbability = parentGene.changeProbability
        changeRange = parentGene.changeRange
        
        let newChangeProbability = mutateScalar(value: parentGene.changeProbability)
        let newChangeRange = mutateScalar(value: parentGene.changeRange)
        
        changeProbability = newChangeProbability
        changeRange = newChangeRange
    }
    
    func mutateScalar(value: Double) -> Double {
        return mutateScalar(value: value, sizeOfDomain: nil)
    }
    
    func mutateScalar(value: Double, sizeOfDomain: Double? = nil) -> Double {
        var probability = changeProbability
        var range = changeRange
        
        // Hopefully make creation a bit more interesting
        if Cosmos.shared.momentOfCreation { probability *= 10; range *= 10; }
        
        // Just to make it interesting, every once in a while, a big change
        var i = 0
        while i < 3 {
            if Axioms.randomBool() { range += 10; probability += 10; i += 1 }
            else { break }
        }
        
        if i == 0 { return value }  // No mutation on this gene for this baby
        else {
            if let s = sizeOfDomain {   // Caller wants to override the range
                let r = s * (1 + range / 100)
                return Axioms.randomDouble(value - r, value + r)
            } else {
                return Axioms.randomDouble(value * (1 - range / 100), value * (1 + range / 100))
            }
        }
    }
}

enum BirthDefect: Error {
    case GeneValueLessThanZero
}

class ScalarGene: Gene {
    var changeProbability = 10.0
    var changeRange = 10.0
    var value: Double = 0.0
    
    init(raw: Double) { value = raw }
    
    init(parentGene: ScalarGene) throws {
        mutateMutatability(parentGene: parentGene)
        value = mutateScalar(value: parentGene.value)
        
        if value < 0 { throw BirthDefect.GeneValueLessThanZero }
    }
}
