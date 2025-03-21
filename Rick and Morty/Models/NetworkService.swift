//
//  networkService.swift
//  Rick and Morty
//
//  Created by Lidiia Diachkovskaia on 3/20/25.
//

import Foundation

struct NetworkService {
    enum HTTPMethod: String {
        case get = "GET"
        case post = "POST"
        case put = "PUT"
        case delete = "DELETE"
    }
    
    static func fetchData<T: Decodable>(
        from url: URL,
        httpMethod: HTTPMethod = .get,
        parameters: [String: String]? = nil,
        headers: [String: String]? = nil
    ) async throws -> T {
        let requestURL = addQueryItems(to: url, from: parameters)
        
        var request = URLRequest(url: requestURL)
        request.httpMethod = httpMethod.rawValue
        request.allHTTPHeaderFields = headers
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }
        
        return try JSONDecoder().decode(T.self, from: data)
    }
    
    private static func addQueryItems(to url: URL, from parameters: [String: String]?) -> URL {
        guard let parameters = parameters, !parameters.isEmpty else { return url }
        
        var components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        components?.queryItems = parameters.map { URLQueryItem(name: $0.key, value: $0.value) }
        
        return components?.url ?? url
    }
}
