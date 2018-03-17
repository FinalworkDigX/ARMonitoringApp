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
        delegate.stompTest(text: "-- OpenSocket --")
        delegate.connectionStatusUpdate(status: .CONNECTING)
    }
    
    func stompClientDidConnect(client: StompClientLib!) {
        client.subscribe(destination: "/topic/dataLog")
        
        delegate.connectionStatusUpdate(status: .CONNECTED)
    }
    
    func stompClientDidDisconnect(client: StompClientLib!) {
        delegate.stompTest(text: "-- STOMP disconnected --")
        
        // Temp stomp disconnect fix
        delegate.connectionStatusUpdate(status: .DISCONNECTED)
        self.openSocket()
    }
    
    func stompClient(client: StompClientLib!, didReceiveMessageWithJSONBody jsonBody: AnyObject?, withHeader header: [String : String]?, withDestination destination: String) {
        //
    }
    
    func stompClientJSONBody(client: StompClientLib!, didReceiveMessageWithJSONBody jsonBody: String?, withHeader header: [String : String]?, withDestination destination: String) {
        
        switch destination {
        case DataLog.destination:
            if let dl = DataLog(JSONString: jsonBody!) {
                delegate.stompDidReceiveJSON(dataLog: dl)
            }
            break;
        default:
            print("delegate error?")
            break;
        }
        
        
    }
    
    func serverDidSendReceipt(client: StompClientLib!, withReceiptId receiptId: String) {
        //
    }
    
    func serverDidSendError(client: StompClientLib!, withErrorMessage description: String, detailedErrorMessage message: String?) {
        delegate.stompTest(text: "-- Server error --")
        delegate.connectionStatusUpdate(status: .DISCONNECTED)
    }
    
    func serverDidSendPing() {
        //
    }
    
    func sendMessage() {
        
        if let channel = SessionService.sharedInstance.getUserInfo()?.channel {
            
            let beaconCalibDto = BeaconCalibrationDto(
                id: "1feb6e90-cb3a-44c6-9619-5ff3b6d6b340",
                calibrationFactor: 4.4
            )
            
            let beaconJson = beaconCalibDto.toJSON()
            
            socketClient.sendJSONForDict(
                dict: beaconJson as AnyObject,
                toDestination: "/beacon/calibrate/" + channel
            )

        }
    }
}
