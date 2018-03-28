//
//  BeaconCalibrationDto.swift
//  ARMonitoring
//
//  Created by Ludovic Marchand on 17/03/2018.
//  Copyright © 2018 Ludovic Marchand. All rights reserved.
//

import Foundation
import ObjectMapper

class BeaconCalibrationDto: Mappable {
    var id: String!
    var calibrationFactor: Float!
    
    init(id: String, calibrationFactor: Float) {
        self.id = id
        self.calibrationFactor = calibrationFactor
    }
    
    required init?(map: Map) {
    }
    
    func mapping(map: Map) {
        id                  <- map["id"]
        calibrationFactor   <- map["calibrationFactor"]
    }
}
