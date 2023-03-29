//
//  Error.swift
//  
//
//  Created by Ian Dundas on 27/03/2023.
//

import Foundation

public enum Error: Swift.Error {
    case couldNotCreateRequest
    case networking(URLError)
    case decoding(Swift.Error)
}
