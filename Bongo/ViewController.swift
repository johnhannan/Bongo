//
//  ViewController.swift
//  Bongo
//
//  Created by John Hannan on 11/12/18.
//  Copyright © 2018 John Hannan. All rights reserved.
//

import UIKit
import CoreMotion

class ViewController: UIViewController, UICollisionBehaviorDelegate {

    let motionManager = CMMotionManager()
    var dynamicAnimator : UIDynamicAnimator!
    var gravityBehavior : UIGravityBehavior!
    var collisionBehavior : UICollisionBehavior!
    var dynamicItemBehavior : UIDynamicItemBehavior!
    
    let kBlockSize : CGFloat = 100
    let kBlockVariation : CGFloat = 75
    let kBoundaryDuration :TimeInterval = 10
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addGestures()
        addBehaviors()
        
    }


    func addGestures() {
        let singleTap = UITapGestureRecognizer(target: self, action: #selector(ViewController.addBlock(recognizer:)))
        self.view.addGestureRecognizer(singleTap)
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(addAttachment(recognizer:)))
        self.view.addGestureRecognizer(doubleTap)
        doubleTap.numberOfTapsRequired = 2
        singleTap.require(toFail: doubleTap)
        
        let pan = UIPanGestureRecognizer(target: self, action: #selector(ViewController.addCollision(recognizer:)))
        self.view.addGestureRecognizer(pan)
        
    }
    
    func addBehaviors() {
        dynamicAnimator = UIDynamicAnimator(referenceView: self.view)
        
        dynamicItemBehavior = UIDynamicItemBehavior(items: [])
        dynamicItemBehavior.allowsRotation = false
        gravityBehavior = UIGravityBehavior(items: [])
        gravityBehavior.gravityDirection = CGVector(dx: 0.0, dy: 0.1)
        gravityBehavior.action = {
            if let deviceMotion = self.motionManager.deviceMotion {
               let gravity = deviceMotion.gravity
                self.gravityBehavior.gravityDirection = CGVector(dx: gravity.x, dy: -gravity.y)
                
            }
        }
        
        collisionBehavior = UICollisionBehavior(items: [])
        collisionBehavior.translatesReferenceBoundsIntoBoundary = true
        collisionBehavior.collisionDelegate = self
        
        dynamicAnimator.addBehavior(gravityBehavior)
        dynamicAnimator.addBehavior(collisionBehavior)
        dynamicAnimator.addBehavior(dynamicItemBehavior)
        
    }
    
    
    @objc func addBlock(recognizer: UITapGestureRecognizer) {
        let point = recognizer.location(in: self.view)
        let _ = createBlockAt(point: point, square: true)
    }
    
    func createBlockAt(point:CGPoint, square isSquare:Bool) -> UIView {
        let size = kBlockSize + CGFloat(arc4random_uniform(UInt32(kBlockVariation))) - kBlockVariation
        let height = isSquare ? size : 5.0
        let block = UIView(frame: CGRect(x: 0, y: 0, width: size, height: height))
        block.backgroundColor = UIColor.randomColor
        block.center = point
        self.view.addSubview(block)
        
        gravityBehavior.addItem(block)
        collisionBehavior.addItem(block)
        
        return block
    }
    
    @objc func addAttachment(recognizer: UITapGestureRecognizer) {
        let point = recognizer.location(in: self.view)
        let block = createBlockAt(point: point, square: false)
        let attachment = UIAttachmentBehavior(item: block, attachedToAnchor: point)
        dynamicItemBehavior.addItem(block)
        
        attachment.damping = 0.5
        attachment.frequency = 5.0
        
        
        
        dynamicAnimator.addBehavior(attachment)
        
        let pan = UIPanGestureRecognizer(target: self, action: #selector(ViewController.dragBlock(recognizer:)))
        block.addGestureRecognizer(pan)
        
    }
    
    @objc func dragBlock(recognizer: UIPanGestureRecognizer) {
        recognizer.view?.center = recognizer.location(in: self.view)
        dynamicAnimator.updateItem(usingCurrentState: recognizer.view!)
        
    }
    
    var beginPoint : CGPoint!
    var bezierPath : UIBezierPath!
    var lineLayer : CAShapeLayer!
    
    @objc func addCollision(recognizer: UIPanGestureRecognizer) {
        switch recognizer.state {
        case .began:
            beginPoint = recognizer.location(in: self.view)
            bezierPath = UIBezierPath()
            lineLayer = CAShapeLayer()
            lineLayer.strokeColor = UIColor.black.cgColor
            lineLayer.lineWidth = 5.0
            self.view.layer.addSublayer(lineLayer)
        case .changed:
            let endPoint = recognizer.location(in: self.view)
            bezierPath.removeAllPoints()
            bezierPath.move(to: beginPoint)
            bezierPath.addLine(to: endPoint)
            lineLayer.path = bezierPath.cgPath

            
        case .ended:
            let endPoint = recognizer.location(in: self.view)
//
//            let path = UIBezierPath()
//            path.move(to: beginPoint)
//            path.addLine(to: endPoint)

            let boundaryID = "(\(String(describing: beginPoint))), \(endPoint))" as NSString
            collisionBehavior.addBoundary(withIdentifier: boundaryID, from: beginPoint, to: endPoint)
            
//            let userInfo = ["BoundaryID":boundaryID]
//            let _ = Timer.scheduledTimer(timeInterval: kBoundaryDuration, target: self, selector: #selector(ViewController.removeBoundary(timer:)), userInfo: userInfo, repeats: false)
            
        default:
            break
        }
    }
    
    @objc func removeBoundary(timer:Timer) {
        let userInfo = timer.userInfo as! [String:NSString]
        if let boundaryID = userInfo["BoundaryID"] {
            collisionBehavior.removeBoundary(withIdentifier: boundaryID)
        }
    }

}

