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
// import SwiftKeychainWrapper
import Trilateration3D

class ARViewController: UIViewController, ARSCNViewDelegate, StompClientDelegate {
    @IBOutlet weak var sceneView: ARSCNView!
    @IBOutlet weak var connectionStatusImage: UIImageView!
    
    private var stompClient: StompClientService?
    private var beaconLocationClient: BeaconLocationService?
    
    // TODO: make delegate for room detection (Beacons)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sceneView.delegate = self
        
        // Init scene
        let scene = SCNScene()
        sceneView.scene = scene
        
        // Debugging
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        //---------
        startWebsocketService()
        // startBeaconLocationService()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Hide navigation bar
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        
        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // Show navigation bar on other views
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "beaconListSegue" {
            let destinationVC = segue.destination as! BeaconsTableViewController
            destinationVC.beaconLocationClient = self.beaconLocationClient
        }
    }
    
    // MARK: - Buttons
    @IBAction func toBeaconList(_ sender: Any) {
    }
    
    
    func addItemToScene() {
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
        // self.stompClient?.sendMessage(destination: "/app/beacon")
        //generateRoom()
        
        let roomForAR: RoomForARDto = RoomForARDto()
        roomForAR.roomLocation = Vector3(x: 1.0, y: 1.1, z: 1.2)
        stompClient?.sendMessage(
            destination: ["/app/room", "/f9a5bae4-c089-4dab-8b2b-c89b9f33a610"],
            json: roomForAR.toJSON(),
            usingPrivateChannel: true)
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
        let roomJSON = "{\"id\": \"room_test_id\", \"name\": \"test_room\", \"description\": \"where is the room located in the building, ex A.2.204\", \"itemList\": [{ \"id\": \"test_item\", \"name\": \"HDD Server Rack 312\", \"location\": { \"x\": 0.0, \"y\": 0.0, \"z\": 10.0 }, \"room_id\": \"room_test_id\"}]}"
        // , \"rowList\": [\"first_row\", \"second_row\", \"third_row\"], \"room_id\": \"room_test_id\"}]
        let room: Room = Room(JSONString: roomJSON)!
        for item: Item in room.itemList {
            roomNode.addChildNode(ItemNode(withItem: item))
        }
        
        sceneView.scene.rootNode.addChildNode(roomNode)
    }
    
    // MARK: - WebSockets & StompClientDelegate
    func startWebsocketService() {
        let url = URL(string: "https://fw.ludovicmarchand.be/managerWS/websocket")!
        
        self.stompClient = StompClientService(delegate: self, socketUrl: url)
        self.stompClient?.openSocket()
    }
    
    func stompRoomGet(roomForAR: RoomForARDto) {
        let roomNode: SCNNode = SCNNode()
        roomNode.position = roomForAR.roomLocation.toSCNVector3()
        roomNode.name = "RoomNode"
        
        let room: Room = roomForAR.room
        for item: Item in room.itemList {
            roomNode.addChildNode(ItemNode(withItem: item))
        }
        
        sceneView.scene.rootNode.addChildNode(roomNode)
    }

    func stompDataLogGet(dataLog: DataLog) {
        
        print(dataLog.toLog())
        if let node = sceneView.getNodeInRoom(name: dataLog.itemId) {
            node.updateData(dataLog: dataLog)
        }
    }
    
    func stompBeaconsGet(beacons: [Beacon]) {
        print("Beacons: \(beacons.count)")
        let beaconService: BeaconService = BeaconService()
        beaconService.massInsertOrUpdate(beacons)
    }
    
    // Debugging
    func stompText(text: String) {
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
            firstInit()
            break;
        case .DISCONNECTED:
            dotColor = UIColor.red
            break;
        }
        
        self.connectionStatusImage.setConnectionStatusDot(color: dotColor)
    }
    
    //
    func startBeaconLocationService() {
        let uuid_ = "4AFECBF0-E8A4-0135-7D93-7E27D0FEF627"
        if let sceneView_ = self.sceneView, let stompClient_ = self.stompClient {
            self.beaconLocationClient = BeaconLocationService(
                uuid: uuid_,
                sceneView: sceneView_,
                stompClient: stompClient_)
            
            self.beaconLocationClient?.startObserving(failed: { error in 
                print(error)
            })
        }
        
    }
    
    func firstInit() {
        if !UserDefaults.standard.bool(forKey: "launchedBefore") {
            stompClient?.sendMessage(destination: ["/app/beacon"])
        }
    }
}
