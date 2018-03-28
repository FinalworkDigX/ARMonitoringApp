//
//  UIImageViewExtension.swift
//  ARMonitoring
//
//  Created by Ludovic Marchand on 28/01/2018.
//  Copyright © 2018 Ludovic Marchand. All rights reserved.
//

import Foundation
import UIKit

extension UIImageView {
    
    func setConnectionStatusDot(color: UIColor) {
        
        let statusDot = CAShapeLayer()
        
        statusDot.path = UIBezierPath(roundedRect: CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: 10, height: 10)), cornerRadius: 50).cgPath
        statusDot.fillColor = color.cgColor

        if self.layer.sublayers != nil {
            self.removeSublayers()
        }
        
        self.layer.addSublayer(statusDot)
    }
    
    func removeSublayers() {
        if self.layer.sublayers != nil {
            self.layer.sublayers?.removeAll()
        }
    }
}
