//
//  BeaconSqliteModel.swift
//  ARMonitoring
//
//  Created by Ludovic Marchand on 21/03/2018.
//  Copyright © 2018 Ludovic Marchand. All rights reserved.
//

import Foundation
import SQLite

class BeaconSqliteDto {
    let table = Table("beacon")
    let id = Expression<String>("id")
    let major = Expression<Int64>("major")
    let minor = Expression<Int64>("minor")
    let calibrationFactor = Expression<Double>("calibrationFactor")
}