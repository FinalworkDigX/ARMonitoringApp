//
//  AuthenticationRestService.swift
//  ARMonitoring
//
//  Created by Ludovic Marchand on 15/03/2018.
//  Copyright © 2018 Ludovic Marchand. All rights reserved.
//

import Foundation
import Alamofire
import ObjectMapper

class AuthenticationRestService {
    
    let headers: HTTPHeaders = [
        "Accept": "application/json"
    ]
    
    func authenticate(loginDto: LoginDto, success: @escaping (User) -> (), failed: @escaping (NSError)->()) {
        
        let testParameters: Parameters = [
            "email": loginDto.email,
            "password": loginDto.password
        ]
        
        Alamofire.request(
            "\(SessionService.API_URL)/auth/login",
            method: .post,
            parameters: testParameters,
            encoding: JSONEncoding.default,
            headers: headers
            )
            .responseJSON { response in
                
                if let json = response.result.value {
                    if let user: User = Mapper<User>().map(JSONObject: json) {
                        if user.accessToken != nil || user.idToken != nil {
                           success(user)
                        }
                        else {
                            failed(NSError(
                                domain: "EHB.ARMonitoring",
                                code: -10,
                                userInfo: [NSLocalizedFailureReasonErrorKey: "error.authentication.wrong.credentials"]))
                        }
                    }
                    else {
                        failed(NSError(
                            domain: "EHB.ARMonitoring",
                            code: -15,
                            userInfo: [NSLocalizedFailureReasonErrorKey: "error.authentication.mapping.error"]))
                    }
                }
                else {
                    failed(NSError(
                        domain: "EHB.ARMonitoring",
                        code: -20,
                        userInfo: [NSLocalizedFailureReasonErrorKey: "error.authentication.connection.error"]))
                }
        }
    }
}

