//
//  SCNodeExtension.swift
//  FirstARTest
//
//  Created by Ludovic Marchand on 24/12/2017.
//  Copyright © 2017 Ludovic Marchand. All rights reserved.
//

import Foundation
import SceneKit
import ARKit

extension SCNNode {
    
    func getParentNode(thatContians name: String) -> SCNNode? {
        if self.name?.range(of: name) != nil {
            return self
        }
        else {
            return self.parent?.getParentNode(thatContians: name)
        }
    }
}

