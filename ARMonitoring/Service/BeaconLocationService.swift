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
import Darwin

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
        
        //print()
        //print(knownBeacons.count)
        
        if knownBeacons.count > 0 {
            for beacon in knownBeacons {
                print("------------")
                print(beacon.accuracy)
                print(beacon.proximity.rawValue)
                print(beacon.rssi)
                print("------------")
                print(pow(Decimal((beacon.rssi-(-64))/(10 * 2)), 10))
                print("==")
                // Get Beacon from activeBeacons OR localDB beacons
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
                        break;
                    }
                }
                
                // print("cf: \(aBeacon.calibrationFactor), rssi: \(beacon.rssi)")
                
                // Get Range & Position of user to beacon
                // If using Kalmann filter, need to get multiple anges before adding to userPosition
//                let range_ = Beacon.caclulateAccuracy(
//                    calibrationFactor: 70,
//                    rssi: beacon.rssi)
                let range_ = Float(100)//Float(beacon.accuracy) * 0.58
                print("range: \(range_)")
//                print("acc: \(beacon.accuracy)")

                
                // Position
                if let scenePosition = sceneView.getCameraCoordinates()?.toVector3() {
                    // Check position is not 0 0 0
                    let beaconPos = Position(location: scenePosition, range: range_)
                    aBeacon.pastUserPositions?.append(beaconPos)
                    
                    // Trilaterate if enough positions known
                    // If aBeacon.pastUserPositions.count >= 3 trilaterate and add room to Scene
                    if let userPastPos = aBeacon.pastUserPositions {
                        if userPastPos.count <= 3 {
                            //debug
                            debug(pos: scenePosition, tril: true)
                        }
                        if userPastPos.count == 3 {
                            let posCount = userPastPos.count
                            
                            let tril_ = TrilatTests.trilaturate(
                                p1: userPastPos[posCount-3].toPosition2(),
                                p2: userPastPos[posCount-2].toPosition2(),
                                p3: userPastPos[posCount-1].toPosition2())

                            let tril = tril_.toVector3()
                            
                            debug(pos: tril, tril: false)
                            
                            let roomForAR: RoomForARDto = RoomForARDto()
                            roomForAR.roomLocation = tril
                            stompClient.sendMessage(
                                destination: ["/app/room", "/\(aBeacon.roomId!)"],
                                json: roomForAR.toJSON(),
                                usingPrivateChannel: true)
                            
//                            if let tril = trilaterate(
//                                p1: userPastPos[posCount-3],
//                                p2: userPastPos[posCount-2],
//                                p3: userPastPos[posCount-1],
//                                returnMiddle: true) {
//
//                                print("================")
//                                print("TRIL: \(tril)")
//                                print("================")
//                                debug(pos: tril[0], tril: false)
//
//
//                                let roomForAR: RoomForARDto = RoomForARDto()
//                                roomForAR.roomLocation = tril.first
//                                stompClient.sendMessage(
//                                    destination: ["/app/room", "/\(aBeacon.roomId!)"],
//                                    json: roomForAR.toJSON(),
//                                    usingPrivateChannel: true)
//                            }
                            // aBeacon.pastUserPositions.removeFirst()
                        }
                    }
                    
                    // Add Beacon to activeBeacons
                    activeBeacons.append(aBeacon)
                    // print("==========================")
                }
                else {
                    // print("Coordiante error (0, 0, 0)")
                }
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
    
    private func debug(pos:Vector3, tril: Bool) {
        var color_: UIColor;
        var size_: CGFloat
        if (tril) {
            color_ = UIColor.yellow
            size_ = 0.009
        }
        else {
            color_ = UIColor.green
            size_ = 0.1
            let lineGeo = SCNGeometry.lineFrom(vector: SCNVector3(0,0,0), toVector: pos.toSCNVector3())
            let lineNode = SCNNode(geometry: lineGeo)
            lineNode.position = SCNVector3(0,0,0)
            sceneView.scene.rootNode.addChildNode(lineNode)
        }
        
        let sphereGeo = SCNSphere(radius: size_)
        sphereGeo.firstMaterial?.diffuse.contents = color_
        let sphereNode = SCNNode(geometry: sphereGeo)
        sphereNode.position = pos.toSCNVector3()
        sceneView.scene.rootNode.addChildNode(sphereNode)
    }
}
