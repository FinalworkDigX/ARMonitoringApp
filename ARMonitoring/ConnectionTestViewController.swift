//
//  ConnectionTestViewController.swift
//  ARMonitoring
//
//  Created by Ludovic Marchand on 05/01/2018.
//  Copyright © 2018 Ludovic Marchand. All rights reserved.
//

import Foundation
import UIKit
import StompClientLib

class ConnectionTestViewController: UIViewController, StompClientLibDelegate {
    
    private var socketClient: StompClientLib = StompClientLib()
    
    @IBOutlet weak var displayInfo: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let url = NSURL(string: "http://10.3.50.6:80/dataLogWS/websocket")!
        socketClient.openSocketWithURLRequest(request: NSURLRequest(url: url as URL), delegate: self)
    }
    
    func stompClient(client: StompClientLib!, didReceiveMessageWithJSONBody jsonBody: AnyObject?, withHeader header: [String : String]?, withDestination destination: String) {
        print("------------------------")
        print("stompClient w/ jsonBody as anyObject")
        print("========================")
        print(jsonBody as! String)
        print("------------------------")
    }
    
    func stompClientJSONBody(client: StompClientLib!, didReceiveMessageWithJSONBody jsonBody: String?, withHeader header: [String : String]?, withDestination destination: String) {
        print("------------------------")
        print("stompClient w/ jsonBody as string")
        print("========================")
        print(jsonBody as Any)
        print("------------------------")
    }
    
    func stompClientDidDisconnect(client: StompClientLib!) {
        print("------------------------")
        print("Websocket disconnected!")
        print("------------------------")
    }
    
    func stompClientDidConnect(client: StompClientLib!) {
        print("------------------------")
        print("Websocket connected!")
        print("------------------------")
        
        client.subscribe(destination: "topic/dataLog")
    }
    
    func serverDidSendReceipt(client: StompClientLib!, withReceiptId receiptId: String) {
        print("------------------------")
        print("serverDidSendReceipt!")
        print(receiptId)
        print("------------------------")
    }
    
    func serverDidSendError(client: StompClientLib!, withErrorMessage description: String, detailedErrorMessage message: String?) {
        print("------------------------")
        print("Websocket connected!")
        print(description)
        print("------------------------")
    }
    
    func serverDidSendPing() {
        print("------------------------")
        print("Server Ping..")
        print("------------------------")
    }
    
}
