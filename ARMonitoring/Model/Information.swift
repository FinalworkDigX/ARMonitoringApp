//
//  DLInformation.swift
//  ARMonitoring
//
//  Created by Ludovic Marchand on 18/01/2018.
//  Copyright © 2018 Ludovic Marchand. All rights reserved.
//

import Foundation
import ObjectMapper

class Information: Mappable {
    
    var name: String!
    var data: String!
    var index: CLong!
    
    required init?(map: Map) {
    }
    
    func mapping(map: Map) {
        name    <- map["name"]
        data    <- map["data"]
        index   <- map["index"]
    }
    
    func toString() -> String {
        var message: String = ""
        message += "[name: \(name), "
        message += "data: \(data), "
        message += "index: \(index)]"
        
        return message
    }
}
