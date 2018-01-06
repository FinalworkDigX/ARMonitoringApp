//
//  DataLog.swift
//  ARMonitoring
//
//  Created by Ludovic Marchand on 06/01/2018.
//  Copyright © 2018 Ludovic Marchand. All rights reserved.
//

import Foundation
import ObjectMapper

class DataLog: Mappable {
    
    var id: String!
    var item_id: String!
    var information: String!
    // var information: [String : Any] = [:]
    var timestamp: CLong!
    
//    init() { }
    required init?(map: Map) {}
    
    func mapping(map: Map) {
        id          <- map["id"]
        item_id     <- map["item_id"]
        information <- map["information"]
        timestamp   <- map["timestamp"]
    }
    
    func toString() -> String {
        return String("id: \(id), item_id: \(item_id), information: \(information), timestamp: \(timestamp)")
    }
}
