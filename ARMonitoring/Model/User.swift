//
//  User.swift
//  ARMonitoring
//
//  Created by Ludovic Marchand on 15/03/2018.
//  Copyright © 2018 Ludovic Marchand. All rights reserved.
//

import Foundation
import ObjectMapper
import JWTDecode

class User: Mappable {
    var accessToken: String!
    var idToken: String!
    var userInfo: UserInfo!
    
    let transform = TransformOf<UserInfo, String>(fromJSON: {(value: String?) -> UserInfo? in
        let jwt = try? decode(jwt: value!)
        
        if let body = jwt?.body {
            return UserInfo(JSON: body)
        }
        
        return nil
    }, toJSON: { (value: UserInfo?) -> String? in
        
        if let value = value {
            return value.toJSONString()
        }
        
        return nil
    })
    
    required init?(map: Map) {
    }
    
    func mapping(map: Map) {
        accessToken <- map["access_token"]
        idToken     <- map["id_token"]
        userInfo    <- (map["id_token"], transform)
    }
    
    func toString() -> String {
        var message: String = ""
        message += "[access_token: \(accessToken), "
        message += "id_token: \(idToken)]"
        
        return message
    }
}
