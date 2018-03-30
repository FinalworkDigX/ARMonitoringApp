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
    
    public static let API_URL: URL = URL(string: "https://fw.ludovicmarchand.be/managerWS/websocket")!
    public static let BEACON_UUID: String = "4AFECBF0-E8A4-0135-7D93-7E27D0FEF627"
    
    private var userAccount: User?
    public var userSet: Bool!
    
    private init() {
        userSet = false
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
