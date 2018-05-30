//
//  SessionService.swift
//  ARMonitoring
//
//  Created by Ludovic Marchand on 16/03/2018.
//  Copyright © 2018 Ludovic Marchand. All rights reserved.
//

import Foundation

class SessionService {
    static let sharedInstance = SessionService()
    
    public let API_URL: String!
    public let WS_URL: URL!
    public let BEACON_UUID: String!
    
    private var userAccount: User?
    public var userSet: Bool!
    
    private init() {
        userSet = false
        
        if let path = Bundle.main.path(forResource: "Properties", ofType: "plist"),
            let myDict: NSDictionary = NSDictionary(contentsOfFile: path),
            let api_url: String = myDict.object(forKey: "api_url") as? String,
            let ws_url: String = myDict.object(forKey: "ws_url") as? String,
            let beacon_uuid: String = myDict.object(forKey: "beacon_uuid") as? String
        {
            self.API_URL = api_url
            self.WS_URL = URL(string: ws_url)
            self.BEACON_UUID = beacon_uuid
        }
        else {
            self.API_URL = ""
            self.WS_URL = URL(string: "")
            self.BEACON_UUID = ""
        }
    }
    
    public func setUserAccount(user: User) {
        if !userSet {
            self.userAccount = user
            self.userSet = true
        }
    }
    
    func getUserInfo() -> UserInfo? {
        return userAccount?.userInfo
    }
    
    func getAccessToken() -> String? {
        return userAccount?.accessToken
    }
    
    func getIdToken() -> String? {
        return userAccount?.idToken
    }
    
}
