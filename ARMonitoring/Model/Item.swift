//
//  Item.swift
//  ARMonitoring
//
//  Created by Ludovic Marchand on 18/01/2018.
//  Copyright © 2018 Ludovic Marchand. All rights reserved.
//

import Foundation
import SceneKit
import ObjectMapper

class Item: Mappable {
    var id: String!
    var name: String!
    var itemId: String!
    var location: SCNVector3 = SCNVector3()
    var roomId: String!
    
    required init?(map: Map) {}
    
    func mapping(map: Map) {
        id          <- map["id"]
        itemId      <- map["itemId"]
        name        <- map["name"]
        location.x  <- map["location.x"]
        location.y  <- map["location.y"]
        location.z  <- map["location.z"]
        roomId      <- map["roomId"]
        
        name.captitalizeFirstLetter()
    }
    
    func toString() -> String {
        var message: String = ""
        message += "[id: \(id), "
        message += "itemId: \(itemId), "
        message += "name: \(name), "
        message += "location: [x: \(location.x), y:\(location.y), z:\(location.z)], "
        message += "roomId: \(roomId)]"
        
        return message
    }
}
