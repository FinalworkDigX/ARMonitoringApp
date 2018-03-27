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
    var beaconService: BeaconService!
    var activeBeacons: [Beacon]!
    
    var sceneView: ARSCNView!
    
    init(uuid:String, sceneView: ARSCNView, stompClient: StompClientService) {
        super.init()
        
        self.sceneView = sceneView
        self.stompClient = stompClient
        self.activeBeacons = [Beacon]()
        self.beaconService = BeaconService()
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        // Authorize if not already done
        if CLLocationManager.authorizationStatus() != .authorizedAlways {
            locationManager.requestAlwaysAuthorization()
        }
        
        // Set beacon regiond (uuid) + start monitoring
        self.region = CLBeaconRegion(proximityUUID: UUID(uuidString: uuid)!, identifier: "iBeacons")
    }
    
    func startObserving(failed: (NSError) -> ()) {
        print("===============")
        print("start observing")
        print("===============")
        if CLLocationManager.authorizationStatus() != .authorizedAlways {
            failed(NSError(
                domain: "EHB.ARMonitoring.BeaconLocationService",
                code: -50,
                userInfo: [NSLocalizedFailureReasonErrorKey: "error.locationmanager.authorizationstatus.not.authorized"]))
        }
        
        locationManager.startMonitoring(for: self.region)
        locationManager.startRangingBeacons(in: self.region)
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
                    if let localBeacon = beaconService.getByMajorMinor(
                        major: Int(truncating: beacon.major),
                        minor: Int(truncating: beacon.minor)
                    ) {
                        aBeacon = localBeacon
                    }
                    else {
                        print("ERROR: beacon not in localDB")
                    }
                }
                // If using Kalmann filter, need to get multiple anges before adding to userPosition
                // TODO: calculate range using calibrationfactor and rssi
                // Add current position in activeBeacons array
                let range_ = Beacon.caclulateAccuracy(
                    calibrationFactor: aBeacon.calibrationFactor, rssi: beacon.rssi)
                
                let beaconPos = Position(location: sceneView.getCameraCoordinates().toVector3(), range: range_)
                aBeacon.pastUserPositions?.append(beaconPos)
                
                // TODO: trialterate over apstuserPositions
                // If aBeacon.pastUserPositions.count >= 3 trilaterate and add room to Scene
                if let userPastPos = aBeacon.pastUserPositions {
                    if userPastPos.count >= 3 {
                        let posCount = userPastPos.count
                        print(trilaterate(
                            p1: userPastPos[posCount-3],
                            p2: userPastPos[posCount-2],
                            p3: userPastPos[posCount-1],
                            returnMiddle: true))
                    }
                }
                
                
                print(aBeacon)
                // Active Beacons
                activeBeacons.append(aBeacon)
                
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
            
            if Int(truncating: beacon.major) == aBeacon.major,
                Int(truncating: beacon.minor) == aBeacon.minor {
                return aIndex
            }
        }
        
        return nil
    }
}
