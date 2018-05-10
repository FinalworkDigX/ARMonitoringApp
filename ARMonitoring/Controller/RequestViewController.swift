//
//  RequestViewController.swift
//  ARMonitoring
//
//  Created by Ludovic Marchand on 10/05/2018.
//  Copyright © 2018 Ludovic Marchand. All rights reserved.
//

import UIKit

class RequestViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var dataItemNameTbx: UITextField!
    @IBOutlet weak var beaconMajorLbl: UILabel!
    @IBOutlet weak var beaconMinorLbl: UILabel!
    
    var beaconLocationClient: BeaconLocationService?
    var aBeacon: Beacon?
    
    override func viewDidLoad() {
        //super.viewDidLoad()

        view.isOpaque = false
        view.backgroundColor = .clear
        self.hideKeyboardWhenTappedAround()
        dataItemNameTbx.delegate = self
        
        self.refreshActiveBeacon("")
        beaconLocationClient?.pom()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textFieldShouldReturn(_ scoreText: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
    
    @IBAction func refreshActiveBeacon(_ sender: Any) {
        if let activeBeacon = beaconLocationClient?.aBeacon {
            self.aBeacon = activeBeacon
            self.beaconMajorLbl.text = String(activeBeacon.major)
            self.beaconMinorLbl.text = String(activeBeacon.minor)
        }
    }
    
    @IBAction func sendRequestButton(_ sender: Any) {
        //send request
        if let beaconId_ = self.aBeacon?.id,
            let dataItemName_ = self.dataItemNameTbx.text,
            let requester_ = SessionService.sharedInstance.getUserInfo()?.email{
            
            let request = DataItemRequestDto(
                beaconId: beaconId_,
                dataItemName:
                dataItemName_,
                requester: requester_)
            
            self.sendRequest(requestDto: request)
        }
    }
    
    @IBAction func cancelButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    private func sendRequest(requestDto: DataItemRequestDto) {
        let requestService: DataItemRequestRestService = DataItemRequestRestService()
        
        requestService.sendRequest(dataItemRequest: requestDto, success: {success in
            //Toast to signall success
            self.sendToast(message: "Success")
            
            if let presenting = self.presentingViewController {
                self.dismiss(animated: false, completion: {
                    presenting.dismiss(animated: false, completion: nil)
                })
            }
            else {
                self.cancelButton("")
            }
        }, failed: { error in
            var errorMessage: String = ""
            switch (error.code) {
            case -15:
                // Mapping error
                errorMessage = "Server error, unexpected response"
                print(error.userInfo)
                break;
            case -20:
                // Connection error
                print(error.userInfo)
                errorMessage = "Connection error, please check your connection"
                break;
            default:
                print("unexpected error..")
                errorMessage = "An unexpected error has occurred.."
                break;
            }
            // Toast to signal error
            self.sendToast(message: errorMessage)
        })
    }
    
    private func sendToast(message: String) {
        print(message)
    }
}
