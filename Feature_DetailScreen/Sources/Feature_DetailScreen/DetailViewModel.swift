//
//  DetailScreenViewModel.swift
//  
//
//  Created by Ian Dundas on 28/03/2023.
//

import UIKit
import Transport
import Combine
import Shared

public protocol DetailViewModelDelegate: AnyObject {
    
    func userWantsMoreToSearchFor(query: String)
}

@MainActor
public final class DetailViewModel {
    
    enum ErrorAlert {
        case networkError(title: String, message: String, retryAction: () -> Void)
    }
    
    public weak var delegate: DetailViewModelDelegate?
    
    let items = CurrentValueSubject<[DetailRow]?, Never>(nil)
    let errorAlerts = CurrentValueSubject<ErrorAlert?, Never>(nil) // TODO: model as a PassthroughSubject instead, as it's an event rather than a static value.
    let isLoading = CurrentValueSubject<Bool, Never>(false)

    private var networkTask: Task<Void, Never>?
    private var fetchCollectionDetailsService: FetchCollectionDetailsService
    
    public init(networkContext: FetchCollectionDetailsService) {
        self.fetchCollectionDetailsService = networkContext
        
        load()
    }
    
    private func load() {
        networkTask?.cancel()
        isLoading.value = true
        
        networkTask = Task {
            do {
                let networkObject = try await fetchCollectionDetailsService.load()
                self.handleNetworkResponse(networkObject: networkObject)
                self.isLoading.value = false
            }
            catch let error {
                self.handleNetworkError(error: error)
                self.isLoading.value = false
            }
        }
    }
    
    private func handleNetworkResponse(networkObject: CollectionDetailResponse.ArtObject) {
        errorAlerts.send(nil)
        
        var rows = [DetailRow]()
        rows += [.init(title: NSLocalizedString("Object Number", comment: ""), value: networkObject.objectNumber, allowsSearch: false)]
        
        if let title = networkObject.title {
            rows += [.init(title: NSLocalizedString("Title", comment: ""), value: title, allowsSearch: true)]
        }
        
        if let description = networkObject.description {
            rows += [.init(title: NSLocalizedString("Description", comment: ""), value: description, allowsSearch: false)]
        }

        if let presentingDate = networkObject.dating?.presentingDate {
            rows += [.init(title: NSLocalizedString("Presenting Date", comment: ""), value: presentingDate, allowsSearch: true)]
        }
        
        networkObject.historicalPersons?.forEach { historicalPerson in
            rows += [.init(title: NSLocalizedString("Historical Person", comment: ""), value: historicalPerson, allowsSearch: true)]
        }
        
        if let principleMaker = networkObject.principalMaker {
            rows += [.init(title: NSLocalizedString("Principle Maker", comment: ""), value: principleMaker, allowsSearch: true)]
        }
        
        items.value = rows
    }
    
    private func handleNetworkError(error: Swift.Error) {
        errorAlerts.send(ErrorAlert.networkError(
            title: NSLocalizedString("Error", comment: "Error dialog title"),
            message: error.localizedDescription,
            retryAction: { [weak self] in
                guard let self else { return }
                print("Retrying load")
                self.load()
            }
        ))
    }
    
    func userTappedRow(data: DetailRow) {
        delegate?.userWantsMoreToSearchFor(query: data.value)
    }
}


