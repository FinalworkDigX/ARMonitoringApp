//
//  Room.swift
//  ARMonitoring
//
//  Created by Ludovic Marchand on 18/01/2018.
//  Copyright © 2018 Ludovic Marchand. All rights reserved.
//

import Foundation
import ObjectMapper

class Room: Mappable {
    var id: String!
    var name: String!
    var description: String!
    var item_list: [Item] = []
    
    required init?(map: Map) {}
    
    func mapping(map: Map) {
        id          <- map["id"]
        name        <- map["name"]
        description <- map["description"]
        item_list   <- map["item_list"]
        
        name.captitalizeFirstLetter()
    }
    
    func toString() -> String {
        var message: String = ""
        message += "[id: \(id), "
        message += "name: \(name), "
        message += "description: \(description), "
        message += "item_list: \(item_list)]"
        
        return message
    }
}
