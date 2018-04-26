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
    
    public static func trilat2(p1: Position, p2: Position, p3: Position, p4: Position) -> Vector3 {
        func sqr(_ base: Float) -> Float {
            return base * base
        }
        
        func norm(_ vector: Vector3) -> Float {
            return sqrtf(sqr(vector.x) + sqr(vector.y) + sqr(vector.z))
        }
        
        func dot(a: Vector3, b: Vector3) -> Float {
            return a.x * b.x + a.y * b.y + a.z * b.z
        }
        
        let pv1 = p1.loc
        let pv2 = p2.loc
        let pv3 = p3.loc
        let pv4 = p4.loc
        
        let pr1 = p1.range
        let pr2 = p2.range
        let pr3 = p3.range
        let pr4 = p4.range
        
        let e_x =   pv1.substract(pv2).devide(norm(pv2.substract(pv1)))
        let i =     dot(a: e_x, b: pv3.substract(pv1))
        let e_y =   pv3.substract(pv1).substract(e_x.multiply(i)).devide(norm(pv3.substract(pv1).substract(e_x.multiply(i))))
        let e_z =   e_x.cross(e_y)
        let d =     norm(pv2.substract(pv1))
        let j =     dot(a: e_y, b: (pv3.substract(pv1)))
        let x =     (sqr(pr1)-sqr(pr2)+sqr(d)) / (d*2)
        let y =     ((sqr(pr1)-sqr(pr3)+sqr(i)+sqr(j))/(2*j)) - ((i/j)*x)
        let z1 =    sqrtf(sqr(pr1)-sqr(x)-sqr(y))
        let z2 =    sqrtf(sqr(pr2)-sqr(x)-sqr(y)) * -1
        let ans1 =  pv1.add(e_x.multiply(x)).add(e_y.multiply(y)).add(e_z.multiply(z1))
        let ans2 =  pv1.add(e_x.multiply(x)).add(e_y.multiply(y)).add(e_z.multiply(z2))
        let dist1 = norm(pv4.substract(ans1))
        let dist2 = norm(pv4.substract(ans2))
        
        if abs(pr4-dist1) < abs(pr4-dist2) {
            return ans1
        }
        else {
            return ans2
        }
    }
}
