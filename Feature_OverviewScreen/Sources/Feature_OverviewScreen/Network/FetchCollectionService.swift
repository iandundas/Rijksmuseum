//
//  FetchCollectionService.swift
//
//
//  Created by Ian Dundas on 28/03/2023.
//

import TransportCore
import Foundation

public protocol FetchCollectionServiceType {
    func load(query: String?, page: Int) async throws -> [CollectionResponse.ArtObject]
}

public class FetchCollectionService: FetchCollectionServiceType {
    
    private let apiKey: String
    private let baseURL: URL
    
    public init(apiKey: String, baseURL: URL) {
        self.apiKey = apiKey
        self.baseURL = baseURL
    }
    
    public func load(query: String?, page: Int) async throws -> [CollectionResponse.ArtObject] {
        
        let request = TransportCore.Request<CollectionResponse>
            .search(query: query, apiKey: apiKey, baseURL: baseURL, page: page)
        
        let result = try await URLSession.shared
            .resolveJSONEncodedValue(from: request) // (runs on a detached `.userInitiated` task)
            
        return result.artObjects
    }
}

private extension TransportCore.Request where Response == CollectionResponse {
    
    /// e.g. `GET https://www.rijksmuseum.nl/api/nl/collection?key=0fiuZFh4&q=Vermeer&imgonly=true&p=0&ps=10&s=artist`
    static func search(query: String?, apiKey: String, baseURL: URL, page: Int = 1, resultsPerPage: Int = 20) -> Self {
        
        // `assert` causes fatal error in debug builds only.
        // 
        // An alternative would be to create a Type for holding `page` and `resultsPerPage` and give it a failable initialiser.
        //      However, that would require handling that programmer mistake, and it's better to catch that class of error during development instead.
        assert(page > 0, "Page should be > 0")
        assert((1...100).contains(resultsPerPage), "resultsPerPage should be between 1 and 100")
 
        var queryItems: [URLQueryItem] = [
            URLQueryItem(name: "imgonly", value: "true"),
            URLQueryItem(name: "p", value: "\(page)"),
            URLQueryItem(name: "ps", value: "\(resultsPerPage)"),
            URLQueryItem(name: "s", value: "artist"),
            URLQueryItem(name: "format", value: "json"),
            URLQueryItem(name: "culture", value: "en"), // TODO: use user's locale?
            URLQueryItem(name: "key", value: apiKey),
        ]
        
        if let query {
            queryItems += [URLQueryItem(name: "q", value: query)] // `URLComponents` automatically escapes its parameters, so can use raw `query` here.]
        }
        
        return Request(
            method: .get(queryItems),
            url: baseURL.appending(path: "collection")
        )
    }
}
