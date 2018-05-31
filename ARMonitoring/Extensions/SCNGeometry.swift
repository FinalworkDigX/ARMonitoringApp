//
//  SCNGeometry.swift
//  ARMonitoring
//
//  Created by Ludovic Marchand on 25/04/2018.
//  Copyright © 2018 Ludovic Marchand. All rights reserved.
//

import Foundation
import SceneKit

extension SCNGeometry {
    class func lineFrom(vector vector1: SCNVector3, toVector vector2: SCNVector3) -> SCNGeometry {
        let indices: [Int32] = [0, 1]
        
        let source = SCNGeometrySource(vertices: [vector1, vector2])
        let element = SCNGeometryElement(indices: indices, primitiveType: .line)
        
        return SCNGeometry(sources: [source], elements: [element])
    }
}
