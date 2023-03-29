//
//  ArtCollectionCoordinator.swift
//  
//
//  Created by Ian Dundas on 28/03/2023.
//

import Foundation
import Feature_OverviewScreen
import Feature_DetailScreen

@MainActor
public class ArtCollectionCoordinator: Coordinator {
    
    public var childCoordinators = [Coordinator]()
    public var navigationController: NavigationControllerProtocol

    public init(navigationController: NavigationControllerProtocol) {
        self.navigationController = navigationController
    }

    public func start() {
        
        // `query` passed here allows a future potential deeplinking feature. It's also used on line 66.
        pushOverviewScreen(query: nil, animated: false)
    }
    
    fileprivate func pushOverviewScreen(query: String?, animated: Bool = true) {
        let viewModel = Feature_OverviewScreen.OverviewViewModel(
            initialQuery: query,
            fetchCollectionService: FetchCollectionService(
                apiKey: Constants.Rijksmuseum.apiKey,
                baseURL: Constants.Rijksmuseum.baseURL
            )
        )
        viewModel.delegate = self
        
        let viewController = Feature_OverviewScreen.OverviewViewController(viewModel: viewModel)
        navigationController.pushViewController(viewController, animated: animated)
    }

    fileprivate func pushDetailScreen(objectNumber: String) {
        
        let viewModel = DetailViewModel(networkContext: FetchCollectionDetailsService(
            objectNumber: objectNumber,
            apiKey: Constants.Rijksmuseum.apiKey,
            baseURL: Constants.Rijksmuseum.baseURL
        ))
        viewModel.delegate = self
        
        let viewController = DetailViewController(viewModel: viewModel)
        navigationController.pushViewController(viewController, animated: true)
    }
}

extension ArtCollectionCoordinator: OverviewViewModelDelegate {

    public func userWantsMoreInfoOn(objectNumber: String) {
        pushDetailScreen(objectNumber: objectNumber)
    }
}

extension ArtCollectionCoordinator: DetailViewModelDelegate {
    
    public func userWantsMoreToSearchFor(query: String) {
        pushOverviewScreen(query: query)
    }
}
