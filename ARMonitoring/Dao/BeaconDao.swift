//
//  BeaconDao.swift
//  ARMonitoring
//
//  Created by Ludovic Marchand on 21/03/2018.
//  Copyright © 2018 Ludovic Marchand. All rights reserved.
//

import Foundation

protocol BeaconDao {
    func getAll() -> [Beacon]
    func getById(id: String) -> Beacon?
    func getByMajorMinor(major: Int, minor: Int) -> Beacon?
    func create(beacon: Beacon) -> Bool
    func update(id: String, beacon: Beacon) -> Bool
}
