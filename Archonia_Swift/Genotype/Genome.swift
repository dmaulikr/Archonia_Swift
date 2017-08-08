//
//  Genome.swift
//  Archonia_Swift
//
//  Created by Rob Bishop on 8/4/17.
//  Copyright © 2017 Rob Bishop. All rights reserved.
//

enum GeneID {
    case forageGridSize, speed
}

struct Genome {
    private let genes: [GeneID : Gene]
    
    static let primordialGenome = Genome(raw: [
        .forageGridSize : ScalarGene(raw: 30),
        .speed : ScalarGene(raw: 50)
    ])
    
    init(raw: [GeneID : Gene]) { genes = raw }
    
    init(inheritFrom: Genome) throws {
        var workingCopy = [GeneID : Gene]()
        
        for (geneID, parentGene) in inheritFrom.genes {
            try workingCopy[geneID] = ScalarGene(parentGene: parentGene as! ScalarGene)
        }
        
        genes = workingCopy
    }
    
    func getGeneValue(_ geneID: GeneID) -> Double {
        return (genes[geneID]! as! ScalarGene).value
    }
}
