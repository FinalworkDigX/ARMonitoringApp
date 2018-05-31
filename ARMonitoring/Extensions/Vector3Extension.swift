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
    
    func toCGPoint() -> CGPoint {
        return CGPoint(x: Double(self.x), y: Double(self.y))
    }
    
    func substract(_ v: Vector3) -> Vector3 {
        return Vector3(
            x: self.x - v.x,
            y: self.y - v.y,
            z: self.z - v.z
        )
    }
    
    func add(_ v: Vector3) -> Vector3 {
        return Vector3(
            x: self.x + v.x,
            y: self.y + v.y,
            z: self.z + v.z
        )
    }
    
    func devide(_ devider: Int) -> Vector3 {
        let deviderF = Float(devider)
        return self.devide(deviderF)
    }
    
    func devide(_ devider: Float) -> Vector3 {
        return Vector3(
            x: self.x / devider,
            y: self.y / devider,
            z: self.z / devider
        )
    }
    
    func multiply(_ multiplier: Int) -> Vector3 {
        let multiplierF = Float(multiplier)
        return self.multiply(multiplierF)
    }
    
    func multiply(_ multiplier: Float) -> Vector3 {
        return Vector3(
            x: self.x * multiplier,
            y: self.y * multiplier,
            z: self.z * multiplier
        )
    }
    
    func cross(_ v: Vector3) -> Vector3 {
        return Vector3(
            x: self.y * v.z - self.z * v.y,
            y: self.z * v.x - self.x * v.z,
            z: self.x * v.y - self.y * v.x
        )
    }
}

