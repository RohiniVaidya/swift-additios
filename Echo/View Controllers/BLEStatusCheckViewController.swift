//
//  BLEStatusCheckViewController.swift
//  Echo
//
//  Created by Rohini on 06/03/20.
//  Copyright © 2020 Rohini. All rights reserved.
//

import UIKit
import CoreBluetooth

class BLEStatusCheckViewController: UIViewController, Storyboarded {
    
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var descriptionLabel: UILabel!
    
    @IBOutlet weak var enableBLEButton: UIButton!
    weak var coordinator: MainCoordinator?

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        BluetoothManager.sharedInstance.startBLE()
        
        NotificationCenter.default.addObserver(self, selector: #selector(notifyUser), name: .didUpdatePeripheralState, object: nil)
        authorizationHandling()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    @objc func notifyUser(notification: Notification)
    {
        let state = notification.object as! CBManagerState
        if state == .poweredOff
        {
            titleLabel.text = "Please Enable Bluetooth Setttings"
            descriptionLabel.text = "Echo needs access to Bluetooth so we can broadcast a heart rate to your workout equipment"
            enableBLEButton.setTitle("Enable Bluetooth", for: .normal)
        }
        else if state == .poweredOn{
            coordinator?.navigateToAppleWatchConnectVC()

        }
    }
    
    
    @IBAction func enableBLEAction(_ sender: UIButton) {
        
        if let url = URL.init(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    func authorizationHandling()
    {
        if #available(iOS 13.1, *) {
            if CBPeripheralManager.authorization == .denied || CBPeripheralManager.authorization == .notDetermined
            {
                self.addSettingsAlert(title: "Please Enable Bluetooth Setttings", message: "Echo needs access to Bluetooth so we can broadcast a heart rate to your workout equipment")
            }
        }
    }
    
}


