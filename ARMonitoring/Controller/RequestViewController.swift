//
//  RequestViewController.swift
//  ARMonitoring
//
//  Created by Ludovic Marchand on 10/05/2018.
//  Copyright © 2018 Ludovic Marchand. All rights reserved.
//

import UIKit

class RequestViewController: UIViewController {
    @IBOutlet weak var itemInfoView: UIView!
    @IBOutlet weak var beaconInfoView: UIView!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    
    var beaconLocationClient: BeaconLocationService?
    
    override func viewDidLoad() {
        //super.viewDidLoad()

        view.isOpaque = false
        view.backgroundColor = .clear
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func sendRequestButton(_ sender: Any) {
        //send request
        
        if let presenting = self.presentingViewController {
            self.dismiss(animated: false, completion: {
                presenting.dismiss(animated: false, completion: nil)
            })
        }
        else {
            self.cancelButton(sender)
        }
    }
    
    @IBAction func cancelButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}
