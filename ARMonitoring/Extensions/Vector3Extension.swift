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
        self.x = fromJson["x"] as! Float
        self.y = fromJson["y"] as! Float
        self.z = fromJson["z"] as! Float
    }
    
    func toSCNVector3() -> SCNVector3 {
        return SCNVector3(self.x, self.y, self.z)
    }
    
    func toJsonArray() -> [String : Any] {
        return ["x": self.x, "y": self.y, "z": self.z]
    }
}

