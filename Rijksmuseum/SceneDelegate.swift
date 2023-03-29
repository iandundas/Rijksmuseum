//
//  SceneDelegate.swift
//  Rijksmuseum
//
//  Created by Ian Dundas on 24/03/2023.
//  Copyright © 2023 Solid Red Systems B.V. All rights reserved.
//

import UIKit
import App

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    var rootCoordinator: Coordinator?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        window = UIWindow(frame: windowScene.coordinateSpace.bounds)
        window?.windowScene = windowScene
        
        let navController = UINavigationController()
        let artCollectionCoordinator = ArtCollectionCoordinator(navigationController: navController)
        rootCoordinator = artCollectionCoordinator
        
        window?.rootViewController = navController

        rootCoordinator?.start()

        window?.makeKeyAndVisible()
    }
}

