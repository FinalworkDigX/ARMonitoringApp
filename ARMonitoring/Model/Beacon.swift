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
    var location: Any?
    var roomId: String!
    var major: Int!
    var minor: Int!
    var calibrationFactor: Double!
    
    var pastUserPositions: [Position]!
    var txPower: Int!
    
    init() {
        self.pastUserPositions = [Position]()
    }
    
    required init?(map: Map) {
        self.pastUserPositions = [Position]()
    }
    
    func mapping(map: Map) {
        id                  <- map["id"]
        name                <- map["name"]
        description         <- map["description"]
        location            <- map["location"]
        roomId              <- map["roomId"]
        major               <- map["major"]
        minor               <- map["minor"]
        calibrationFactor   <- map["calibrationFactor"]
    }
    
    // https://gist.github.com/JoostKiens/d834d8acd3a6c78324c9
    func caclulateAccuracy(txPower: Int, rssi: Int) -> Float {
        if rssi == 0 {
            return -1
        }
        
        let ratio: Float = Float(rssi * 1 / txPower)
        if ratio < 1.0 {
            return pow(ratio, 10)
        }
        else {
            return (0.89976) * pow(ratio, 7.7095) + 0.111
        }
    }
    
}
