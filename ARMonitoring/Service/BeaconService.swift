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
    
    func create(beacon: Beacon) -> Bool {
        return beaconDao.create(beacon: beacon)
    }
    
    func massInsertOrUpdate(beacons: [Beacon]) -> Int {
        for beacon in beacons {
            if let localBeacon = getById(id: beacon.id) {
                localBeacon.id = beacon.id
            }
        }
        return 0
    }
}
