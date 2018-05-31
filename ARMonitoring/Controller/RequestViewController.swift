//
//  RequestViewController.swift
//  ARMonitoring
//
//  Created by Ludovic Marchand on 10/05/2018.
//  Copyright © 2018 Ludovic Marchand. All rights reserved.
//

import UIKit
import Toast_Swift

class RequestViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var dataItemNameTbx: UITextField!
    @IBOutlet weak var beaconMajorLbl: UILabel!
    @IBOutlet weak var beaconMinorLbl: UILabel!
    @IBOutlet weak var sendRequestButton: UIButton!
    
    var beaconLocationClient: BeaconLocationService?
    var aBeacon: Beacon?
    
    var enabledButtonColor: UIColor?
    var disabledButtonColor: UIColor?
    
    override func viewDidLoad() {
        //super.viewDidLoad()

        view.isOpaque = false
        view.backgroundColor = .clear
        
        // Keyboard hide on tap around & 'done'
        self.hideKeyboardWhenTappedAround()
        self.dataItemNameTbx.delegate = self
        
        // Set submitButton
        self.enabledButtonColor = UIColor(red: 82.0/255.0, green: 179.0/255.0, blue: 217.0/255.0, alpha: 1.0)
        self.disabledButtonColor = UIColor(red: 178.0/255.0, green: 211.0/255.0, blue: 238.0/255.0, alpha: 1.0)
        
        if let dataItemText = self.dataItemNameTbx.text,
            dataItemText.isEmpty {
            self.sendRequestButton.isEnabled = false
            self.sendRequestButton.backgroundColor = disabledButtonColor
        }
        
        self.refreshActiveBeacon("")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textFieldShouldReturn(_ scoreText: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        let value = NSString(string: textField.text!).replacingCharacters(in: range, with: string)
        
        if value.count > 0 {
            self.sendRequestButton.isEnabled = true
            self.sendRequestButton.backgroundColor = enabledButtonColor
        } else {
            self.sendRequestButton.isEnabled = false
            self.sendRequestButton.backgroundColor = disabledButtonColor
        }
        
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
            self.sendToast(message: "Success", success: true)
            
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
            self.sendToast(message: errorMessage, success: false)
        })
    }
    
    private func sendToast(message: String, success: Bool) {
        if let presentingView = self.presentingViewController?.presentingViewController {
            var style = ToastStyle()
            if success {
                style.backgroundColor = UIColor(red: 46.0/255.0, green: 204.0/255.0, blue: 113.0/255.0, alpha: 1.0)
            }
            else {
                style.backgroundColor = UIColor(red: 239.0/255.0, green: 72.0/255.0, blue: 54.0/255.0, alpha: 1.0)
            }
            presentingView.view.makeToast(message, duration: 3.0, position: .top, style: style)
        }
        
    }
}
