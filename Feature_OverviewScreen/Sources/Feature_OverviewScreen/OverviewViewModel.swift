//
//  OverviewViewModel.swift
//  
//
//  Created by Ian Dundas on 27/03/2023.
//

import UIKit
import Combine
import Transport
import Shared
 
public protocol OverviewViewModelDelegate: AnyObject {
    
    func userWantsMoreInfoOn(objectNumber: String) // TODO: `objectNumber` would be better as its own Type instead of `String`
}

@MainActor
public final class OverviewViewModel {

    enum StateChangeMode {
        case overwrite  // this change should overwrite the last change.
        case append     // this change should be appended to the last change.
    }
    
    enum ErrorAlert {
        case networkError(title: String, message: String, retryAction: () -> Void)
    }
    
    public weak var delegate: OverviewViewModelDelegate?
    
    let title: String
    let itemUpdates = CurrentValueSubject<(StateChangeMode, [CollectionItem])?, Never>(nil)
    let errorAlerts = CurrentValueSubject<ErrorAlert?, Never>(nil) // TODO: model as a PassthroughSubject instead, as it's an event rather than a static value.
    let isLoading = CurrentValueSubject<Bool, Never>(false)

    private var nextPageToLoad: Int?
    private var queryText: String?
    private var networkTask: Task<Void, Never>?
    private let fetchCollectionService: FetchCollectionServiceType
    
    public init(initialQuery: String?, fetchCollectionService: FetchCollectionServiceType) {
        self.queryText = initialQuery
        self.title = initialQuery ?? NSLocalizedString("Rijksmuseum Collection", comment: "Overview Title")
        self.fetchCollectionService = fetchCollectionService
        self.nextPageToLoad = 1

        load()
    }
    
    private func load() {
        guard let nextPageToLoad else { return }
        
        networkTask?.cancel()
        
        isLoading.value = true
        
        networkTask = Task {
            do {
                let networkObjects = try await fetchCollectionService.load(query: queryText, page: nextPageToLoad)
                self.handleNetworkResponse(networkObjects: networkObjects, forPage: nextPageToLoad)
                
                self.isLoading.value = false
            }
            catch let error {
                self.handleNetworkError(error: error)
                
                self.isLoading.value = false
            }
        }
    }
    
    private func handleNetworkResponse(networkObjects: [CollectionResponse.ArtObject], forPage page: Int) {
        errorAlerts.send(nil)
        
        let objects = networkObjects.compactMap(CollectionItem.init)
        
        // If it's the first page of data loaded, overwrite existing data. Otherwise append it.
        let stateChangeMode: StateChangeMode = nextPageToLoad == 1 ? .overwrite : .append
        self.itemUpdates.value = (stateChangeMode, objects)
        
        // Increment next page counter:
        self.nextPageToLoad = objects.isEmpty ? nil : page + 1
    }
    
    private func handleNetworkError(error: Swift.Error) {
        errorAlerts.send(ErrorAlert.networkError(
            title: NSLocalizedString("Error", comment: "Error dialog title"),
            message: error.localizedDescription,
            retryAction: { [weak self] in
                guard let self else { return }
                print("retrying loading query \(String(describing: self.queryText)) at page \(String(describing: self.nextPageToLoad))")
                self.load()
            }
        ))
    }
    
    func userViewedTheLastCell() {
        
        // Time to load the next page. `nextPageToLoad` is pointing to the next page already.
        load()
    }
    
    func userTappedCell(data: CollectionItem) {
        delegate?.userWantsMoreInfoOn(objectNumber: data.objectNumber)
    }
    
    func userTypedSearchQuery(query: String?) {
        // TODO: debounce this

        guard query != self.queryText else { return }
        
        // We'll be loading page 1 again after changing the query:
        self.nextPageToLoad = 1
        
        // Save the new query:
        self.queryText = query
        
        // Perform a load
        self.load()
    }
}

private extension CollectionItem {
    
    /// Produce a `CollectionItem` from a `CollectionResponse.ArtObject` 
    init?(networkObject: CollectionResponse.ArtObject) {
        guard let urlString = networkObject.webImage?.url,
            let url = URL(string: urlString),
            let title = networkObject.title,
            let principalOrFirstMaker = networkObject.principalOrFirstMaker
        else { return nil }
        
        self.name = title
        self.section = Section(name: principalOrFirstMaker)
        self.objectNumber = networkObject.objectNumber
        self.imageURL = url
    }
}
