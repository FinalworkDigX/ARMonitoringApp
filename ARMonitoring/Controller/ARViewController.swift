//
//  ARViewController.swift
//  ARMonitoring
//
//  Created by Ludovic Marchand on 17/01/2018.
//  Copyright © 2018 Ludovic Marchand. All rights reserved.
//

import Foundation
import ARKit
import SceneKit

class ARViewController: UIViewController, ARSCNViewDelegate, StompClientDelegate {

    @IBOutlet weak var sceneView: ARSCNView!
    @IBOutlet weak var connectionStatusImage: UIImageView!
    
    private var stompClient: StompClientService?
    
    // TODO: make delegate for room detection (Beacons)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        // Create a new scene
        // let scene = SCNScene(named: "art.scnassets/ship.scn")!
        let scene = SCNScene()
        
        // Set the scene to the view
        sceneView.scene = scene
        
        //---------
        startWebsocket()
        
        // Test alamofire / authentication
        authenticate()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        
        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }
    
    // MARK: - Buttons
    
    @IBAction func addItemButton(_ sender: Any) {
        // Temp disable.
        
//        let itemJSON = "{ \"id\": \"test_item_btnAdded\", \"name\": \"HDD Server Rack 312\", \"location\": { \"x\": 0.0, \"y\": 0.0, \"z\": 10.0 }, \"row_list\": [\"first_row\", \"second_row\", \"third_row\"], \"room_id\": \"room_test_id\"}"
//        let myItem = Item(JSONString: itemJSON)!
//        let testItem = ItemNode(withItem: myItem)
//        let cc = sceneView.getCameraCoordinates()
//
//        testItem.position = SCNVector3(cc.x, cc.y, cc.z-1)
//
//        // Add testItem to RoomNode
//        // RoomNode needs to be add programmatically by beacon position
//        // sceneView.getNode(name: "RoomNode")?.addChildNode(testItem)
//
//        sceneView.scene.rootNode.addChildNode(testItem)
    }
    
    // MARK: - ARSCNViewDelegate
    
    /*
     // Override to create and configure nodes for anchors added to the view's session.
     func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
     let node = SCNNode()
     
     return node
     }
     */
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
    
    // MARK: - RoomShizzle
    //tmp function to add testRoom
    @IBAction func resetRoomButton(_ sender: Any) {
        generateRoom()
    }
    
    func generateRoom() {
        if let node = sceneView.getNode(name: "RoomNode") {
            node.removeFromParentNode()
        }
        // TODO: Set room at coordinates with beacons
        //tmp fix
        let roomNode: SCNNode = SCNNode()
        roomNode.position = sceneView.getCameraCoordinates()
        roomNode.name = "RoomNode"
        
        // TODO: Itterate over 'Room' model to add items at correct coordinates inside the Room
        let roomJSON = "{\"id\": \"room_test_id\", \"name\": \"test_room\", \"description\": \"where is the room located in the building, ex A.2.204\", \"item_list\": [{ \"id\": \"test_item\", \"name\": \"HDD Server Rack 312\", \"location\": { \"x\": 0.0, \"y\": 0.0, \"z\": 10.0 }, \"row_list\": [\"first_row\", \"second_row\", \"third_row\"], \"room_id\": \"room_test_id\"}]}"
        let room: Room = Room(JSONString: roomJSON)!
        for item: Item in room.item_list {
            roomNode.addChildNode(ItemNode(withItem: item))
        }
        
        sceneView.scene.rootNode.addChildNode(roomNode)
    }
    
    // MARK: - WebSockets & StompClientDelegate
    func startWebsocket() -> () {
        let url = URL(string: "https://fw.ludovicmarchand.be/managerWS/websocket")!
        // let url = URL(string: "http://db.ludovicmarchand.be/managerWS/websocket")!
        
        self.stompClient = StompClientService(delegate: self, socketUrl: url)
        self.stompClient?.openSocket()
    }
    
    func stompDidReceiveJSON(dataLog: DataLog) {
        
        // print(dataLog.toLog())
        if let node = sceneView.getNodeInRoom(name: dataLog.item_id) {
            node.updateData(dataLog: dataLog)
        }
    }
    
    func stompTest(text: String) {
        print(text)
    }
    
    func connectionStatusUpdate(status: StompClientService.ConnectionStatus) {
        var dotColor: UIColor = UIColor.gray
        
        switch status {
        case .CONNECTING:
            dotColor = UIColor.yellow
            break;
        case .CONNECTED:
            dotColor = UIColor.green
            break;
        case .DISCONNECTED:
            dotColor = UIColor.red
            break;
        }
        
        self.connectionStatusImage.setConnectionStatusDot(color: dotColor)
    }
    
    //
    func authenticate() {
        let authService: AuthenticationService = AuthenticationService()
        
        let myUrl = "https://fw.ludovicmarchand.be/v1/auth/login"
        let loginDto = LoginDto(email: "*****", password: "*****")
        
        authService.authenticate(url: myUrl, loginDto: loginDto, success: { user in
            print("in success AUTH")
        } , failed: { error in
            print("in error AUTH")
        })
    }
}
