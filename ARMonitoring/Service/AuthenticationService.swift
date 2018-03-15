//
//  AuthenticationService.swift
//  ARMonitoring
//
//  Created by Ludovic Marchand on 15/03/2018.
//  Copyright © 2018 Ludovic Marchand. All rights reserved.
//

import Foundation
import Alamofire

class AuthenticationService {
    
    func authenticate(url: String, success: (User) -> (), failed: (NSError)->()) {
        
        let testParameters: Parameters = [
            "email": "*******",
            "password": "*******"
        ]
        Alamofire.request(url, method: .post, parameters: testParameters, encoding: JSONEncoding.default).responseJSON { response in
            
            if let json = response.result.value {
                print("JSON : \(json)")
            }
            // print(response)
            
            // print(userResponse)
        }
    }
}
