//
//  Engine.swift
//  Archonia_Swift
//
//  Created by Rob Bishop on 8/6/17.
//  Copyright © 2017 Rob Bishop. All rights reserved.
//

import SpriteKit

protocol Edible {
    var sprite: SKSpriteNode { get }
}

typealias Stimulus = (String, Edible, Int)

class Engine {
    let archon: Archon
    var forager: Forager
    var state: State = .Foraging
    var stimuli = [Stimulus]()
    
    init(_ inArchon: Archon) {
        archon = inArchon
        forager = Forager(archon)
    }
    
    enum State { case Foraging, PursuingManna, EatingManna }
}

extension Engine {
    func find(stimulus: String, who: SKSpriteNode) -> Int? {
        fatalError()
    }
    
    func find(stimulus: String) -> Int? {
        return stimuli.index(where: { $0.0 == stimulus })
    }
    
    func find(who: Edible) -> Int? {
        return stimuli.index(where: { $0.1.sprite.name! == who.sprite.name! })
    }

    func launch() { forage(reset: true) }
    
    func processStimuli() {
        guard !archon.sprite.hasActions() else { fatalError() }
        
        if stimuli.count == 0 { state = .Foraging; forage(reset: true) }
        else if let index = find(stimulus: "contact") { state = .EatingManna; eat(mannaParticle: index) }
        else if let index = find(stimulus: "sense") { state = .PursuingManna; pursue(mannaParticle: index) }
        else { fatalError() }
    }
}

extension Engine {
    func eat(mannaParticle atIndex: Int) {
        var actions = [SKAction]()
        let mannaParticle = stimuli[atIndex].1 as! MannaParticle
        let expectedIncarnationNumber = stimuli[atIndex].2

        // It's possible that we might sense a particle just before it rots
        // away, or is eaten by someone else, after which it would be reincarnated
        // and appear somewhere else, effectively a different particle.
        if mannaParticle.isCoherent && mannaParticle.incarnationNumber == expectedIncarnationNumber {
            let wait = SKAction.wait(forDuration: 0.5)
            let eat = SKAction.run { mannaParticle.beEaten() }
            
            actions.append(contentsOf: [wait, eat])
        }
        
        let next = SKAction.run { self.forage(reset: true) }
        actions.append(next)
        
        let button = archon.sprite.childNode(withName: archon.sprite.name!)!
        button.run(SKAction.sequence(actions))
        
        // Note: remove this stimulus immediately; don't wait for actions to finish
        stimuli.remove(at: atIndex)
    }
    
    func forage(reset: Bool) {
        guard stimuli.count == 0 else { archon.sprite.removeAllActions(); processStimuli(); return }
        
        state = .Foraging
        
        var actions = [SKAction]()
        
        if reset { forager = Forager(archon); state = .Foraging }
        else { actions.append(SKAction.wait(forDuration: 0.5, withRange: 0.5)) }
        
        forager.tick()
        
        let distance = Double(forager.targetPosition.getDistanceTo(archon.sprite.position))
        let speed = (archon.genome.genes["speed"]! as! ScalarGene).value
        let duration = distance / speed
        
        let move = SKAction.move(to: forager.targetPosition, duration: duration)
        let next = SKAction.run { self.forage(reset: false) }
        
        let movementSequence = SKAction.sequence([move, next])
        
        actions.append(movementSequence)
        
        archon.sprite.run(SKAction.sequence(actions))
    }

    func pursue(mannaParticle atIndex: Int) {
        var actions = [SKAction]()
        let mannaParticle = stimuli[atIndex].1 as! MannaParticle
        let expectedIncarnationNumber = stimuli[atIndex].2

        // It's possible that we might sense a particle just before it rots
        // away, or is eaten by someone else, after which it would be reincarnated
        // and appear somewhere else, effectively a different particle.
        if mannaParticle.isCoherent && mannaParticle.incarnationNumber == expectedIncarnationNumber {
            let distance = Double(mannaParticle.sprite.position.getDistanceTo(archon.sprite.position))
            let speed = (archon.genome.genes["speed"]! as! ScalarGene).value
            let duration = distance / speed
            
            let move = SKAction.move(to: mannaParticle.sprite.position, duration: duration)
            actions.append(move)
        }
        
        let next = SKAction.run {
            // Note: remove stimulus only if we complete the actions, that is, only
            // if we've moved all the way to where the manna was. Usually, we won't
            // get all the way there, because we'll get a contact notification as soon
            // as our circumference touches it, which will cancel this set of actions
            // and re-categorize the stimulus as a contact
            self.stimuli.remove(at: atIndex)
            self.forage(reset: true)
        }
        actions.append(next)
        
        archon.sprite.run(SKAction.sequence(actions))
    }
}

extension Engine {
    func contactManna(_ mannaParticle: MannaParticle) {
        if let index = find(who: mannaParticle) {
            stimuli[index].0 = "contact"
        } else {
            // If a particle materializes right on top of us, we might get the contact
            // notification before the sense notification, so we have to create the
            // stimulus here. We'll ignore the sense notification when it happens, because
            // we already have the stimulus
            stimuli.append(("contact", mannaParticle, mannaParticle.incarnationNumber))
        }
        
        // If we're not already in the middle of a meal, stop whatever it is we're
        // doing and eat
        if state != .EatingManna {
            archon.sprite.removeAllActions()
            processStimuli()
        }
    }

    func senseManna(_ mannaParticle: MannaParticle) {
        if find(who: mannaParticle) == nil {
            stimuli.append(("sense", mannaParticle, mannaParticle.incarnationNumber))
        }

        // If we've sensed food, stop foraging and go after it right away
        if state == .Foraging {
            archon.sprite.removeAllActions()
            processStimuli()
        }
    }
}
