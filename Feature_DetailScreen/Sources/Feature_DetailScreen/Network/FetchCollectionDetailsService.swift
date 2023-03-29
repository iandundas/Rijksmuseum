//
//  FetchCollectionDetailsService.swift
//  
//
//  Created by Ian Dundas on 29/03/2023.
//

import Foundation
import TransportCore

public class FetchCollectionDetailsService {
    
    private let objectNumber: String
    private let apiKey: String
    private let baseURL: URL
    
    public init(objectNumber: String, apiKey: String, baseURL: URL) {
        self.objectNumber = objectNumber
        self.apiKey = apiKey
        self.baseURL = baseURL
    }
    
    func load() async throws -> CollectionDetailResponse.ArtObject {
        
        let request = TransportCore.Request<CollectionDetailResponse>
            .fetch(objectNumber: objectNumber, apiKey: apiKey, baseURL: baseURL)
        
        let result = try await URLSession.shared
            .resolveJSONEncodedValue(from: request) // (runs on a detached `.userInitiated` task)
            
        return result.artObject
    }
}

private extension TransportCore.Request where Response == CollectionDetailResponse {
    
    /// e.g. `GET https://www.rijksmuseum.nl/api/nl/collection/BI-1950-17-160`
    static func fetch(objectNumber: String, apiKey: String, baseURL: URL) -> Self {
        return Request(
            method: .get([
                URLQueryItem(name: "key", value: apiKey),
            ]),
            url: baseURL
                .appending(path: "collection")
                .appending(path: objectNumber)
        )
    }
}
