//
//  DetailScreenViewModel.swift
//  
//
//  Created by Ian Dundas on 28/03/2023.
//

import UIKit
import TransportCore
import Combine
import Shared

public protocol DetailViewModelDelegate: AnyObject {
    
    func userWantsMoreToSearchFor(query: String)
}

public final class DetailViewModel {

    public weak var delegate: DetailViewModelDelegate?
    
    let items = CurrentValueSubject<[DetailRow]?, Never>(nil)
    
    private var networkTask: Task<Void, Never>?
    private var fetchCollectionDetailsService: FetchCollectionDetailsService
    
    public init(networkContext: FetchCollectionDetailsService) {
        self.fetchCollectionDetailsService = networkContext
        
        load()
    }
    
    private func load() {
        networkTask?.cancel()
        
        networkTask = Task {
            do {
                let networkObject = try await fetchCollectionDetailsService.load()
                self.handleNetworkResponse(networkObject: networkObject)
            }
            catch let error {
                // TODO: handle error
                print("Network Error:", error.localizedDescription)
            }
        }
    }
    
    private func handleNetworkResponse(networkObject: CollectionDetailResponse.ArtObject) {
        
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
    
    func userTappedRow(data: DetailRow) {
        delegate?.userWantsMoreToSearchFor(query: data.value)
    }
}


