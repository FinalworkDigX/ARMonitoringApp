//
//  ConnectionFactory.swift
//  ARMonitoring
//
//  Created by Ludovic Marchand on 21/03/2018.
//  Copyright © 2018 Ludovic Marchand. All rights reserved.
//

//https://github.com/stephencelis/SQLite.swift/blob/master/Documentation/Index.md#getting-started

import Foundation
import SQLite

class ConnectionFactory {
    static let instance = ConnectionFactory()
    
    private let connection: Connection!
    
    private init() {
        do {
            let path = NSSearchPathForDirectoriesInDomains(
                .documentDirectory, .userDomainMask, true
                ).first!
            
            connection = try Connection("\(path)/db.sqlite3")
        }
        catch {
            connection = nil
            print("ERROR- DBInitializer")
        }
    }
    
    func getConnection() -> Connection {
        return connection
    }
}
