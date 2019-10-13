//
//  UrlSessionHelper.swift
//  My Movies
//
//  Created by Ramy Al Zuhouri on 12/10/19.
//  Copyright © 2019 Ramy Al Zuhouri. All rights reserved.
//

import Foundation

enum UrlSessionHelperError: Error {
    case noData
}

// Helper that automatically handles error when trying to load
// any resource from the web.
class UrlSessionHelper {
    func runTask(url: URL,
                 completion: @escaping (Data) -> Void,
                 failure: @escaping (Error) -> Void) {
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                failure(error)
                return
            }
            
            guard let data = data else {
                failure(UrlSessionHelperError.noData)
                return
            }
            
            completion(data)
        }
        
        task.resume()
    }
}
