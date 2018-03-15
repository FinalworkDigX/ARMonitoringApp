//
//  UserInfo.swift
//  ARMonitoring
//
//  Created by Ludovic Marchand on 15/03/2018.
//  Copyright © 2018 Ludovic Marchand. All rights reserved.
//

import Foundation
import ObjectMapper

class UserInfo: Mappable {
    var id: String!
    var email: String!
    var picture: String!
    var channel: String!
    
    required init?(map: Map) {
    }
    
    func mapping(map: Map) {
        id      <- map["sub"]
        email   <- map["email"]
        picture <- map["picture"]
        channel <- map["https://finalwork.be/channel", delimiter: "->"]
    }
    
    func toString() -> String {
        var message: String = ""
        message += "[id: \(id), "
        message += "email: \(email), "
        message += "picture: \(picture), "
        message += "channel: \(channel)]"
        
        return message
    }
}
