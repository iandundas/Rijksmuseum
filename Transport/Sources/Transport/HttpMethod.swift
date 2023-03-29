//
//  HttpMethod.swift
//  
//
//  Created by Ian Dundas on 27/03/2023.
//

import Foundation

public enum HttpMethod: Equatable {
    case get([URLQueryItem])
    case post(Data?)
    // etc..
    
    /// The name of the verb used in the HTTP request
    public var name: String {
        switch self {
        case .get: return "GET"
        case .post: return "POST"
        }
    }
}


