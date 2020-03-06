//
//  Coordinator.swift
//  Echo
//
//  Created by Rohini on 06/03/20.
//  Copyright © 2020 Rohini. All rights reserved.
//

import UIKit

protocol Coordinator {
    var childCoordinators: [Coordinator] { get set }
    var navigationController: UINavigationController { get set }

    func start()
}
