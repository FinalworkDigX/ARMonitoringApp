//
//  BeaconRestService.swift
//  ARMonitoring
//
//  Created by Ludovic Marchand on 21/03/2018.
//  Copyright © 2018 Ludovic Marchand. All rights reserved.
//


import Foundation
import Alamofire
import ObjectMapper

class BeaconRestService {
    
    let headers: HTTPHeaders = [
        "Accept": "application/json"
    ]
    
    let baseUrl: String = "https://fw.ludovicmarchand.be/v1/"
    
    func getAllBeacons(success: @escaping ([Beacon]) -> (), failed: @escaping (NSError)->()) {
        
        Alamofire.request("\(self.baseUrl)/beacon").responseJSON { response in
            
            if let json = response.result.value {
                if let beacons: Array<Beacon> = Mapper<Beacon>().mapArray(JSONObject: json) {
                    success(beacons)
                }
                else {
                    failed(NSError(
                        domain: "EHB.ARMonitoring",
                        code: -15,
                        userInfo: [NSLocalizedFailureReasonErrorKey: "error.authentication.mapping.error"]))
                }
            }
            else {
                failed(NSError(
                    domain: "EHB.ARMonitoring",
                    code: -20,
                    userInfo: [NSLocalizedFailureReasonErrorKey: "error.authentication.connection.error"]))
            }
        }
    }
}


