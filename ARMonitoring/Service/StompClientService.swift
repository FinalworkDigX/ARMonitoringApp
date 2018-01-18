//
//  StompClientService.swift
//  ARMonitoring
//
//  Created by Ludovic Marchand on 17/01/2018.
//  Copyright © 2018 Ludovic Marchand. All rights reserved.
//

import Foundation
import StompClientLib

//TODO: 'didCloseWithCode 1001, reason: Optional("Stream end encountered")'

class StompClientService: StompClientLibDelegate {
    
    private var socketClient: StompClientLib = StompClientLib()
    public var delegate: StompClientDelegate?

    func openSocket(withUrl wsurl: URL) {
        socketClient.openSocketWithURLRequest(request: NSURLRequest(url: wsurl), delegate: self)
        delegate?.test(text: "OpenSOcket----")
    }
    
    func stompClient(client: StompClientLib!, didReceiveMessageWithJSONBody jsonBody: AnyObject?, withHeader header: [String : String]?, withDestination destination: String) {
        //
    }
    
    func stompClientJSONBody(client: StompClientLib!, didReceiveMessageWithJSONBody jsonBody: String?, withHeader header: [String : String]?, withDestination destination: String) {
        
        if let dl = DataLog(JSONString: jsonBody!) {
            delegate?.didReceiveJSON(dataLog: dl)
        }
        
    }
    
    func stompClientDidDisconnect(client: StompClientLib!) {
        //
    }
    
    func stompClientDidConnect(client: StompClientLib!) {
        client.subscribe(destination: "/topic/dataLog")
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
