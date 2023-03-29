//
//  DetailRow.swift
//  
//
//  Created by Ian Dundas on 29/03/2023.
//

import Foundation

public struct DetailRow: Hashable {
    private let uuid = UUID() // to ensure `Hashable` produces unique values even if other properties are the same.
    
    let title: String
    let value: String
    let allowsSearch: Bool
}

