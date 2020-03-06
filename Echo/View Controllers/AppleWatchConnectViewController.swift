//
//  AppleWatchConnectViewController.swift
//  Echo
//
//  Created by Rohini on 06/03/20.
//  Copyright © 2020 Rohini. All rights reserved.
//

import UIKit
import CoreBluetooth

class AppleWatchConnectViewController: UIViewController, Storyboarded {

    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var descriptionlabel: UILabel!
    
    @IBOutlet weak var helpButton: UIButton!
    weak var coordinator: MainCoordinator?

    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(enableBLE), name: .didUpdatePeripheralState, object: nil)
        

    }
    
    @IBAction func helpButtonAction(_ sender: UIButton) {
    }
    
    @objc func enableBLE(notification: Notification)
    {
        let state = notification.object as! CBManagerState
        if state == .poweredOff
        {
            self.addSettingsAlert(title: "Please Enable Bluetooth Setttings", message: "Echo needs access to Bluetooth so we can broadcast a heart rate to your workout equipment")

        }
    }
    
}


