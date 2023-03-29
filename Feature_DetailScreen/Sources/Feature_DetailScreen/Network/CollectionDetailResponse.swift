//
//  CollectionDetailResponse.swift
//  
//
//  Created by Ian Dundas on 29/03/2023.
//

import Foundation

internal struct CollectionDetailResponse: Codable {
    let artObject: ArtObject
    
    struct ArtObject: Codable {
        let id: String
        let objectNumber: String
        let title: String?
        let webImage: ArtObjectWebImage?
        let description: String?
        let principalMaker: String?
        let dating: ArtObjectDating?
        let historicalPersons: [String]?
        
        struct ArtObjectWebImage: Codable {
            let url: String
        }
        
        struct ArtObjectDating: Codable {
            let presentingDate: String?
        }
    }
}
