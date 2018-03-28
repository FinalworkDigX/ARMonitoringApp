//
//  StompClientService.swift
//  ARMonitoring
//
//  Created by Ludovic Marchand on 17/01/2018.
//  Copyright © 2018 Ludovic Marchand. All rights reserved.
//

import Foundation
import StompClientLib
import ObjectMapper

//TODO: 'didCloseWithCode 1001, reason: Optional("Stream end encountered")'

class StompClientService: StompClientLibDelegate {
    
    public enum ConnectionStatus {
        case CONNECTED, DISCONNECTED, CONNECTING
    }
    
    private var socketClient: StompClientLib = StompClientLib()
    private var delegate: StompClientDelegate
    private var socketUrlRequest: NSURLRequest
    private let channel: String
    
    private let rfarDestination: String
    
    init(delegate: StompClientDelegate, socketUrl: URL) {
        self.delegate = delegate
        self.socketUrlRequest = NSURLRequest(url: socketUrl)
        delegate.connectionStatusUpdate(status: .DISCONNECTED)
        
        if let channel = SessionService.sharedInstance.getUserInfo()?.channel {
            self.channel = channel
            self.rfarDestination = "\(RoomForARDto.destination)\(channel)"
        }
        else {
            self.channel = "----"
            self.rfarDestination = "----"
        }
    }

    func openSocket() {
        socketClient.openSocketWithURLRequest(request: self.socketUrlRequest, delegate: self)
        delegate.stompText(text: "-- OpenSocket --")
        delegate.connectionStatusUpdate(status: .CONNECTING)
    }
    
    func stompClientDidConnect(client: StompClientLib!) {
        client.subscribe(destination: "/topic/dataLog")
        client.subscribe(destination: "/topic/beacon")
        client.subscribe(destination: "/topic/room/\(channel)")
        
        delegate.connectionStatusUpdate(status: .CONNECTED)
    }
    
    func stompClientDidDisconnect(client: StompClientLib!) {
        delegate.stompText(text: "-- STOMP disconnected --")
        
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
                delegate.stompDataLogGet(dataLog: dl)
            }
            break;
        case Beacon.destination:
            if let beacons: Array<Beacon> = Mapper<Beacon>().mapArray(JSONString: jsonBody!) {
                delegate.stompBeaconsGet(beacons: beacons)
            }
            break;
        case rfarDestination:
            if let rfar = RoomForARDto(JSONString: jsonBody!) {
                delegate.stompRoomGet(roomForAR: rfar)
            }
            print("in roomAR case")
            break;
        default:
            print("Destination not dound: \(destination);")
            break;
        }
        
        
    }
    
    func serverDidSendReceipt(client: StompClientLib!, withReceiptId receiptId: String) {
        //
    }
    
    func serverDidSendError(client: StompClientLib!, withErrorMessage description: String, detailedErrorMessage message: String?) {
        delegate.stompText(text: "-- Server error --")
        delegate.connectionStatusUpdate(status: .DISCONNECTED)
    }
    
    func serverDidSendPing() {
        //
    }
    
    func sendMessage(destination: [String], json: [String : Any] = [String : Any](), usingPrivateChannel: Bool = false) {
        var destination_ = destination[0]
        if usingPrivateChannel {
            destination_ += "/\(channel)"
            if destination.count > 1 {
                destination_ += destination[1]
            }
        }
        
        socketClient.sendJSONForDict(
            dict: json as AnyObject,
            toDestination:  destination_
        )
    }
}
