//
//  AnimalsTableViewController.swift
//  AnimalSpotter
//
//  Created by Ben Gohlke on 4/16/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit

class AnimalsTableViewController: UITableViewController {
    
    // MARK: - Properties
    
    private var animalNames: [String] = []
    var apiController = APIController()

    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // performSegue to LoginViewController if bearer doesn't exist?
        if apiController.bearer == nil {
            performSegue(withIdentifier: "LoginViewModalSegue", sender: nil)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // transition to login view if conditions require
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return animalNames.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AnimalCell", for: indexPath)

        // Configure the cell...
        cell.textLabel?.text = animalNames[indexPath.row]

        return cell
    }

    // MARK: - Actions
    
    @IBAction func getAnimals(_ sender: UIBarButtonItem) {
        apiController.fetchAllAnimalNames { (result) in
            if let names = try? result.get() {
                // try? means you don't need a catch statement!  So no do-try-catch block required
                // if this succeeds, object will be stored in names,  but upon failure error is ignored and names will be nil, thus false, thus 'if let' gets skipped!
                DispatchQueue.main.async {
                    self.animalNames = names
                }
                // } catch {
                // if let error = error as? NetworkError {
                //     switch Error {
                //     case .noAuth:
                //         print("No bearer token exists")
                //     case .badAuth:
                //         print("
            }
        }
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "LoginViewModalSegue" {
            // inject dependencies
            if let loginVC = segue.destination as? LoginViewController {
                
                // this is dependency injection (can also use singleton?)
                loginVC.apiController = apiController
            }
        }
        if segue.identifier == "ShowAnimalDetailSegue" {
            if let indexPath = tableView.indexPathForSelectedRow,
                let detailVC = segue.destination as? AnimalDetailViewController {
                detailVC.animalName = animalNames[indexPath.row]
                detailVC.apiController = apiController
            }
        }
    }
}

// SINGLETON examples:
//                       DispatchQueue.main    main is the singleton
//                       URLSession.shared     shared is a singleton
