//
//  Beacon.swift
//  ARMonitoring
//
//  Created by Ludovic Marchand on 16/03/2018.
//  Copyright © 2018 Ludovic Marchand. All rights reserved.
//

import Foundation
import CoreLocation
import Trilateration3D
import Darwin

class Beacon: CLBeacon {
    
    var pastUserPositions: [Position]?
    var txPower: Int?
    
    override init() {
        super.init()
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        self.pastUserPositions = [Position]()
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
