//
//  BeaconDaoImpl.swift
//  ARMonitoring
//
//  Created by Ludovic Marchand on 21/03/2018.
//  Copyright © 2018 Ludovic Marchand. All rights reserved.
//

import Foundation
import SQLite

class BeaconDaoImpl: BeaconDao {
    
    private let db: Connection
    private let beaconDto: BeaconSqliteDto
    
    init() {
        db = ConnectionFactory.instance.getConnection()
        beaconDto = BeaconSqliteDto()
    }
    
    func getAll() -> [Beacon] {
        var returnBeacons = [Beacon]()
        
        do {
            for row in try db.prepare(beaconDto.table) {
                let b = Beacon()
                b.id = try row.get(beaconDto.id)
                b.major = try Int(row.get(beaconDto.major))
                b.minor = try Int(row.get(beaconDto.minor))
                b.calibrationFactor = try row.get(beaconDto.calibrationFactor)
                
                returnBeacons.append(b)
            }
        } catch {
            print("BeaconGetAll error")
        }
        
        return returnBeacons
    }
    
    func getById(id: String) -> Beacon {
        let b = Beacon()
        
        do {
            if let row = try db.pluck(beaconDto.table.filter(beaconDto.id == id)) {
                b.id = try row.get(beaconDto.id)
                b.major = try Int(row.get(beaconDto.major))
                b.minor = try Int(row.get(beaconDto.minor))
                b.calibrationFactor = try row.get(beaconDto.calibrationFactor)
                
            }
        } catch {
            print("BeaconGetAll error")
        }
        
        return b
    }
    
    func getByMajorMinor(major: Int, minor: Int) -> Beacon {
        let b = Beacon()
        
        do {
            if let row = try db.pluck(
                    beaconDto.table
                        .filter(beaconDto.major == Int64(major))
                        .filter(beaconDto.minor == Int64(minor))
            ) {
                b.id = try row.get(beaconDto.id)
                b.major = try Int(row.get(beaconDto.major))
                b.minor = try Int(row.get(beaconDto.minor))
                b.calibrationFactor = try row.get(beaconDto.calibrationFactor)
            }
            
        } catch {
            print("BeaconGetAll error")
        }
        
        return b
    }
    
    func create(beacon: Beacon) -> Bool {
        do {
            let query = beaconDto.table.insert(
                beaconDto.id <- beacon.id,
                beaconDto.major <- Int64(beacon.major),
                beaconDto.minor <- Int64(beacon.minor),
                beaconDto.calibrationFactor <- beacon.calibrationFactor
            )
            try db.run(query)
            
            return true
        } catch {
            print("BeaconGetAll error")
            return false
        }
    }
}
