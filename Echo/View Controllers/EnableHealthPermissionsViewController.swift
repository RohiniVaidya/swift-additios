//
//  EnableHealthPermissionsViewController.swift
//  Echo
//
//  Created by Rohini on 09/03/20.
//  Copyright © 2020 Rohini. All rights reserved.
//

import UIKit
import CoreBluetooth

class EnableHealthPermissionsViewController: UIViewController, Storyboarded {

    weak var coordinator: MainCoordinator?

    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var descriptionLabel: UILabel!
    
    
    @IBOutlet weak var enableHealthButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    
    @IBAction func enablehealth(_ sender: UIButton) {
        
        addOKAlert(title: "Health Permissions Required", message: "Please go to Settings > Privacy > Health > Echo and turn on all the categories to continue.")
    }
    
    func addOKAlert(title:String, message:String)
       {
           let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
           
           alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
               
            self.coordinator?.navigateToFinalConnectionVC()
               
           }))
           self.present(alert, animated: true)
       }
}
