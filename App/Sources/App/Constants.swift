//
//  Constants.swift
//  
//
//  Created by Ian Dundas on 27/03/2023.
//

import Foundation

internal enum Constants {
    enum Rijksmuseum {
        static var apiKey: String { "0fiuZFh4" }
        static var baseURL: URL { URL(string: "https://www.rijksmuseum.nl/api/nl")! }
    }
}
