//
//  MainCoordinator.swift
//  Echo
//
//  Created by Rohini on 06/03/20.
//  Copyright © 2020 Rohini. All rights reserved.
//

import UIKit

class MainCoordinator: Coordinator {
    var childCoordinators = [Coordinator]()
    var navigationController: UINavigationController

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    func start() {
        let vc = BLEStatusCheckViewController.instantiate()
        vc.coordinator = self
        navigationController.pushViewController(vc, animated: false)
    }
    
    func navigateToAppleWatchConnectVC()
    {
          let vc = AppleWatchConnectViewController.instantiate()
          vc.coordinator = self
          navigationController.pushViewController(vc, animated: true)
        
    }
}
