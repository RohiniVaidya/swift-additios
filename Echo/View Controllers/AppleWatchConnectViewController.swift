//
//  AppleWatchConnectViewController.swift
//  Echo
//
//  Created by Rohini on 06/03/20.
//  Copyright © 2020 Rohini. All rights reserved.
//

import UIKit
import CoreBluetooth
import WatchConnectivity


class AppleWatchConnectViewController: UIViewController, Storyboarded {
        
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var descriptionlabel: UILabel!
    
    @IBOutlet weak var helpButton: UIButton!
    weak var coordinator: MainCoordinator?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(enableBLE), name: .didUpdatePeripheralState, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(watchAppInstalled), name: .isWatchAppInstalled, object: nil)
        
    }
    
    @IBAction func helpButtonAction(_ sender: UIButton) {
        
        if sender.title(for: .normal) == "Install Now"
        {
            // open the watch phone app to install echo
            coordinator?.navigateTohealthPermissionsVC()

        }
        else if sender.title(for: .normal) == "Troubleshooting"
        {
            coordinator?.navigateToTroubleshooting()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if WatchSessionHandler.sharedInstance.isWatchAppInstalled(){
            performWatchAppInstalled()
        }
        else
        {
            whenWatchAppNotInstalled()
        }
    }
    
    @objc func watchAppInstalled(notification: Notification)
    {
        if let isWatchAppInstalled = notification.object as? Bool {
            if isWatchAppInstalled
            {
                performWatchAppInstalled()
            }
            else
            {
                whenWatchAppNotInstalled()
            }
            
        }
    }
    
    @objc func enableBLE(notification: Notification)
    {
        let state = notification.object as! CBManagerState
        if state == .poweredOff
        {
            self.addSettingsAlert(title: "Please Enable Bluetooth Setttings", message: "Echo needs access to Bluetooth so we can broadcast a heart rate to your workout equipment")
            
        }
    }
    
    func performWatchAppInstalled()
    {
        if WatchSessionHandler.sharedInstance.isWatchAppPaired() && WatchSessionHandler.sharedInstance.isWatchAppReachable()
        {
            coordinator?.navigateTohealthPermissionsVC()
        }
        else
        {
            self.titleLabel.text = "Can't find Apple Watch"
            self.descriptionlabel.text = "We can't find your Apple Watch. Is your watch off or not in range?"
            self.helpButton.setTitle("Troubleshooting", for: .normal)
        }
    }
    
    func whenWatchAppNotInstalled()
    {
        self.titleLabel.text = "Install Apple Watch App"
        self.descriptionlabel.text = "Got to the Watch app on your phone and install Echo app to your Watch."
        self.helpButton.setTitle("Install Now", for: .normal)
    }
}


