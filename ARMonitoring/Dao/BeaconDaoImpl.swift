//
//  BeaconDaoImpl.swift
//  ARMonitoring
//
//  Created by Ludovic Marchand on 21/03/2018.
//  Copyright © 2018 Ludovic Marchand. All rights reserved.
//

// https://github.com/stephencelis/SQLite.swift
import Foundation
import SQLite
import Trilateration3D

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
                returnBeacons.append(try self.rowToModel(row))
            }
        } catch {
            print("BeaconGetAll error: \(error)")
        }
        
        return returnBeacons
    }
    
    func getById(id: String) -> Beacon? {
        do {
            if let row = try db.pluck(beaconDto.table.filter(beaconDto.id == id)) {
                return try self.rowToModel(row)
            }
        } catch {
            print("BeaconGetById error: \(error)")
        }
        
        return nil
    }
    
    func getByMajorMinor(major: Int, minor: Int) -> Beacon? {
        do {
            if let row = try db.pluck(
                    beaconDto.table
                        .filter(beaconDto.major == Int64(major))
                        .filter(beaconDto.minor == Int64(minor))
            ) {
                return try self.rowToModel(row)
            }
            
        } catch {
            print("BeaconGetMajorMinor error: \(error)")
        }
        
        return nil
    }
    
    func create(beacon: Beacon) -> Bool {
        do {
            try db.run(beaconDto.table.insert(
                beaconDto.id <- beacon.id,
                beaconDto.major <- Int64(beacon.major),
                beaconDto.minor <- Int64(beacon.minor),
                beaconDto.calibrationFactor <- Int64(beacon.calibrationFactor),
                beaconDto.lastUpdated <- beacon.lastUpdated
            ))

            return true
        } catch {
            print("BeaconCreate error: \(error)")
            return false
        }
    }
    
    func update(id: String, beacon: Beacon) -> Bool {
        do {
            let query = beaconDto.table.filter(beaconDto.id == id)
            
            try db.run(query.update(
                beaconDto.major <- Int64(beacon.major),
                beaconDto.minor <- Int64(beacon.minor),
                beaconDto.calibrationFactor <- Int64(beacon.calibrationFactor),
                beaconDto.lastUpdated <- beacon.lastUpdated
            ))
            
            return true
        } catch {
            print("BeaconUpdate error: \(error)")
            return false
        }
    }
    
    private func rowToModel(_ row: Row) throws -> Beacon {
        let b = Beacon()
        b.id = try row.get(beaconDto.id)
        b.major = try Int(row.get(beaconDto.major))
        b.minor = try Int(row.get(beaconDto.minor))
        b.calibrationFactor = try Int(row.get(beaconDto.calibrationFactor))
        b.lastUpdated = try row.get(beaconDto.lastUpdated)
        
        return b
    }
}
