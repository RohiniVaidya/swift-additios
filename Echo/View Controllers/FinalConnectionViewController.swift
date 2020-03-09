//
//  FinalConnectionViewController.swift
//  Echo
//
//  Created by Rohini on 09/03/20.
//  Copyright © 2020 Rohini. All rights reserved.
//

import UIKit
import CoreBluetooth

let activeGreen = UIColor(red: 134/255, green: 204/255, blue: 84/255, alpha: 1)
let activeBlue = UIColor(red: 18/255, green: 106/255, blue: 213/255, alpha: 1)

class FinalConnectionViewController: UIViewController, Storyboarded, BluetoothManagerDelegate {
    
    weak var coordinator: MainCoordinator?
    
    @IBOutlet weak var animationImageView: UIImageView!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var bleView: UIView!
    @IBOutlet weak var watchView: UIView!
    @IBOutlet weak var pelotonConnectView: UIView!
    @IBOutlet weak var bleStatusLabel: UILabel!
    @IBOutlet weak var watchStatusLabel: UILabel!
    @IBOutlet weak var broadcastStatusLabel: UILabel!
    @IBOutlet weak var bleImage: UIImageView!
    @IBOutlet weak var watchImage: UIImageView!
    @IBOutlet weak var broadcastImage: UIImageView!
    @IBOutlet weak var startButton: UIButton!
    
    @IBOutlet weak var heartRateLabel: UILabel!
    
    @IBOutlet weak var hearRateReadingView: UIView!
    
    @IBOutlet weak var initialImageView: UIImageView!
    
    
    var isBLEConnected = false
    var isWatchPaired = false
    
    var animationImages = [UIImage]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(isBLEOn), name: .didUpdatePeripheralState, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(didSomeoneSubscribeToBLE), name: .didSomeoneSubscribe, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(watchAppPairingStatus), name: .isWatchAppPaired, object: nil)
        self.hearRateReadingView.isHidden = true
        self.initialImageView.isHidden = false
        // Do any additional setup after loading the view.
        setUpBroadcastView()
        checkInitialConnections()
        BluetoothManager.sharedInstance.delegate = self
        self.initialImageView.tintColor = activeBlue
        
        animationImages = addAnimationImages(totalImages: 5, imagePrefix: "connecting")
        if BluetoothManager.sharedInstance.peripheralManager.state == .poweredOff
        {
            self.startButton.backgroundColor = #colorLiteral(red: 0.4139562992, green: 0.7631862915, blue: 1, alpha: 1)
            self.startButton.isEnabled = false
            self.startButton.setTitleColor(.gray, for: .disabled)
        }
    }
        
    
    func setUpBroadcastView()
    {
        self.broadcastImage.tintColor = .darkGray
        self.broadcastStatusLabel.text = "Not Currently Broadcasting"
        self.broadcastStatusLabel.textColor = .darkGray
        self.pelotonConnectView.borderColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
    }
    
    func checkInitialConnections()
    {
        if BluetoothManager.sharedInstance.isAdvertising()
        {
            isBLEConnected = true
            setBLEView(isOn: true)
        }
        else
        {
            isBLEConnected = false
            setBLEView(isOn: false)
            self.addSettingsAlert(title: "Please Enable Bluetooth Setttings", message: "Echo needs access to Bluetooth so we can broadcast a heart rate to your workout equipment")

        }
        
        if WatchSessionHandler.sharedInstance.isWatchAppPaired() && WatchSessionHandler.sharedInstance.isWatchAppReachable()
        {
            isWatchPaired = true
            setWatchView(isPaired: true)
        }
        else
        {
            isWatchPaired = false
            setWatchView(isPaired: false)
        }
    }
    
    @objc func isBLEOn(notification:Notification)
    {
        if let state = notification.object as? CBManagerState
        {
            if state == .poweredOn
            {
                isBLEConnected = true
                setBLEView(isOn: true)
                self.startButton.backgroundColor = activeBlue
                self.startButton.isEnabled = true
                self.startButton.setTitleColor(.white, for: .normal)
            }
            else
            {
                isBLEConnected = false
                setBLEView(isOn: false)
                self.startButton.backgroundColor = #colorLiteral(red: 0.4139562992, green: 0.7631862915, blue: 1, alpha: 1)
                self.startButton.isEnabled = false
                self.startButton.setTitleColor(.gray, for: .disabled)
                BluetoothManager.sharedInstance.stopAdvertising()
                BluetoothManager.sharedInstance.timer?.invalidate()
                setUpBroadcastView()

            }
        }
        
    }
    
    @objc func watchAppPairingStatus(notification:Notification)
    {
        if let isPaired = notification.object as? Bool
        {
            if isPaired
            {
                isWatchPaired = true
                
                setWatchView(isPaired: true)
                
            }
            else
            {
                isWatchPaired = false
                
                setWatchView(isPaired: false)
            }
        }
    }
    
    @objc func didSomeoneSubscribeToBLE(notification: Notification)
    {
        if let subscribed = notification.object as? Bool
        {
            if subscribed
            {
                BluetoothManager.sharedInstance.startHeartRateSensor()
                self.initialImageView.isHidden = true
                self.hearRateReadingView.isHidden = false
                self.descriptionLabel.isHidden = true
                activeBroadCasting()
                initialImageView.stopAnimating()
            }
            else
            {
                // do nothing
                self.descriptionLabel.isHidden = false
                animate(imageView: initialImageView, images: animationImages)
                setUpBroadcastView()
            }
        }
        
    }
    
    func fetchHeartRate(hearRate: UInt8) {
        self.heartRateLabel.text = String(describing: hearRate)
    }
    
    func setBLEView(isOn: Bool)
    {
        if isOn
        {
            isBLEConnected = true
            self.bleImage.tintColor = activeGreen
            self.bleStatusLabel.text = "Bluetooth Enabled"
            self.bleStatusLabel.textColor = activeGreen
            self.bleView.borderColor = activeGreen

        }
        else
        {
            isBLEConnected = false
            self.bleImage.tintColor = .darkGray
            self.bleStatusLabel.text = "Bluetooth Not Connected"
            self.bleStatusLabel.textColor = .darkGray
            self.bleView.borderColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)

        }
    }
    
    func setWatchView(isPaired: Bool)
    {
        if isPaired
        {
            self.watchImage.tintColor = activeGreen
            self.watchStatusLabel.text = "Watch Connected"
            self.watchStatusLabel.textColor = activeGreen
            self.watchView.borderColor = activeGreen

        }
        else
        {
            self.watchImage.tintColor = .darkGray
            self.watchStatusLabel.text = "Watch Not Connected"
            self.watchStatusLabel.textColor = .darkGray
            self.watchView.borderColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)

        }
        
    }
    
    func activeBroadCasting()
    {
        self.pelotonConnectView.borderColor = activeGreen
        self.broadcastStatusLabel.text = "Equipment Connected"
        self.broadcastStatusLabel.textColor = activeGreen
        self.broadcastImage.image = #imageLiteral(resourceName: "icn_equipment")
        self.broadcastImage.tintColor = activeGreen
    }

    
    @IBAction func bleButtonAction(_ sender: UIButton) {
        
        isBLEConnected = !isBLEConnected
        if !isBLEConnected
        {
            BluetoothManager.sharedInstance.stopAdvertising()
            setBLEView(isOn: false)
        }
        else
        {
            BluetoothManager.sharedInstance.startAdvertising()
            setBLEView(isOn: true)

        }
        
    }
    
    
    @IBAction func watchConnectAction(_ sender: UIButton) {
        
        isWatchPaired = !isWatchPaired
        
        if !isWatchPaired
        {
            setWatchView(isPaired: false)
        }
        else
        {
            setWatchView(isPaired: true)

        }
        
    }
    
    @IBAction func pelotonConnectAction(_ sender: UIButton) {
        
        
    }
    
    @IBAction func startButtonAction(_ sender: UIButton) {
        if sender.title(for: .normal) == "Start"
        {
            //animation should begin
            initialImageView.tintColor = activeBlue
            animate(imageView: initialImageView, images: animationImages)
            
            //change the broadcast view
            self.pelotonConnectView.borderColor = activeBlue
            self.broadcastImage.tintColor = activeBlue
            self.broadcastStatusLabel.text = "Broadcasting..."
            self.broadcastStatusLabel.textColor = activeBlue
            self.startButton.setTitle("End", for: .normal)

            //change descr label
            self.descriptionLabel.text = "Find Echo in the Bluetooth settings on your workout equipment."
        }
        else if sender.title(for: .normal) == "End"
        {
            stopBroadcastingAlert(title: "Are you sure you want to stop broadcasting with Echo?", message: "Tap yes if you want to stop broadcasting your heart rate for this session")
        }
        
    }
    
    func addAnimationImages(totalImages: Int, imagePrefix:String) -> [UIImage]
    {
        
        var imageArray = [UIImage] ()
        for i in 1...totalImages
        {
            let imagename = "\(imagePrefix)" + "-" + "\(i)" + ".png"
            if let image = UIImage(named: imagename)
            {
                imageArray.append(image)
            }
        }
        
        return imageArray
    }
    
    func animate(imageView: UIImageView, images:[UIImage])
    {
        imageView.animationImages = images
        imageView.animationDuration = 1
        imageView.startAnimating()
    }
    
    func stopBroadcastingAlert(title:String, message: String)
    {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { action in
            BluetoothManager.sharedInstance.timer?.invalidate()
            self.coordinator?.start()
        }))
        self.present(alert, animated: true)
    }
    
}
