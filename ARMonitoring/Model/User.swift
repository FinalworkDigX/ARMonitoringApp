//
//  User.swift
//  ARMonitoring
//
//  Created by Ludovic Marchand on 15/03/2018.
//  Copyright © 2018 Ludovic Marchand. All rights reserved.
//

import Foundation
import ObjectMapper

class User: Mappable {
    var email: String?
    var password: String?
    var access_token: String?
    var id_token: String?
    
    required init?(map: Map) {
    }
    
    func mapping(map: Map) {
        access_token    <- map["access_token"]
        id_token    <- map["id_token"]
    }
    
    func toString() -> String {
        var message: String = ""
        message += "[name: \(String(describing: access_token)), "
        message += "data: \(String(describing: id_token))"
        
        return message
    }
}
