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
    
    func toLog() -> String {
        var message = ""
        message += "id:\t\t\t\t\(id!),\n"
        message += "item_id:\t\t\(item_id!),\n"
        message += "information:\t\(information!),\n"
        message += "timestamp:\t\t\(timestamp!),\n"
        
        return message
    }
    
    func toString() -> String {
        var message = ""
        message += "[id: \(id!), "
        message += "item_id: \(item_id!), "
        message += "information: \(information!), "
        message += "timestamp: \(timestamp!)]"
        
        return message
    }
}
