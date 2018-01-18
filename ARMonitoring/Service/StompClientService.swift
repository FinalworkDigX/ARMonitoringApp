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
    private var delegate: StompClientDelegate
    private var socketUrlRequest: NSURLRequest
    
    init(delegate: StompClientDelegate, socketUrl: URL) {
        self.delegate = delegate
        self.socketUrlRequest = NSURLRequest(url: socketUrl)
    }

//    func openSocket(withUrl wsurl: URL) {
//        socketClient.openSocketWithURLRequest(request: NSURLRequest(url: wsurl), delegate: self)
//        delegate.test(text: "OpenSOcket----")
//    }

    func openSocket() {
        socketClient.openSocketWithURLRequest(request: self.socketUrlRequest, delegate: self)
        delegate.stompTest(text: "OpenSOcket----")
    }
    
    func stompClient(client: StompClientLib!, didReceiveMessageWithJSONBody jsonBody: AnyObject?, withHeader header: [String : String]?, withDestination destination: String) {
        //
    }
    
    func stompClientJSONBody(client: StompClientLib!, didReceiveMessageWithJSONBody jsonBody: String?, withHeader header: [String : String]?, withDestination destination: String) {
        
        if let dl = DataLog(JSONString: jsonBody!) {
            delegate.stompDidReceiveJSON(dataLog: dl)
        }
        
    }
    
    func stompClientDidDisconnect(client: StompClientLib!) {
        delegate.stompTest(text: "STOMP discopnnected----")
        
        // Temp stomp disconnect fix
        self.openSocket()
    }
    
    func stompClientDidConnect(client: StompClientLib!) {
        client.subscribe(destination: "/topic/dataLog")
    }
    
    func serverDidSendReceipt(client: StompClientLib!, withReceiptId receiptId: String) {
        //
    }
    
    func serverDidSendError(client: StompClientLib!, withErrorMessage description: String, detailedErrorMessage message: String?) {
        delegate.stompTest(text: "server did send error----")
    }
    
    func serverDidSendPing() {
        //
    }
}
