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

enum NetworkError: Error {
    case noAuth
    case badAuth
    case otherError
    case badData
    case noDecode
}

class APIController {
    
    private let baseUrl = URL(string: "https://lambdaanimalspotter.vapor.cloud/api")!
    var bearer: Bearer?
    

    // create function for sign up
    func signUp(with user: User, completion: @escaping (Error?) -> ()) {
        let signUpURL = baseUrl.appendingPathComponent("users/signup")         // huge 404 error since I had user/signup not users/signup
        
        print(signUpURL)
        
        var request = URLRequest(url: signUpURL)
        request.httpMethod = HTTPMethod.post.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let jsonEncoder = JSONEncoder()
        do {
            let jsonData = try jsonEncoder.encode(user)
            
            print("\(String(data: jsonData, encoding: .utf8))")
            
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
        let signInURL = baseUrl.appendingPathComponent("users/login")
        
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
    // Result type introduced Swift 5.0 (we're 5.1 now)
    func fetchAllAnimalNames(completion: @escaping (Result<[String], NetworkError>) -> Void) {
        guard let bearer = bearer else {
            completion(.failure(.noAuth))
            return
        }
        let allAnimalsURL = baseUrl.appendingPathComponent("animals/all")
        
        var request = URLRequest(url: allAnimalsURL)
        request.httpMethod = HTTPMethod.get.rawValue
        request.addValue("Bearer \(bearer.token)", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let response = response as? HTTPURLResponse,
                response.statusCode == 401 {
                    completion(.failure(.badAuth))
                    return
            }                                                          // HANDLE ALL THE BAD STATES FIRST!
            if let error = error {
                print("Error receiving animal name data: \(error)")
                completion(.failure(.otherError))
            }
            guard let data = data else {
                completion(.failure(.badData))
                return
            }
            let decoder = JSONDecoder()
            do {
                let animalNames = try decoder.decode([String].self, from: data)
                completion(.success(animalNames))
            } catch {
                print("Error decoding animal jobjects: \(error)")
                completion(.failure(.noDecode))
                return
            }
        }.resume()
    }  // end fetchAnimals func
    
    
    
    // create function to fetch one animal & its details
    func fetchDetails(for animalName: String, completion: @escaping (Result<Animal, NetworkError>) -> Void) {
        guard let bearer = bearer else {
            completion(.failure(.noAuth))
            return
        }
        let animalURL = baseUrl.appendingPathComponent("animal/\(animalName)")
        
        var request = URLRequest(url: animalURL)
        request.httpMethod = HTTPMethod.get.rawValue
        request.addValue("Bearer \(bearer.token)", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let response = response as? HTTPURLResponse,
                response.statusCode == 401 {
                completion(.failure(.badAuth))
                return
            }                                                          // HANDLE ALL THE BAD STATES FIRST!
            if let error = error {
                print("Error receiving animal detail data: \(error)")
                completion(.failure(.otherError))
            }
            guard let data = data else {
                completion(.failure(.badData))
                return
            }
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .secondsSince1970
            do {
                let animal = try decoder.decode(Animal.self, from: data)
                completion(.success(animal))
            } catch {
                print("Error decoding animal detail: \(error)")
                completion(.failure(.noDecode))
                return
            }
            }.resume()
    }
    
    
    // create function to fetch image
    func fetchImage(at urlString: String, completion: @escaping (Result<UIImage, NetworkError>) -> Void) {
        let imageURL = URL(string: urlString)!
        
        var request = URLRequest(url: imageURL)
        request.httpMethod = HTTPMethod.get.rawValue
        
        URLSession.shared.dataTask(with: request) { (data, _, error) in
            if let error = error {
                print("error fetching image: \(error)")
                completion(.failure(.otherError))
                return
            }
            guard let data = data else {
                completion(.failure(.badData))
                return
            }
            if let image = UIImage(data: data) {
                completion(.success(image))
            } else {
                completion(.failure(.noDecode))
            }
        }.resume()
    }
    
}
