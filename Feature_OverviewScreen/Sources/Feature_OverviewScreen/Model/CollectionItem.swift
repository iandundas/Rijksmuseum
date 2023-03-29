//
//  CollectionItem.swift
//  
//
//  Created by Ian Dundas on 28/03/2023.
//

import Foundation

internal struct CollectionItem: Hashable {
    let name: String
    let section: Section
    let objectNumber: String
    let imageURL: URL
}
