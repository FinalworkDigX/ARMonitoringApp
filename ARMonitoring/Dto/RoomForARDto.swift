//
//  RoomForARDto.swift
//  ARMonitoring
//
//  Created by Ludovic Marchand on 27/03/2018.
//  Copyright © 2018 Ludovic Marchand. All rights reserved.
//

import Foundation
import ObjectMapper
import Trilateration3D

class RoomForARDto: Mappable {
    static let destination: String = "/topic/room"
    var roomLocation: Vector3!
    var room: Room!
    
    init() {
        room = Room()
    }
    
    required init?(map: Map) {
    }
    
    func mapping(map: Map) {
        roomLocation    <- (map["roomLocation"], transform)
        room            <- map["roomInfo"]
        room.itemList   <- map["itemList"]
    }
    
    let transform = TransformOf<Vector3, [String : Any]>(fromJSON: { (value: [String : Any]?) -> Vector3? in
        // transform value from String? to Int?
        if let value: [String : Any] = value {
            return Vector3(fromJson: value)
        }
        
        return nil
    }, toJSON: { (value: Vector3?) -> [String : Any]? in
        // transform value from Int? to String?
        if let value = value {
            return value.toJsonArray()
        }
        return nil
    })
    
    // Workarround without true north (1 item / beacon)
    func getFirstItemId() -> String? {
        return self.room.itemList.first?.itemId
    }
}
