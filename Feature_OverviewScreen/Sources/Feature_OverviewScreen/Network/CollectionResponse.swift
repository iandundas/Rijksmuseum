//
//  CollectionResponse.swift
//  
//
//  Created by Ian Dundas on 28/03/2023.
//

import Foundation

internal struct CollectionResponse: Codable {
    let count: Int
    let artObjects: [ArtObject]
    
    struct ArtObject: Codable {
        let id: String
        let objectNumber: String
        let title: String?
        let principalOrFirstMaker: String?
        let webImage: WebImage?
        
        struct WebImage: Codable {
            let url: String?
        }
    }
}
