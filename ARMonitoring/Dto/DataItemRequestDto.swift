//
//  DataItemRequestDto.swift
//  ARMonitoring
//
//  Created by Ludovic Marchand on 10/05/2018.
//  Copyright © 2018 Ludovic Marchand. All rights reserved.
//

import Foundation

class DataItemRequestDto {
    let beaconId: String!
    let dataItemName: String!
    
    init(beaconId: String, dataItemName: String) {
        self.beaconId = beaconId
        self.dataItemName = dataItemName
    }
}
