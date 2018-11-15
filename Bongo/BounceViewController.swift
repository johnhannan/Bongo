//
//  BounceViewController.swift
//  Bongo
//
//  Created by John Hannan on 11/12/18.
//  Copyright © 2018 John Hannan. All rights reserved.
//

import UIKit

class BounceViewController: UIViewController, UICollisionBehaviorDelegate {

    @IBOutlet weak var topBumperView: UIView!
    @IBOutlet weak var leftBumperView: UIView!
    @IBOutlet weak var bottomBumperView: UIView!
    @IBOutlet weak var rightBumperView: UIView!
    
    
    var dynamicAnimator : UIDynamicAnimator!
    var gravityBehavior : UIGravityBehavior!
    var collisionBehavior : UICollisionBehavior!
    var itemBehaviors = UIDynamicItemBehavior()
    var bumperBehaviors : UIDynamicItemBehavior!
    var bumpers : [UIView]!
    
    override func viewDidLoad() {
        super.viewDidLoad()

           addBumpers()
        addBehaviors()
     
        addGestures()
    }
    

    func addBehaviors() {
        dynamicAnimator = UIDynamicAnimator(referenceView: self.view)
        collisionBehavior = UICollisionBehavior(items: bumpers)
        collisionBehavior.translatesReferenceBoundsIntoBoundary = true
        collisionBehavior.collisionDelegate = self
        
        itemBehaviors.resistance = 0.0
        itemBehaviors.elasticity = 0.9
        itemBehaviors.density = 0.0
        
        dynamicAnimator.addBehavior(collisionBehavior)
        dynamicAnimator.addBehavior(itemBehaviors)
        dynamicAnimator.addBehavior(bumperBehaviors)
    }
    
    func addGestures() {
        let pan = UIPanGestureRecognizer(target: self, action: #selector(BounceViewController.throwFire(recognizer:)))
        self.view.addGestureRecognizer(pan)
    }
    
    func addBumpers() {
        bumpers = [topBumperView,leftBumperView,bottomBumperView,rightBumperView]
        bumperBehaviors = UIDynamicItemBehavior(items: bumpers)
        bumperBehaviors.isAnchored = true
    }
    
 

    var fireball : UIView!
    @objc func throwFire(recognizer: UIPanGestureRecognizer) {
        
        
        
        switch recognizer.state {
        case .began:
            fireball = UIImageView(image: UIImage(named: "fire"))
            let location = recognizer.location(in: self.view)
            fireball.center = location
            self.view.addSubview(fireball)
            collisionBehavior.addItem(fireball)
        case .changed:
            let translation = recognizer.translation(in: self.view)
            fireball.center.x += translation.x
            fireball.center.y += translation.y
            recognizer.setTranslation(.zero, in: view)
        default:
            let velocity = recognizer.velocity(in: self.view)
            
            itemBehaviors.addItem(fireball)
            itemBehaviors.addLinearVelocity(velocity, for: fireball)
            
            
        }
        
    }
    

    //MARK: - Collision Detection
    func collisionBehavior(_ behavior: UICollisionBehavior, beganContactFor item1: UIDynamicItem, with item2: UIDynamicItem, at p: CGPoint) {

    }
    
    func collisionBehavior(_ behavior: UICollisionBehavior, beganContactFor item: UIDynamicItem, withBoundaryIdentifier identifier: NSCopying?, at p: CGPoint) {
    }
}
