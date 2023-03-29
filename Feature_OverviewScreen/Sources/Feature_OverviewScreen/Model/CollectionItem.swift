//
//  CollectionItem.swift
//  
//
//  Created by Ian Dundas on 28/03/2023.
//

import Foundation

internal struct CollectionItem: Hashable {
    private let uuid = UUID() // to ensure `Hashable` produces unique values even if other properties are the same.
    
    let name: String
    let section: Section
    let objectNumber: String
    let imageURL: URL
}
