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
    var aBeacon: Beacon;
    var manualToggle: Bool = false;
    
    init(uuid:String, sceneView: ARSCNView, stompClient: StompClientService) {
        self.aBeacon = Beacon();
        
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
        if CLLocationManager.authorizationStatus() != .authorizedAlways &&
            CLLocationManager.authorizationStatus() != .authorizedWhenInUse {
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
        
        
        if knownBeacons.count > 0 {
            for (index, beacon) in knownBeacons.enumerated() {
                
                // Get Beacon from activeBeacons OR localDB beacons
                var beacon_ = Beacon()
                if let activeBeaconIndex = beaconActive(beacon: beacon) {
                    beacon_ = activeBeacons[activeBeaconIndex]
                }
                else {
                    if let localBeacon = beaconService.getByMajorMinor(
                        major: Int(truncating: beacon.major),
                        minor: Int(truncating: beacon.minor)
                    ) {
                        beacon_ = localBeacon
                    }
                    else {
                        print("ERROR: beacon not in localDB")
                        break;
                    }
                }
                // Set activebeacon as closest beacon
                if index == 0 {
                    aBeacon = beacon_;
                }
                
                if !self.manualToggle {
                    
                    // Get cameraCoordinates for average calcualtion
                    if let cameraCoordinates = sceneView.getCameraCoordinates()?.toVector3() {
                        // Add to arrays for later average calculation
                        beacon_.coordinatesAverage.append(cameraCoordinates)
                        beacon_.distanceAverage.append(beacon.accuracy)
                        
                        // If enough entries, calculate average
                        if (beacon_.distanceAverage.count > 3) {
                            
                            // Random factor test
                            let rFactor:Double = 2;
                            
                            //Calculate averages
                            let rangeA: Float = Float(beacon_.getAndStoreAverageDistance() * rFactor)
                            let cameraCoordinateA = beacon_.getAndStoreAverageCoordinates()
                            
                           
                            // Create Position
                            let beaconPos = Position(
                                location: cameraCoordinateA,
                                range: rangeA)
                            
                            //print("Range: \(beaconPos.range)")
                            beacon_.pastUserPositions?.append(beaconPos)
                            
                            // Trilaterate if enough positions known
                            // If beacon_.pastUserPositions.count >= 3 trilaterate and add room to Scene
                            if let userPastPos = beacon_.pastUserPositions {
                                // print("coord+range: r: \(userPastPos.last?.range), v:\(userPastPos.last?.loc)")
                                if userPastPos.count <= 4 {
                                    //debug
                                    debug(pos: cameraCoordinateA, tril: true)
                                }
                                if userPastPos.count == 4 {
                                    let posCount = userPastPos.count
                                    
                                    if let tril = trilaterate(
                                        p1: userPastPos[posCount-3],
                                        p2: userPastPos[posCount-2],
                                        p3: userPastPos[posCount-1],
                                        returnMiddle: true) {

                                        print("================")
                                        print("TRIL: \(tril)")
                                        print("================")
                                        debug(pos: tril[0], tril: false)

                                        callWebSocketSetRoom(tril.first!)
                                    }
                                }
                            }
                            // print("==========================")
                        }
                        // Add Beacon to activeBeacons
                        activeBeacons.append(beacon_)
                    
                    } // End of averages
                    else {
                        // print("Coordiantes too close to origin (0, 0, 0)")
                    }
                }
            
                if forgettableBeacons.count != 0 && activeBeacons.count != 0 {
                    for fBeacon in forgettableBeacons {
                        if let activeBeaconIndex = beaconActive(beacon: fBeacon) {
                            activeBeacons.remove(at: activeBeaconIndex)
                        }
                    }
                }
            // End beacons iteration
            }
        // End if beacon present
        }
    }
    
    private func beaconActive(beacon: CLBeacon) -> Int? {
        
        for (aIndex, beacon_) in activeBeacons.enumerated() {
            
            if Int(truncating: beacon.major) == beacon_.major,
                Int(truncating: beacon.minor) == beacon_.minor {
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
    
    public func callWebSocketSetRoom(_ pos: Vector3) {
        let roomForAR: RoomForARDto = RoomForARDto()
        roomForAR.roomLocation = pos
        stompClient.sendMessage(
            destination: ["/app/room", "/\(aBeacon.roomId!)"],
            json: roomForAR.toJSON(),
            usingPrivateChannel: true)
    }
}
