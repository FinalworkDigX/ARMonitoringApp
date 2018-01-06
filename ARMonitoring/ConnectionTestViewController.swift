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
import ObjectMapper

class ConnectionTestViewController: UIViewController, StompClientLibDelegate {
    
    private var socketClient: StompClientLib = StompClientLib()
    
    @IBOutlet weak var displayInfo: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.displayInfo.text = ""
        
        let url = NSURL(string: "http://10.3.50.6:80/dataLogWS/websocket")!
        socketClient.openSocketWithURLRequest(request: NSURLRequest(url: url as URL), delegate: self)
    }
    
    func stompClientDidConnect(client: StompClientLib!) {
        var message = "------------------------\n"
        message += "Websocket connected!\n"
        message += "------------------------\n"
        
        print(message)
        self.printToView(text: message)
        
        client.subscribe(destination: "/topic/dataLog")
        
    }
    
    func stompClientDidDisconnect(client: StompClientLib!) {
        var message = "------------------------\n"
        message += "Websocket diconnected!\n"
        message += "------------------------\n"
        
        print(message)
        self.printToView(text: message)
    }
    
    func stompClient(client: StompClientLib!, didReceiveMessageWithJSONBody jsonBody: AnyObject?, withHeader header: [String : String]?, withDestination destination: String) {
//        print("------------------------")
//        print("stompClient w/ jsonBody as anyObject")
////        print("========================")
////        if let test = Mapper<DataLog>().map(JSONObject: jsonBody) {
////            print(test.toJSONString(prettyPrint: true) as Any)
////        }
//        print("------------------------")
    }
    
    func stompClientJSONBody(client: StompClientLib!, didReceiveMessageWithJSONBody jsonBody: String?, withHeader header: [String : String]?, withDestination destination: String) {
        print("------------------------")
        print("stompClientJSONBody w/ jsonBody as string")
        print("========================")
        if let dl: DataLog = DataLog(JSONString: jsonBody!) {
            self.printToView(text: dl.toString())
        }
        print("------------------------")
    }
    
    func serverDidSendReceipt(client: StompClientLib!, withReceiptId receiptId: String) {
        print("------------------------")
        print("serverDidSendReceipt!")
        print(receiptId)
        print("------------------------")
    }
    
    func serverDidSendError(client: StompClientLib!, withErrorMessage description: String, detailedErrorMessage message: String?) {
        var message = "------------------------\n"
        message += "Websocket connected!\n"
        message += description + "\n"
        message += "------------------------\n"
        
        print(message)
        self.printToView(text: message)
    }
    
    func serverDidSendPing() {
        print("------------------------")
        print("Server Ping..")
        print("------------------------")
    }
    
    func printToView(text: String) {
        self.displayInfo.text.append(text + "\n-----------------------------\n")
    }
    
}
