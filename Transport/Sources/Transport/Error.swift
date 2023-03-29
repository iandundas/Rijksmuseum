//
//  Error.swift
//  
//
//  Created by Ian Dundas on 27/03/2023.
//

import Foundation

public enum Error: Swift.Error, LocalizedError {
    case couldNotCreateRequest
    case networking(URLError)
    case decoding(Swift.Error)
    
    public var errorDescription: String? {
        switch self {
        case .couldNotCreateRequest:
            return NSLocalizedString("Could not create a request to send to the network", comment: "")
        case .decoding(let error):
            return error.localizedDescription
        case .networking(let error):
            return error.localizedDescription
        }
   }
}
