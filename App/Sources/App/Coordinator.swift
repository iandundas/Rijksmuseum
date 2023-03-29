//
//  Coordinator.swift
//  
//
//  Created by Ian Dundas on 28/03/2023.
//

import UIKit

@MainActor
public protocol Coordinator {
    var childCoordinators: [Coordinator] { get set }
    var navigationController: NavigationControllerProtocol { get set }

    func start()
}

/// `NavigationControllerProtocol` would allow the Coordinators to be tested. One for the future..
///
public protocol NavigationControllerProtocol: NSObject {
    func pushViewController(_: UIViewController, animated: Bool)

    @discardableResult
    func popViewController(animated: Bool) -> UIViewController?
}

extension UINavigationController: NavigationControllerProtocol {}
