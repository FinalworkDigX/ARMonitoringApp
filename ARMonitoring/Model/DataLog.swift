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
    static let destination: String = "/topic/dataLog"
    
    var id: String!
    var itemId: String!
    var information: [Information] = []
    var timestamp: CLong!
    
    required init?(map: Map) {
    }
    
    func mapping(map: Map) {
        id          <- map["id"]
        itemId      <- map["itemId"]
        information <- map["information"]
        timestamp   <- map["timestamp"]
    }
    
    func toLog() -> String {
        var message = ""
        message += "id:\t\t\t\t\(id!),\n"
        message += "itemId:\t\t\(itemId!),\n"
        message += "informationC:\t\(String(describing: information)),\n"
        message += "timestamp:\t\t\(timestamp!),\n"
        
        return message
    }
    
    func toString() -> String {
        var message = ""
        message += "[id: \(id!), "
        message += "itemId: \(itemId!), "
        message += "information count: \(String(describing: information)), "
        message += "timestamp: \(timestamp!)]"
        
        return message
    }
}
