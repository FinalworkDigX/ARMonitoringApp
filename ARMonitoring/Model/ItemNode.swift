//
//  ObjectNode.swift
//  FirstARTest
//
//  Created by Ludovic Marchand on 26/12/2017.
//  Copyright © 2017 Ludovic Marchand. All rights reserved.
//

import Foundation
import ARKit
import SceneKit

// Staight copy from FirstARTest
class ItemNode: SCNNode {
    final let PLANE_SIZE:CGFloat = CGFloat(100)
    final let SCALE:SCNVector3 = SCNVector3(0.08, 0.08, 0.08)
    
    init(withName name: String) {
        super.init()
        self.name = name
        
        let billboardconstraint = SCNBillboardConstraint()
        billboardconstraint.freeAxes = SCNBillboardAxis.Y
        
        constraints = [billboardconstraint]
        
        self.createBackground()
        self.createNameText()
        self.createInfoText(info: "som info to display")
        /*
         Next up
         - receive data from emitter (json)
         - check how much rows, dynamically adapt text height / number of rows
         - 2functions -> background & rows
         */
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // Y acces anchor at bottom
    private func helloWorld() {
        // add text
        let pomTextNode = SKLabelNode(text: "pom")
        pomTextNode.name = "pom"
        pomTextNode.fontSize = 20
        pomTextNode.fontName = UIFont.systemFont(ofSize: 20).fontName
        pomTextNode.position = CGPoint(x: PLANE_SIZE/2, y: PLANE_SIZE/3)
        pomTextNode.zPosition = -5
        
    }
    
    private func createBackground()
    {
        let rect = CGRect(x: 0, y: 0, width: PLANE_SIZE, height: PLANE_SIZE)
        let rectShape = SKShapeNode(rect: rect)
        rectShape.name = "backgroundShape"
        rectShape.fillColor = SKColor.yellow
        rectShape.strokeColor = SKColor.red
        rectShape.lineWidth = 0.1
        rectShape.zPosition = -10
        
        let skScene = createScene(name: "backgroundScene", size: CGSize(width: PLANE_SIZE, height: PLANE_SIZE))
        skScene.addChild(rectShape)
        
        let scnPlane = toPlane(name: "background", skScene: skScene)
        toChildNode(name: "background", position: SCNVector3(0, 0, -0.5), plane: scnPlane)
    }
    
    private func createNameText()
    {
        print(self.name!)
        let nameTextNode = SKLabelNode(text: self.name!)
        nameTextNode.name = "nameText"
        nameTextNode.fontSize = 10
        nameTextNode.fontName = UIFont.systemFont(ofSize: 10).fontName
        nameTextNode.fontColor = SKColor.red
        nameTextNode.position = CGPoint(x: PLANE_SIZE/2, y: (PLANE_SIZE/6)*5)
        nameTextNode.zPosition = -5
        
        let skScene = createScene(name: "nameScene", size: CGSize(width: PLANE_SIZE, height: PLANE_SIZE))
        skScene.addChild(nameTextNode)
        
        let scnPlane = toPlane(name: "name", skScene: skScene)
        toChildNode(name: "name", position: SCNVector3(0, 0, -0.48), plane: scnPlane)
    }
    
    private func createInfoText(info: String)
    {
        print(self.name!)
        let nameTextNode = SKLabelNode(text: info)
        nameTextNode.name = "infoText"
        nameTextNode.fontSize = 10
        nameTextNode.fontName = UIFont.systemFont(ofSize: 10).fontName
        nameTextNode.fontColor = SKColor.red
        nameTextNode.position = CGPoint(x: PLANE_SIZE/2, y: (PLANE_SIZE/6)*4)
        nameTextNode.zPosition = -5
        
        let skScene = createScene(name: "infoScene", size: CGSize(width: PLANE_SIZE, height: PLANE_SIZE))
        skScene.addChild(nameTextNode)
        
        let scnPlane = toPlane(name: "info", skScene: skScene)
        toChildNode(name: "info", position: SCNVector3(0, 0, -0.48), plane: scnPlane)
    }
    
    private func createScene(name: String, size: CGSize) -> SKScene
    {
        let skScene = SKScene(size: size)
        skScene.backgroundColor = UIColor.clear
        skScene.name = name
        
        return skScene
    }
    
    private func toPlane(name: String, skScene: SKScene) ->SCNPlane
    {
        let plane = SCNPlane(width: PLANE_SIZE/10, height: -PLANE_SIZE/10)
        plane.name = "\(name)_plane"
        let material = SCNMaterial()
        material.name = "\(name)_material"
        material.isDoubleSided = true
        material.diffuse.contents = skScene
        plane.materials = [material]
        
        return plane
    }
    
    private func toChildNode(name: String, position: SCNVector3, plane: SCNPlane)
    {
        let node = SCNNode(geometry: plane)
        node.name = name
        node.position = position
        node.scale = SCALE
        
        self.addChildNode(node)
    }
}
