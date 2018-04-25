//
//  CGPointExtension.swift
//  ARMonitoring
//
//  Created by Ludovic Marchand on 26/04/2018.
//  Copyright © 2018 Ludovic Marchand. All rights reserved.
//

import Foundation
import Trilateration3D
import SceneKit

extension CGPoint {
    
    func toVector3() -> Vector3 {
        return Vector3(x: Float(self.x), y: Float(self.y), z: 0)
    }
    
    func toSCNVector3() -> SCNVector3 {
        return SCNVector3(self.x, self.y, 0)
    }
}

extension Position {
    func toPosition2() -> Position2 {
        let p = Position2()
        p.loc = self.loc.toCGPoint()
        p.range = CGFloat(self.range)
        p.name = self.name
        return p
    }
}
