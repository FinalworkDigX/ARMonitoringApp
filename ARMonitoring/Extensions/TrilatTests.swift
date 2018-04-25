//
//  Trilateration3DExtension.swift
//  ARMonitoring
//
//  Created by Ludovic Marchand on 25/04/2018.
//  Copyright © 2018 Ludovic Marchand. All rights reserved.
//

import Foundation
import Trilateration3D
import UIKit
import Darwin

class TrilatTests {
    
    static func trilaturate(p1: Position2, p2: Position2, p3: Position2) -> CGPoint {
        // Helping functions
        //  - Trilateration
        func sqr(_ base : CGFloat) -> CGFloat {
            return base * base
        }
        
        func dot(a: Position2, b: Position2) -> CGFloat {
            return sqr(a.loc.x) - sqr(b.loc.x) + sqr(a.loc.y) - sqr(b.loc.y) + sqr(b.range) - sqr(a.range)
        }
        
        func dat(a: CGPoint, b: CGPoint, c: CGPoint) -> CGFloat {
            return (a.y - b.y) * (b.x - c.x)
        }
        
        let s = dot(a: p3, b: p2) / 2
        let t = dot(a: p1, b: p2) / 2
        
        let px = p2.loc.x - p1.loc.x
        
        let my = (t * (p2.loc.x - p3.loc.x)) - (s * px)
            / (dat(a: p1.loc, b: p2.loc, c: p3.loc) - dat(a: p3.loc, b: p2.loc, c: p1.loc))
        
        let mx = (my * (p1.loc.y - p2.loc.y) - t) / px
        
        return CGPoint(x: mx, y: my)
    }
}
