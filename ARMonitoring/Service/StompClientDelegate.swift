//
//  StompClientDelegate.swift
//  ARMonitoring
//
//  Created by Ludovic Marchand on 18/01/2018.
//  Copyright © 2018 Ludovic Marchand. All rights reserved.
//

protocol StompClientDelegate {
    func didReceiveJSON(dataLog: DataLog)
    func test(text: String)
}
