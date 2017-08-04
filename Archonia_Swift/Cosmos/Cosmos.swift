//
//  Cosmos.swift
//  Archonia_Swift
//
//  Created by Rob Bishop on 8/4/17.
//  Copyright © 2017 Rob Bishop. All rights reserved.
//

final class Cosmos {
    private init() {}
    
    static let shared = Cosmos()
    
    var momentOfCreation = true
}
