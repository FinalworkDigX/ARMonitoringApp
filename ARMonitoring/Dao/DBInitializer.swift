//
//  DBInitializer.swift
//  ARMonitoring
//
//  Created by Ludovic Marchand on 20/03/2018.
//  Copyright © 2018 Ludovic Marchand. All rights reserved.
//

import Foundation
import SQLite

class DBInitializer {
    
    var db: Connection!
    
    init() {
        db = ConnectionFactory.instance.getConnection()
        
        do {
            try createTables()
        }
        catch {
            print("ERROR- DBInitializer")
        }
    }
    
    func createTables() throws {
        let beacon = BeaconSqliteDto()
        
        try db.run(beacon.table.create(ifNotExists: true) { t in
            t.column(beacon.id, primaryKey: true)
            t.column(beacon.roomId)
            t.column(beacon.major)
            t.column(beacon.minor, unique: true)
            t.column(beacon.calibrationFactor)
            t.column(beacon.lastUpdated)
        })
    }
    
    
}
