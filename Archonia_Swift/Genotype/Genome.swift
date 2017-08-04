//
//  Genome.swift
//  Archonia_Swift
//
//  Created by Rob Bishop on 8/4/17.
//  Copyright © 2017 Rob Bishop. All rights reserved.
//

struct Genome {
    let genes: [String : Gene]
    
    static let primordialGenome = Genome(raw: [
        "speed" : ScalarGene(raw: 50)
    ])
    
    init(raw: [String : Gene]) { genes = raw }
    
    init(inheritFrom: Genome) {
        var workingCopy = [String : Gene]()
        
        for (name, parentGene) in inheritFrom.genes {
            do {
                try workingCopy[name] = ScalarGene(parentGene: parentGene as! ScalarGene)
            } catch BirthDefect.GeneValueLessThanZero {
                print("Birth defect")
            } catch {
                fatalError()
            }
        }
        
        genes = workingCopy
    }
}
