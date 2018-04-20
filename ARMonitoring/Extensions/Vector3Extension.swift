//
//  Vector3Extension.swift
//  ARMonitoring
//
//  Created by Ludovic Marchand on 16/03/2018.
//  Copyright © 2018 Ludovic Marchand. All rights reserved.
//

import Foundation
import Trilateration3D
import ARKit

extension Vector3 {
    
    init(fromJson: [String : Any]) {
        self.init()
        // ... got no time for this..
        let mx = fromJson["x"] as! NSNumber
        let my = fromJson["y"] as! NSNumber
        let mz = fromJson["z"] as! NSNumber
        self.x = Float(truncating: mx)
        self.y = Float(truncating: my)
        self.z = Float(truncating: mz)
    }
    
    func toSCNVector3() -> SCNVector3 {
        return SCNVector3(self.x, self.y, self.z)
    }
    
    func toJsonArray() -> [String : Any] {
        return ["x": self.x, "y": self.y, "z": self.z]
    }
}

