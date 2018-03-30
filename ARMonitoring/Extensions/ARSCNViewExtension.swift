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
    
    func getNodeInRoom(name: String) -> ItemNode? {
        return self.scene.rootNode.childNode(withName: "RoomNode", recursively: true)?
            .childNode(withName: name, recursively: true) as? ItemNode
    }
    
    func getCameraCoordinates() -> SCNVector3? {
        if let cameraTransform = self.session.currentFrame?.camera.transform {
            let cameraCoordinates = MDLTransform(matrix: cameraTransform).translation
            
            // If Cameralocation not yet ready / origin returns
            // Return nil
            if cameraCoordinates.x != 0.0,
                cameraCoordinates.y != 0.0,
                cameraCoordinates.z != 0.0 {
                
                var cc = SCNVector3()
                cc.x = cameraCoordinates.x
                cc.y = cameraCoordinates.y
                cc.z = cameraCoordinates.z
                return cc
            }
        }
        return nil
    }
}
