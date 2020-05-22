/*
Copyright (C) 2020 Groupe MINASTE

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License along
with this program; if not, write to the Free Software Foundation, Inc.,
51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
*/
//
//  APIRequest.swift
//  HiberLink
//
//  Created by Nathan FALLET on 19/04/2020.
//  Copyright © 2020 Nathan FALLET. All rights reserved.
//

import Foundation

class APIRequest {
    
    // Object properties
    var method: String
    var path: String
    var queryItems: [URLQueryItem]
    var body: [String: String]?
    
    init(_ method: String, path: String) {
        // Get request parameters
        self.method = method
        self.path = path
        self.queryItems = [URLQueryItem]()
    }
    
    // Add url parameter (String)
    func with(name: String, value: String) -> APIRequest {
        queryItems.append(URLQueryItem(name: name, value: value))
        return self
    }
    
    // Add url parameter (int)
    func with(name: String, value: Int) -> APIRequest {
        return with(name: name, value: "\(value)")
    }
    
    // Add url parameter (int64)
    func with(name: String, value: Int64) -> APIRequest {
        return with(name: name, value: "\(value)")
    }
    
    // Set request body
    func with(body: [String: String]) -> APIRequest {
        self.body = body
        return self
    }
    
    // Construct URL
    func getURL() -> URL? {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "hiberfile.com"
        components.path = path
        
        if !queryItems.isEmpty {
            components.queryItems = queryItems
        }
        
        return components.url
    }
    
    // Upload a file
    func uploadFile(file: Data, name: String, completionHandler: @escaping (_ data: String?, _ status: APIResponseStatus) -> ()) {
        // Check url validity
        if let url = getURL() {
            // Create the request based on give parameters
            var request = URLRequest(url: url)
            request.httpMethod = method
            request.addValue("curl", forHTTPHeaderField: "User-Agent")
            
            // Set body
            var bodyData = Data()
            
            // Generate boundary
            let boundary = UUID().uuidString
            
            // Set content type
            request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
                
            if let body = body {
                for key in body {
                    // Add the value to the raw http request data
                    bodyData.append("\r\n--\(boundary)\r\n".data(using: .utf8)!)
                    bodyData.append("Content-Disposition: form-data; name=\"\(key.0)\"\r\n\r\n".data(using: .utf8)!)
                    bodyData.append(key.1.data(using: .utf8)!)
                }
            }
            
            // Add the file
            bodyData.append("\r\n--\(boundary)\r\n".data(using: .utf8)!)
            bodyData.append("Content-Disposition: form-data; name=\"my_file\"; filename=\"\(name)\"\r\n".data(using: .utf8)!)
            bodyData.append("Content-Type: application/octet-stream\r\n\r\n".data(using: .utf8)!)
            bodyData.append(file)
            
            // Close
            bodyData.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)
            
            // Launch the request to server
            URLSession.shared.uploadTask(with: request, from: bodyData) { (data: Data?, response: URLResponse?, error: Error?) in
                // Check if there is an error
                if let error = error {
                    print(error.localizedDescription)
                    DispatchQueue.main.async {
                        completionHandler(nil, .offline)
                    }
                    return
                }
                
                // Get data and response
                // NOTE: This line will be changed when HiberFile API will be available
                //if let data = data, let string = String(data: data, encoding: .utf8), let response = response as? HTTPURLResponse {
                if let response = response as? HTTPURLResponse, let string = response.allHeaderFields["X-HIBERFILE-LINK"] as? String {
                    DispatchQueue.main.async {
                        completionHandler(string, self.status(forCode: response.statusCode))
                    }
                } else {
                    // We consider we don't have a valid response
                    DispatchQueue.main.async {
                        completionHandler(nil, .offline)
                    }
                }
            }.resume()
        } else {
            // URL is not valid
            DispatchQueue.main.async {
                completionHandler(nil, .invalidRequest)
            }
        }
    }
    
    // Get status for code
    func status(forCode code: Int) -> APIResponseStatus {
        switch code {
        case 200:
            return .ok
        case 201:
            return .created
        case 400:
            return .invalidRequest
        case 401:
            return .unauthorized
        case 404:
            return .notFound
        default:
            return .offline
        }
    }
    
}
