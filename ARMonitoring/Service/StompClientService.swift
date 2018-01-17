//
//  StompClientService.swift
//  ARMonitoring
//
//  Created by Ludovic Marchand on 17/01/2018.
//  Copyright © 2018 Ludovic Marchand. All rights reserved.
//

import Foundation
import StompClientLib

class StompClientService: StompClientLibDelegate {
    
    static let sharedInstance = StompClientService();
    
    private var socketClient: StompClientLib = StompClientLib()
    
    private init() {
        let url = NSURL(string: "http://10.3.50.6:80/managerWS/websocket")!
        socketClient.openSocketWithURLRequest(request: NSURLRequest(url: url as URL), delegate: self)
    }
    
    func stompClient(client: StompClientLib!, didReceiveMessageWithJSONBody jsonBody: AnyObject?, withHeader header: [String : String]?, withDestination destination: String) {
        //
    }
    
    func stompClientJSONBody(client: StompClientLib!, didReceiveMessageWithJSONBody jsonBody: String?, withHeader header: [String : String]?, withDestination destination: String) {
        //
    }
    
    func stompClientDidDisconnect(client: StompClientLib!) {
        //
    }
    
    func stompClientDidConnect(client: StompClientLib!) {
        //
    }
    
    func serverDidSendReceipt(client: StompClientLib!, withReceiptId receiptId: String) {
        //
    }
    
    func serverDidSendError(client: StompClientLib!, withErrorMessage description: String, detailedErrorMessage message: String?) {
        //
    }
    
    func serverDidSendPing() {
        //
    }
    
    
}
