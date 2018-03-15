//
//  AuthenticationService.swift
//  ARMonitoring
//
//  Created by Ludovic Marchand on 15/03/2018.
//  Copyright © 2018 Ludovic Marchand. All rights reserved.
//

import Foundation
import Alamofire
import ObjectMapper

class AuthenticationService {
    
    let headers: HTTPHeaders = [
        "Accept": "application/json"
    ]
    
    func authenticate(url: String, loginDto: LoginDto, success: @escaping (User) -> (), failed: (NSError)->()) {
        
        let testParameters: Parameters = [
            "email": loginDto.email,
            "password": loginDto.password
        ]
        
        Alamofire.request(
            url,
            method: .post,
            parameters: testParameters,
            encoding: JSONEncoding.default,
            headers: headers
            )
            .responseJSON { response in
                
                if let json = response.result.value {
                    if let user: User = Mapper<User>().map(JSONObject: json) {
                        print(user.toString())
                        success(user)
                    }
                }
                
                // print(response)
                
                // print(userResponse)
        }
    }
}

