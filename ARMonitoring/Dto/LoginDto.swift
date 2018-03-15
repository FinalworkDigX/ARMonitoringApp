//
//  LoginDto.swift
//  ARMonitoring
//
//  Created by Ludovic Marchand on 15/03/2018.
//  Copyright © 2018 Ludovic Marchand. All rights reserved.
//

import Foundation

class LoginDto {
    let email: String!
    let password: String!
    
    init(email: String, password: String) {
        self.email = email
        self.password = password
    }
}
