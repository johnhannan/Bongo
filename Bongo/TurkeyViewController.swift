//
//  ViewController.swift
//  Bounce
//
//  Created by jjh9 on 11/18/18.
//  Copyright © 2018 jjh9. All rights reserved.
//

import UIKit
import CoreMotion


class TurkeyViewController: UIViewController, UICollisionBehaviorDelegate {

    let motionManager = CMMotionManager()
    
    var dynamicAnimator : UIDynamicAnimator!
    var gravityAnimator : UIDynamicAnimator!
    var turkeyGravityBehavior : UIGravityBehavior!
    var gravityBehavior : UIGravityBehavior!
    var collisionBehavior : UICollisionBehavior!
    var itemBehaviors : UIDynamicItemBehavior!

    let motionQueue = OperationQueue()
    
    let turkeyView = UIImageView(image: UIImage(named: "turkey"))
    var items = [UIImageView]()
    var timer : Timer?
    
    override func viewDidLoad() {
        let scale = 5.0
        
        super.viewDidLoad()
        self.view.addSubview(turkeyView)
        
        if motionManager.isDeviceMotionAvailable {
            
            motionManager.deviceMotionUpdateInterval = 0.01
            motionManager.accelerometerUpdateInterval = 0.01
            
            
            motionManager.startAccelerometerUpdates(to: motionQueue) { (data, error) in
                //guard let data = data, error != nil else { return }
                let acceleration = data!.acceleration
                let x = acceleration.x
                let y = acceleration.y

                DispatchQueue.main.async {
                    if self.turkeyGravityBehavior != nil {
                    self.turkeyGravityBehavior.gravityDirection = CGVector(dx: scale*x, dy: -scale*y)
                    }
                }
                
            }
            
//            motionManager.startGyroUpdates(to: .main) { (data, error) in
//
//                //guard let data = data, error != nil else { return }
//                let rate = data!.rotationRate
//                let x = rate.x
//                let y = rate.y
//
//
//                self.gravityBehavior.gravityDirection = CGVector(dx: scale*y, dy: scale*x)
//            }
            
//            motionManager.startDeviceMotionUpdates(to: .main) { (data, error) in
//
//                //guard let data = data, error != nil else { return }
//                let rate = data!.userAcceleration
//                let x = rate.x
//                let y = rate.y
//
//
//                self.gravityBehavior.gravityDirection = CGVector(dx: scale*y, dy: scale*x)
//            }
        }
        
    }

   
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
      
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        turkeyView.center = self.view.center
        if dynamicAnimator == nil {
            addBehaviors()
        }
    }
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

    }

    func addBehaviors() {
        dynamicAnimator = UIDynamicAnimator(referenceView: self.view)
        gravityAnimator = UIDynamicAnimator(referenceView: self.view)
        
        collisionBehavior = UICollisionBehavior(items: [turkeyView])
        collisionBehavior.translatesReferenceBoundsIntoBoundary = true
        collisionBehavior.collisionDelegate = self
        //collisionBehavior.addItem(turkeyView)
        
        itemBehaviors = UIDynamicItemBehavior(items: [])
        itemBehaviors.resistance = 0.0
        itemBehaviors.elasticity = 0.9
        itemBehaviors.density = 0.0
        
        gravityBehavior = UIGravityBehavior()
        gravityBehavior.gravityDirection = CGVector(dx: 0.0, dy: 3.0)
        
        turkeyGravityBehavior = UIGravityBehavior(items: [turkeyView])
        turkeyGravityBehavior.gravityDirection = CGVector.zero
       
        
        
        dynamicAnimator.addBehavior(collisionBehavior)
        dynamicAnimator.addBehavior(itemBehaviors)
        dynamicAnimator.addBehavior(turkeyGravityBehavior)
        gravityAnimator.addBehavior(gravityBehavior )
        
        collisionBehavior.action = {}
        
        
        }

    let interval : TimeInterval = 0.5
    @IBAction func togglePlay() {
        if timer == nil {
            timer = Timer.scheduledTimer(timeInterval: interval, target: self, selector: #selector(TurkeyViewController.dropItems), userInfo: nil, repeats: true)
        } else {
            timer?.invalidate()
            timer = nil
        }
        
    }
    
    @objc func dropItems() {
        let chance = arc4random() % 2 == 0
        if chance {
            let axeView = UIImageView(image: UIImage(named: "hatchet"))
            let buffer = axeView.bounds.width+5.0
            let x = CGFloat(arc4random_uniform(UInt32(Int(self.view.bounds.size.width)))) - CGFloat(2 * buffer)
            let origin = CGPoint(x: CGFloat(x) + buffer, y: 100.0)
            axeView.frame = CGRect(origin: origin, size: axeView.bounds.size)
            self.view.addSubview(axeView)
            gravityBehavior.addItem(axeView)
            collisionBehavior.addItem(axeView)
        }
    }

    func collisionBehavior(_ behavior: UICollisionBehavior, endedContactFor item1: UIDynamicItem, with item2: UIDynamicItem) {
        
        
    }
    
    func endGame() {
        togglePlay()
        let alertView = UIAlertController(title: "Game Over", message: "", preferredStyle: .alert)
        present(alertView, animated: true, completion: nil)
    }
}


