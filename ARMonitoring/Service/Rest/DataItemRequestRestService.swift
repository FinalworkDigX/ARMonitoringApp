//
//  DataItemRequestRestService.swift
//  ARMonitoring
//
//  Created by Ludovic Marchand on 10/05/2018.
//  Copyright © 2018 Ludovic Marchand. All rights reserved.
//

import Foundation
import Alamofire
import ObjectMapper

class DataItemRequestRestService {
    
    let headers: HTTPHeaders = [
        "Accept": "application/json"
    ]
    
    func sendRequest(dataItemRequest: DataItemRequestDto, success: @escaping (Bool) -> (), failed: @escaping (NSError)->()) {
        
        let testParameters: Parameters = [
            "beaconId": dataItemRequest.beaconId,
            "dataItemName": dataItemRequest.dataItemName,
            "requester": dataItemRequest.requester
        ]
        if let api_url = SessionService.sharedInstance.API_URL {
            Alamofire.request(
                "\(api_url)/request",
                method: .post,
                parameters: testParameters,
                encoding: JSONEncoding.default,
                headers: headers
                )
                .responseJSON { response in
                    if let statusCode = response.response?.statusCode {
                        if statusCode == 200 {
                            success(true)
                        }
                        else {
                            failed(NSError(
                                domain: "EHB.ARMonitoring",
                                code: -15,
                                userInfo: [NSLocalizedFailureReasonErrorKey: "error.request.wrong.status.code"]))
                        }
                    }
                    else {
                        failed(NSError(
                            domain: "EHB.ARMonitoring",
                            code: -20,
                            userInfo: [NSLocalizedFailureReasonErrorKey: "error.request.connection.error"]))
                    }
            }
        } else {
            failed(NSError(
                domain: "EHB.ARMonitoring",
                code: -100,
                userInfo: [NSLocalizedFailureReasonErrorKey: "error.project.plist.not.set"]))
        }
    }
}
