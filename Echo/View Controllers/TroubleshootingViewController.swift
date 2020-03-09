//
//  TroubleshootingViewController.swift
//  Echo
//
//  Created by Rohini on 09/03/20.
//  Copyright © 2020 Rohini. All rights reserved.
//

import UIKit

class TroubleshootingViewController: UIViewController, Storyboarded {

    weak var coordinator: MainCoordinator?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    
    @IBAction func collapseVC(_ sender: UIButton) {
        
        coordinator?.navigateToAppleWatchConnectVC()
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
