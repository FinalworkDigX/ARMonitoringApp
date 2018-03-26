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
    let stompClient: StompClientService!
    let beaconLocation: BeaconLocationService!
    let beaconService: BeaconService!
    
    init(sceneView: ARSCNView) {
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
        
    }
    
    func stompBeaconsGet(beacons: [Beacon]) {
        
    }
    
}
