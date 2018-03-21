//
//  DBSyncService.swift
//  ARMonitoring
//
//  Created by Ludovic Marchand on 21/03/2018.
//  Copyright © 2018 Ludovic Marchand. All rights reserved.
//

import Foundation

class DBSyncService {
    
    private let beaconDao: BeaconDao
    
    init() {
        self.beaconDao = BeaconDaoImpl()
    }
    
    func createOrUpdateAllBeacons() {
        
    }
    
}
