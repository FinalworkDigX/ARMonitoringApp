//
//  ModalMenuViewController.swift
//  ARMonitoring
//
//  Created by Ludovic Marchand on 10/05/2018.
//  Copyright © 2018 Ludovic Marchand. All rights reserved.
//

import UIKit

class ModalMenuViewController: UIViewController {
    
    var beaconLocationClient: BeaconLocationService?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.isOpaque = false
        view.backgroundColor = .clear
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func cancelButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "requestNewItemSegue",
            let destinationVC = segue.destination as? RequestViewController {
            
            destinationVC.beaconLocationClient = self.beaconLocationClient
        }
    }
}
