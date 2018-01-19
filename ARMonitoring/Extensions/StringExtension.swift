//
//  StringExtension.swift
//  ARMonitoring
//
//  Created by Ludovic Marchand on 18/01/2018.
//  Copyright © 2018 Ludovic Marchand. All rights reserved.
//
//  https://stackoverflow.com/a/26306372

import Foundation

extension String {
    private func capitalizingFirstLetter() -> String {
        return prefix(1).uppercased() + dropFirst()
    }
    
    mutating func captitalizeFirstLetter() {
        self = self.capitalizingFirstLetter()
    }
}
