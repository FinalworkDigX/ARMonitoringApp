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
                
                
                
//                print("------------")
//                print(beacon.accuracy)
//                print(beacon.proximity.hashValue)
//                print(beacon.rssi)
//                print("------------")
//                print(pow(Decimal((beacon.rssi-(-70))/(10 * 2)), 10))
//                print("==")
                
                
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
//                    calibrationFactor: aBeacon.calibrationFactor,
//                    rssi: beacon.rssi)
                //print("range_calc: \(range_2)")
                //let range_ = Float(100)//Float(beacon.accuracy) * 0.58

                // Get cameraCoordinates for average calcualtion
                if let cameraCoordinates = sceneView.getCameraCoordinates()?.toVector3() {
                    // Add to arrays for later average calculation
                    aBeacon.coordinatesAverage.append(cameraCoordinates)
                    aBeacon.distanceAverage.append(beacon.accuracy)
                    print("count: \(aBeacon.distanceAverage.count)")
                    
                    // If enough entries, calculate average
                    if (aBeacon.distanceAverage.count > 2) {
                        
                        //Calculate averages
                        let rangeA: Float = Float(aBeacon.getAndStoreAverageDistance())
                        let cameraCoordinateA = aBeacon.getAndStoreAverageCoordinates()
                       
                        // Create Position
                        let beaconPos = Position(
                            location: cameraCoordinateA,
                            range: rangeA)
                        
                        print("Range: \(beaconPos.range)")
                        aBeacon.pastUserPositions?.append(beaconPos)
                        
                        // Trilaterate if enough positions known
                        // If aBeacon.pastUserPositions.count >= 3 trilaterate and add room to Scene
                        if let userPastPos = aBeacon.pastUserPositions {
                            if userPastPos.count <= 4 {
                                //debug
                                debug(pos: cameraCoordinateA, tril: true)
                            }
                            if userPastPos.count == 4 {
                                let posCount = userPastPos.count
                                
                                let tril_ = TrilatTests.trilat2(
                                    p1: userPastPos[posCount-4],
                                    p2: userPastPos[posCount-3],
                                    p3: userPastPos[posCount-2],
                                    p4: userPastPos[posCount-1])
                                
                                debug(pos: tril_, tril: false)
                                
                                
                                let roomForAR: RoomForARDto = RoomForARDto()
                                roomForAR.roomLocation = tril_
                                stompClient.sendMessage(
                                    destination: ["/app/room", "/\(aBeacon.roomId!)"],
                                    json: roomForAR.toJSON(),
                                    usingPrivateChannel: true)
                                
//                                if let tril = trilaterate(
//                                    p1: userPastPos[posCount-3],
//                                    p2: userPastPos[posCount-2],
//                                    p3: userPastPos[posCount-1],
//                                    returnMiddle: true) {
//
//                                    print("================")
//                                    print("TRIL: \(tril)")
//                                    print("================")
//                                    debug(pos: tril[0], tril: false)
//
//
//                                    let roomForAR: RoomForARDto = RoomForARDto()
//                                    roomForAR.roomLocation = tril.first
//                                    stompClient.sendMessage(
//                                        destination: ["/app/room", "/\(aBeacon.roomId!)"],
//                                        json: roomForAR.toJSON(),
//                                        usingPrivateChannel: true)
//                                }
                                // aBeacon.pastUserPositions.removeFirst()
                            }
                        }
                        // print("==========================")
                    }
                    // Add Beacon to activeBeacons
                    activeBeacons.append(aBeacon)
                
                } // End of averages
                else {
                    print("Coordiantes too close to origin (0, 0, 0)")
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
