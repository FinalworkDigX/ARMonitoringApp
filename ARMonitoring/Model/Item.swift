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
    var location: SCNVector3 = SCNVector3()
    //var rowList: [String] = []
    var roomId: String!
    
    required init?(map: Map) {}
    
    func mapping(map: Map) {
        id          <- map["id"]
        name        <- map["name"]
        location.x  <- map["location.x"]
        location.y  <- map["location.y"]
        location.z  <- map["location.z"]
        //rowList    <- map["rowList"]
        roomId     <- map["roomId"]
        
        name.captitalizeFirstLetter()
    }
    
    func toString() -> String {
        var message: String = ""
        message += "[id: \(id), "
        message += "name: \(name), "
        message += "location: [x: \(location.x), y:\(location.y), z:\(location.z)], "
        //message += "rowList: \(rowList), "
        message += "roomId: \(roomId)]"
        
        return message
    }
}
