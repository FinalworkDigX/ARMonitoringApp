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
    
    public enum ConnectionStatus {
        case CONNECTED, DISCONNECTED, CONNECTING
    }
    
    private var socketClient: StompClientLib = StompClientLib()
    private var delegate: StompClientDelegate
    private var socketUrlRequest: NSURLRequest
    
    init(delegate: StompClientDelegate, socketUrl: URL) {
        self.delegate = delegate
        self.socketUrlRequest = NSURLRequest(url: socketUrl)
        delegate.connectionStatusUpdate(status: .DISCONNECTED)
    }

    func openSocket() {
        socketClient.openSocketWithURLRequest(request: self.socketUrlRequest, delegate: self)
        delegate.stompTest(text: "OpenSOcket----")
        delegate.connectionStatusUpdate(status: .CONNECTING)
    }
    
    func stompClientDidConnect(client: StompClientLib!) {
        client.subscribe(destination: "/topic/dataLog")
        
        delegate.connectionStatusUpdate(status: .CONNECTED)
    }
    
    func stompClientDidDisconnect(client: StompClientLib!) {
        delegate.stompTest(text: "STOMP discopnnected----")
        
        // Temp stomp disconnect fix
        delegate.connectionStatusUpdate(status: .DISCONNECTED)
        self.openSocket()
    }
    
    func stompClient(client: StompClientLib!, didReceiveMessageWithJSONBody jsonBody: AnyObject?, withHeader header: [String : String]?, withDestination destination: String) {
        //
    }
    
    func stompClientJSONBody(client: StompClientLib!, didReceiveMessageWithJSONBody jsonBody: String?, withHeader header: [String : String]?, withDestination destination: String) {

        if let dl = DataLog(JSONString: jsonBody!) {
            delegate.stompDidReceiveJSON(dataLog: dl)
        }
        
    }
    
    func serverDidSendReceipt(client: StompClientLib!, withReceiptId receiptId: String) {
        //
    }
    
    func serverDidSendError(client: StompClientLib!, withErrorMessage description: String, detailedErrorMessage message: String?) {
        delegate.stompTest(text: "server did send error----")
        delegate.connectionStatusUpdate(status: .DISCONNECTED)
    }
    
    func serverDidSendPing() {
        //
    }
}
