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
import Toast_Swift
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
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        // Check for beacons
        if let beaconLocClient = self.beaconLocationClient {
            if !beaconLocClient.bleutoothToastCheck() {
                return false
            }
        }
        return true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "modalMenuSegue",
            let destinationVC = segue.destination as? ModalMenuViewController {
            
            destinationVC.beaconLocationClient = self.beaconLocationClient
        }
    }
    
    // MARK: - Buttons
    @IBAction func manualBeaconSetButton(_ sender: Any) {
        if let beaconLocClient = self.beaconLocationClient,
            let position = sceneView.getCameraCoordinates() {
            
            beaconLocClient.manualToggle = true;
            beaconLocClient.callWebSocketSetRoom(position.toVector3())
        }
        
    }
    
    // Test Func. To BE DELETED
    func generateRoom() {
        
        print("generate")
        beaconLocationClient?.manualToggle = true
        // =========================
        // Generate using WebSockets
        // =========================
        let roomForAR: RoomForARDto = RoomForARDto()
        roomForAR.roomLocation = Vector3(x: 0, y: 0, z: 0)

        stompClient?.sendMessage(
            destination: ["/app/room", "/d5182fb3-d68c-4a9e-994d-c004b003ebe4"],
            json: roomForAR.toJSON(),
            usingPrivateChannel: true)
    }
    
    // MARK: - WebSockets & StompClientDelegate
    func startWebsocketService() {
        self.stompClient = StompClientService(delegate: self, socketUrl: SessionService.sharedInstance.WS_URL)
        self.stompClient?.openSocket()
    }
    
    func stompRoomGet(roomForAR: RoomForARDto) {
        // FIX: Workarround for 1 beacon -> 1 item:
        //   Use itemId as room name
        let roomName: String = roomForAR.getFirstItemId()!
        
        if let node = sceneView.getNode(name: roomName) {
            node.removeFromParentNode()
        }
        
        let roomNode: SCNNode = SCNNode()
        roomNode.position = roomForAR.roomLocation.toSCNVector3()
        roomNode.name = roomName
        

        let room: Room = roomForAR.room
        for item: Item in room.itemList {
            roomNode.addChildNode(ItemNode(withItem: item))
        }
        sceneView.scene.rootNode.addChildNode(roomNode)
    }

    func stompDataLogGet(dataLog: DataLog) {
        
        print(dataLog.toLog())
        // FIX: Workaround 1 beacon -> 1item
        if let node = sceneView.getNodeInRoom(roomName: dataLog.itemId, nodeName: dataLog.itemId) {
            node.updateData(dataLog: dataLog)
        }
    }
    
    func stompBeaconsGet(beacons: [Beacon]) {
        print("Recieved Beacons: \(beacons.count)")
        print("Own Beacons: \(BeaconService().getAll().count)")
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
                uuid: SessionService.sharedInstance.BEACON_UUID,
                sceneView: sceneView_,
                stompClient: stompClient_,
                toastView: self.view
            )
            
            self.beaconLocationClient?.startObserving(failed: { error in 
                print(error)
            })
        }
        
    }
    
    func firstInit() {
        if !UserDefaults.standard.bool(forKey: "launchedBefore") {
            if let channel = SessionService.sharedInstance.getUserInfo()?.channel {
                stompClient?.sendMessage(destination: ["/app/beacon/\(channel)"])
            }
        }
    }
}
