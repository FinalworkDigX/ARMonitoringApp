//
//  BeaconLocationService.swift
//  ARMonitoring
//
//  Created by Ludovic Marchand on 16/03/2018.
//  Copyright © 2018 Ludovic Marchand. All rights reserved.
//

import Foundation
import CoreLocation
import ARKit
import Trilateration3D

class BeaconLocationService: NSObject, CLLocationManagerDelegate {
    
    var locationManager: CLLocationManager!
    var region: CLBeaconRegion!
    var stompClient: StompClientService!
    var activeBeacons: [Beacon]!
    
    var sceneView: ARSCNView!
    
    init(uuid:String, sceneView: ARSCNView, stompClient: StompClientService) {
        super.init()
        
        self.sceneView = sceneView
        self.stompClient = stompClient
        self.activeBeacons = [Beacon]()
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
        
        // Authorize if not already done
        if CLLocationManager.authorizationStatus() != .authorizedWhenInUse {
            locationManager.requestWhenInUseAuthorization()
        }
        
        // Set beacon regiond (uuid) + start monitoring
        region = CLBeaconRegion(proximityUUID: UUID(uuidString: uuid)!, identifier: "iBeacons")
    }
    
    func startObserving(failed: (NSError) -> ()) {
        print("start observing")
        if CLLocationManager.authorizationStatus() != .authorizedWhenInUse {
            failed(NSError(
                domain: "EHB.ARMonitoring.BeaconLocationService",
                code: -50,
                userInfo: [NSLocalizedFailureReasonErrorKey: "error.locationmanager.authorizationstatus.not.authorized"]))
        }
        locationManager.startRangingBeacons(in: region)
    }
    
    func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
        let knownBeacons = beacons.filter{ $0.proximity != .unknown }
        let forgettableBeacons = beacons.filter{ $0.proximity == .unknown }
        
        
        for beacon in beacons {
            print(String(format: "%.2f", beacon.accuracy) + " - \(beacon.minor)")
        }
        
        print("in location manager")
        print()
        print(knownBeacons.count)
        
        if knownBeacons.count > 0 {
            for beacon in knownBeacons {
                // DO
                // Get camera location from Scene
                // Get distance from Beacon
                // WHILE (3verschillende punten)
                // Get beacon if alreadyKnown
                
                // get beacon if already in activeBeacons array
                var aBeacon = Beacon()
                if let activeBeaconIndex = beaconActive(beacon: beacon) {
                    aBeacon = activeBeacons[activeBeaconIndex]
                }
                else {
                    self.stompClient.sendMessage()
                }
                // TODO: calculate range using calibrationfactor and rssi
                // Add current position in activeBeacons array
                let beaconPos = Position(location: sceneView.getCameraCoordinates().toVector3(), range: 1)
                aBeacon.pastUserPositions?.append(beaconPos)
                
                // TODO: trialterate over apstuserPositions
                // If aBeacon.pastUserPositions.count >= 3 trilaterate and add room to Scene
                
                print(aBeacon)
                // Active Beacons
                
            }
        }
        
        if forgettableBeacons.count != 0 && activeBeacons.count != 0 {
            for fBeacon in forgettableBeacons {
                if let activeBeaconIndex = beaconActive(beacon: fBeacon) {
                    activeBeacons.remove(at: activeBeaconIndex)
                }
            }
        }
    }
    
    private func beaconActive(beacon: CLBeacon) -> Int? {
        for (aIndex, aBeacon) in activeBeacons.enumerated() {
            if beacon.major == aBeacon.major,
                beacon.minor == aBeacon.minor {
                return aIndex
            }
        }
        
        return nil
    }
}
