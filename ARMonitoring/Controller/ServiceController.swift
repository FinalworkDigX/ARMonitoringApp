//
//  ServiceController.swift
//  ARMonitoring
//
//  Created by Ludovic Marchand on 27/03/2018.
//  Copyright © 2018 Ludovic Marchand. All rights reserved.
//

import Foundation
import ARKit

class ServiceController: StompClientDelegate {
    var stompClient: StompClientService!
    var beaconLocation: BeaconLocationService!
    var beaconService: BeaconService!
    
    var sceneView: ARSCNView!
    
    init(sceneView: ARSCNView) {
        self.sceneView = sceneView
        
        let url = URL(string: "https://fw.ludovicmarchand.be/managerWS/websocket")!
        stompClient = StompClientService(delegate: self, socketUrl: url)
        
        let uuid = "4AFECBF0-E8A4-0135-7D93-7E27D0FEF627"
        beaconLocation = BeaconLocationService(
            uuid: uuid,
            sceneView: sceneView,
            stompClient: stompClient)
        
        beaconService = BeaconService()
    }
    
    func connectionStatusUpdate(status: StompClientService.ConnectionStatus) {
        
    }
    
    func stompText(text: String) {
        
    }
    
    func stompDataLogGet(dataLog: DataLog) {
        if let node = sceneView.getNodeInRoom(name: dataLog.itemId) {
            node.updateData(dataLog: dataLog)
        }
    }
    
    func stompBeaconsGet(beacons: [Beacon]) {
        beaconService.massInsertOrUpdate(beacons)
    }
    
}
