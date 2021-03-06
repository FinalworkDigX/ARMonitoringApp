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

import UIKit

class ItemNode: SCNNode {
    
    final let PLANE_SIZE: CGFloat = 1000
    final let PLANE_PADDING: CGFloat = 50
    final let PLANE_ICOUNT: CGFloat = 7
    final let SCALE: SCNVector3 = SCNVector3(0.003, 0.003, 0.003)
    
    final let FILL_COLOR: SKColor = SKColor.black.withAlphaComponent(0.80)
    final let BORDER_COLOR: SKColor = SKColor.black
    
    final let FONT_COLOR: SKColor = SKColor.white
    final let FONT_NAME: String = "Courier"
    final let FONT_SIZE_1: CGFloat = 100;
    final let FONT_SIZE_2: CGFloat = 100;
    
    
    
    let item: Item;

    init(withItem item:Item) {
        self.item = item;
        super.init()
        
        // Set constraints
        let billboardconstraint = SCNBillboardConstraint()
        billboardconstraint.freeAxes = SCNBillboardAxis.Y
        constraints = [billboardconstraint]
        
        self.name = item.itemId
        
        setup(item: item)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup(item: Item) {
        self.createBackground()
        self.createNameText(name: item.name)
        self.createNameTextSeparator()
    }
    
    public func updateData(dataLog: DataLog) {
        for information in dataLog.information {
            self.deleteChildNode(withName: "\(information.name!)Node")
            self.createInfoText(name: information.name, info: information.data, index: information.index)
        }
    }
    
    private func createBackground() {
        // Create SubNode
        let rect = CGRect(x: 0, y: 0, width: PLANE_SIZE, height: PLANE_SIZE)
        let rectShape = SKShapeNode(rect: rect)
        rectShape.name = "backgroundShape"
        rectShape.fillColor = FILL_COLOR
        rectShape.strokeColor = BORDER_COLOR
        rectShape.lineWidth = 1
        rectShape.zPosition = -1
        
        // Add SubNode to ItemNode
        let skScene = createScene(name: "BackgroundScene", size: CGSize(width: PLANE_SIZE, height: PLANE_SIZE))
        skScene.addChild(rectShape)
        
        let scnPlane = toPlane(name: "background", skScene: skScene)
        var bgPosition: SCNVector3 = self.item.location
        bgPosition.z += -0.02
        toChildNode(name: "background", position: bgPosition, plane: scnPlane)
    }
    
    private func createNameText(name: String) {
        // Create SubNode
        let nameTextNode = SKLabelNode(text: name)
        nameTextNode.name = name
        nameTextNode.fontSize = FONT_SIZE_1
        nameTextNode.fontName = String(FONT_NAME + "-Bold")
        nameTextNode.fontColor = FONT_COLOR
        nameTextNode.position = CGPoint(
            x: (PLANE_SIZE - PLANE_PADDING) / 2,
            y: (PLANE_SIZE - PLANE_PADDING) / PLANE_ICOUNT * 6)
        nameTextNode.zPosition = 0

        // Add SubNode to ItemNode
        let skScene = createScene(
            name: "TitleScene",
            size: CGSize(
                width: (PLANE_SIZE - PLANE_PADDING),
                height: (PLANE_SIZE - PLANE_PADDING))
        )
        skScene.addChild(nameTextNode)
        
        let scnPlane = toPlane(name: "TitlePlane", skScene: skScene)
        toChildNode(name: "TitleNode", position: self.item.location, plane: scnPlane)
    }
    
    private func createNameTextSeparator() {
        let rect = CGRect(
            x: 0,
            y: 0,
            width: (PLANE_SIZE - (PLANE_PADDING * 2)),
            height: 10
        )
        let rectShape = SKShapeNode(rect: rect)
        rectShape.name = "titleSeparator"
        rectShape.fillColor = UIColor.white
        rectShape.position = CGPoint(
            x: PLANE_PADDING,
            y: ((PLANE_SIZE - PLANE_PADDING) / PLANE_ICOUNT * 6) - 10
        )
        rectShape.zPosition = 0
        
        // Add SubNode to ItemNode
        let skScene = createScene(
            name: "TitleSeparatorScene",
            size: CGSize(width: PLANE_SIZE, height: PLANE_SIZE)
        )
        skScene.addChild(rectShape)
        
        let scnPlane = toPlane(name: "TitleSeparatorPlane", skScene: skScene)
        toChildNode(name: "TitleSeparatorNode", position: self.item.location, plane: scnPlane)
    }
    
    private func createInfoText(name:String, info: String, index:Int) {
        // Create SubNode
        let nameTextNode = SKLabelNode(text: "\(name): \(info)")
        nameTextNode.name = name
        nameTextNode.fontSize = FONT_SIZE_2
        nameTextNode.fontName = FONT_NAME
        nameTextNode.fontColor = FONT_COLOR
        nameTextNode.position = CGPoint(
            x: PLANE_PADDING,
            y: ((PLANE_SIZE - PLANE_PADDING) / PLANE_ICOUNT) * CGFloat(5-index)
        )
        nameTextNode.horizontalAlignmentMode = .left
        nameTextNode.zPosition = 0
        
        // Add SubNode to ItemNode
        let skScene = createScene(name: "\(name)Scene", size: CGSize(width: (PLANE_SIZE - PLANE_PADDING), height: (PLANE_SIZE - PLANE_PADDING)))
        skScene.addChild(nameTextNode)
        
        let scnPlane = toPlane(name: "\(name)Plane", skScene: skScene)
        toChildNode(name: "\(name)Node", position: self.item.location, plane: scnPlane)
    }
    
    private func createScene(name: String, size: CGSize) -> SKScene {
        
        let skScene = SKScene(size: size)
        skScene.backgroundColor = UIColor.clear
        skScene.name = name
        
        return skScene
    }
    
    private func toPlane(name: String, skScene: SKScene) ->SCNPlane {
        
        let plane = SCNPlane(width: PLANE_SIZE/10, height: -PLANE_SIZE/10)
        plane.name = "\(name)_plane"
        let material = SCNMaterial()
        material.name = "\(name)_material"
        material.isDoubleSided = true
        material.diffuse.contents = skScene
        plane.materials = [material]
        
        return plane
    }
    
    private func toChildNode(name: String, position: SCNVector3, plane: SCNPlane) {
        
        let node = SCNNode(geometry: plane)
        node.name = name
        node.position = position
        node.scale = SCALE
        
        self.addChildNode(node)
    }
}
