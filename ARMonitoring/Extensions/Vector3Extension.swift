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
    
    func toSCNVector3() -> SCNVector3 {
        return SCNVector3(self.x, self.y, self.z)
    }
}

