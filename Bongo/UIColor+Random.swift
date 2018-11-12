//
//  UIColor+Random.swift
//  Lion Views
//
//  Created by John Hannan on 9/4/18.
//  Copyright © 2018 John Hannan. All rights reserved.
//

import Foundation

import UIKit

extension UIColor {

    static var randomColor : UIColor {return UIColor(red: CGFloat(arc4random() % 256)/255.0, green: CGFloat(arc4random() % 256)/255.0, blue: CGFloat(arc4random() % 256)/255.0, alpha: 1.0)}
    
}
