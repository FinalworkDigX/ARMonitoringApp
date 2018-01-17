//
//  ChildNodeExtension.swift
//  FirstARTest
//
//  Created by Ludovic Marchand on 24/12/2017.
//  Copyright © 2017 Ludovic Marchand. All rights reserved.
//

import Foundation
import SceneKit
import ARKit

extension ARSCNView {
    
    func getNode(name: String) -> SCNNode? {
        return self.scene.rootNode.childNode(withName: name, recursively: true)
    }
}
