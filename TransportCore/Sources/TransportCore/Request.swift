//
//  Request.swift
//
//
//  Created by Ian Dundas on 27/03/2023.
//

import Foundation

/// Response is a "Phantom" type, i.e a generic type associated with - but not used by - this Type.
public struct Request<Response> {
    public let method: HttpMethod
    public let url: URL
    // (NB could also set request headers here if it were needed.)
    
    public init(method: HttpMethod, url: URL) {
        self.method = method
        self.url = url
    }
}

extension Request {
    
    internal var urlRequest: URLRequest? {
        var request = URLRequest(url: url)
        
        switch method {
        case .post(let data):
            request.httpBody = data
            
        case let .get(queryItems):
            var components = URLComponents(url: url, resolvingAgainstBaseURL: false)
            components?.queryItems = queryItems
            
            guard let url = components?.url else {
                print("`URLComponents` failed to produce a url after queryItems were added: (\(queryItems)")
                return nil
            }
            
            request = URLRequest(url: url)
        }
        
        request.httpMethod = method.name
        return request
    }
}

extension URLSession {
    
    public func resolveJSONEncodedValue<Value: Decodable>(from request: Request<Value>)
        async throws -> Value {
            
        let decoded = Task.detached(priority: .userInitiated) {
            
            guard let urlRequest = request.urlRequest else {
                throw Error.couldNotCreateRequest
            }
            
            let (data, _) = try await self.data(for: urlRequest)
            try Task.checkCancellation() // maybe the task was cancelled already. If so, throw here without wasting time decoding.
            return try JSONDecoder().decode(Value.self, from: data)
        }
        return try await decoded.value
    }
}
