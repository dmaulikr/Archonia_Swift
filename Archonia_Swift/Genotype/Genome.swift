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
        "forageGridSize" : ScalarGene(raw: 30),
        "speed" : ScalarGene(raw: 50)
    ])
    
    init(raw: [String : Gene]) { genes = raw }
    
    init(inheritFrom: Genome) throws {
        var workingCopy = [String : Gene]()
        
        for (name, parentGene) in inheritFrom.genes {
            try workingCopy[name] = ScalarGene(parentGene: parentGene as! ScalarGene)
        }
        
        genes = workingCopy
    }
}
