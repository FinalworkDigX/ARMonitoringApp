//
//  BeaconService.swift
//  ARMonitoring
//
//  Created by Ludovic Marchand on 26/03/2018.
//  Copyright © 2018 Ludovic Marchand. All rights reserved.
//

import Foundation

class BeaconService {
    
    private let beaconDao: BeaconDao
    
    init() {
        self.beaconDao = BeaconDaoImpl()
    }
    
    func getAll() -> [Beacon] {
        return beaconDao.getAll()
    }
    
    func getById(id: String) -> Beacon? {
        return beaconDao.getById(id: id)
    }
    
    func getByMajorMinor(major: Int, minor: Int) -> Beacon? {
        return beaconDao.getByMajorMinor(major: major, minor: minor)
    }
    
    func create(_ beacon: Beacon) -> Bool {
        return beaconDao.create(beacon: beacon)
    }
    
    func update(id: String, beacon: Beacon) -> Bool {
        return beaconDao.update(id: id, beacon: beacon)
    }
    
    func massInsertOrUpdate(_ beacons: [Beacon]) -> () {
        for beacon in beacons {
            if let _ = getById(id: beacon.id) {
                print("update: \(beacon.id)")
                let _ = update(id: beacon.id, beacon: beacon)
            }
            else {
                print("create: \(beacon.id)")
                let _ = create(beacon)
            }
        }
    }
}
