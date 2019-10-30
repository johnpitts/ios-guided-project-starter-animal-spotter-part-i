//
//  APIController.swift
//  AnimalSpotter
//
//  Created by Ben Gohlke on 4/16/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import Foundation
import UIKit

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
}

class APIController {
    
    private let baseUrl = URL(string: "https://lambdaanimalspotter.vapor.cloud/api")!
    var bearer: Bearer?

    
    // create function for sign up
    func signUp(with user: User, completion: @escaping (Error?) -> ()) {
        let signUpURL = baseUrl.appendingPathComponent("user/signup")
        
        var request = URLRequest(url: signUpURL)
        request.httpMethod = HTTPMethod.post.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let jsonEncoder = JSONEncoder()
        do {
            let jsonData = try jsonEncoder.encode(user)
            request.httpBody = jsonData
        } catch {
            NSLog("Error encoding user object: \(error)")
            completion(error)
            return
        }
        URLSession.shared.dataTask(with: request) { _, response, error in         // we're not going to do anything with data, it's a post!
            if let response = response as? HTTPURLResponse,
                response.statusCode != 200 {
                // Below we make our own error using NSError class
                completion(NSError(domain: "", code: response.statusCode, userInfo: nil))
                return
            }
            if let error = error {
                NSLog("error in the URL Session calling vapor.cloud \(error) \n")
                completion(error)
            }
            completion(nil)
        }.resume()               // the dataTask has been written and completed within the closures, so let's move on
    }
    
    // create function for sign in
    func signIn(with user: User, completion: @escaping (Error?) -> ()) {
        let signInURL = baseUrl.appendingPathComponent("user/login")
        
        var request = URLRequest(url: signInURL)
        request.httpMethod = HTTPMethod.post.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let jsonEncoder = JSONEncoder()
        do {
            let jsonData = try jsonEncoder.encode(user)
            request.httpBody = jsonData
        } catch {
            NSLog("Error encoding user object: \(error)")
            completion(error)
            return
        }
        URLSession.shared.dataTask(with: request) { data, response, error in         // we're not going to do anything with data, it's a post!
            if let response = response as? HTTPURLResponse,
                response.statusCode != 200 {
                // Below we make our own error using NSError class
                completion(NSError(domain: "", code: response.statusCode, userInfo: nil))
                return
            }
            if let error = error {
                NSLog("error in the URL Session calling vapor.cloud \(error) \n")
                completion(error)
            }
            guard let data = data else {
                completion(NSError())       // blank error, so it we don't expect any errors here really
                return
            }
            let decoder = JSONDecoder()
            do {
                self.bearer = try decoder.decode(Bearer.self, from: data)
                
            } catch {
                print("Error decoding bearer object: \(error)")
                completion(error)
                return
            }
            
            completion(nil)
            }.resume()               // the dataTask has been written and completed within the closures, so let's move on
    }
    
    // create function for fetching all animal names
    
    // create function to fetch image
}
