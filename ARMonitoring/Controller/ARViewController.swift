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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sceneView.delegate = self
        
        // Init scene
        let scene = SCNScene()
        sceneView.scene = scene
        
        // Debugging
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        // Start services
        startWebsocketService()
        startBeaconLocationService()
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
    @IBAction func resetRoomButton(_ sender: Any) {
//        print("beacon: \(String(describing: sceneView.getCameraCoordinates()))")
//        if let beaconLocClient = self.beaconLocationClient {
//            beaconLocClient.activeBeacons = [Beacon]()
//        }
        
        if let beaconLocClient = self.beaconLocationClient,
            let position = sceneView.getCameraCoordinates() {
            beaconLocClient.manualToggle = true;
            beaconLocClient.callWebSocketSetRoom(position.toVector3())
        }
        
    }
    
    // Test Func. To BE DELETED
    func generateRoom() {
        
        print("\(String(describing: sceneView.getCameraCoordinates()))")
        
        // =========================
        // Generate usign WebSockets
        // =========================
//        let roomForAR: RoomForARDto = RoomForARDto()
//        roomForAR.roomLocation = Vector3(x: 0.195782185, y: 0.0673767626, z: 0.0634026974)
//
//        stompClient?.sendMessage(
//            destination: ["/app/room", "/3fbf0f08-ae52-4529-8da7-731773a83a72"],
//            json: roomForAR.toJSON(),
//            usingPrivateChannel: true)
    }
    
    // MARK: - WebSockets & StompClientDelegate
    func startWebsocketService() {
        self.stompClient = StompClientService(delegate: self, socketUrl: SessionService.WS_URL)
        self.stompClient?.openSocket()
    }
    
    func stompRoomGet(roomForAR: RoomForARDto) {
        if let node = sceneView.getNode(name: "RoomNode") {
            node.removeFromParentNode()
        }
        
        let roomNode: SCNNode = SCNNode()
        roomNode.position = roomForAR.roomLocation.toSCNVector3()
        roomNode.name = "RoomNode"
        

        let room: Room = roomForAR.room
        for item: Item in room.itemList {
            roomNode.addChildNode(ItemNode(withItem: item))
        }
        sceneView.scene.rootNode.addChildNode(roomNode)
        
        //DEBUG
        
        
        let sphereGeo = SCNSphere(radius: 0.01)
        sphereGeo.firstMaterial?.diffuse.contents = UIColor.cyan
        let sphereNode = SCNNode(geometry: sphereGeo)
        sphereNode.position = roomForAR.roomLocation.toSCNVector3()
        sceneView.scene.rootNode.addChildNode(sphereNode)
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
        if let sceneView_ = self.sceneView, let stompClient_ = self.stompClient {
            self.beaconLocationClient = BeaconLocationService(
                uuid: SessionService.BEACON_UUID,
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
