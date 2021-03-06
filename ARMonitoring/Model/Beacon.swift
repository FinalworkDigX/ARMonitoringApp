//
//  Beacon.swift
//  ARMonitoring
//
//  Created by Ludovic Marchand on 16/03/2018.
//  Copyright © 2018 Ludovic Marchand. All rights reserved.
//

import Foundation
import ObjectMapper
import Trilateration3D
import Darwin

class Beacon: Mappable {
    
    var id: String!
    var name: String?
    var description: String?
    var roomId: String!
    var major: Int!
    var minor: Int!
    var calibrationFactor: Int!
    var lastUpdated: Double!
    
    static let destination: String = "/topic/beacon"
    
    var pastUserRanges: [Double]!
    var pastUserPositions: [Position]!
    var distanceAverage = [Double]()
    var coordinatesAverage = [Vector3]()
    var txPower: Int!
    
    init() {
        self.pastUserPositions = [Position]()
        self.pastUserRanges = [Double]()
    }
    
    required init?(map: Map) {
        self.pastUserPositions = [Position]()
    }
    
    func mapping(map: Map) {
        id                  <- map["id"]
        name                <- map["name"]
        description         <- map["description"]
        roomId              <- map["roomId"]
        major               <- map["major"]
        minor               <- map["minor"]
        calibrationFactor   <- map["calibrationFactor"]
        lastUpdated         <- map["lastUpdated"]
    }
    
    public func getAndStoreAverageDistance() -> Double {
        var average:Double = 0;
        for distance in self.distanceAverage {
            average += distance
        }
        average /= Double(self.distanceAverage.count)
        self.distanceAverage.removeAll()
        self.pastUserRanges.append(average)
        return average
    }
    
    public func getAndStoreAverageCoordinates() -> Vector3 {
        var average:Vector3 = Vector3(x: 0, y: 0, z: 0);
        for distance in self.coordinatesAverage {
            average = average.add(distance)
        }
        average = average.devide(self.coordinatesAverage.count)
        self.coordinatesAverage.removeAll()
        return average
    }
    
    // https://gist.github.com/JoostKiens/d834d8acd3a6c78324c9
    static func caclulateAccuracy(calibrationFactor: Int, rssi: Int) -> Float {
        if rssi == 0 {
            return -1
        }
        
        let ratio: Float = Float(rssi * 1 / calibrationFactor)
        if ratio < 1.0 {
            return pow(ratio, 10)
        }
        else {
            return (0.89976) * pow(ratio, 7.7095) + 0.111
        }
    }
    
}
