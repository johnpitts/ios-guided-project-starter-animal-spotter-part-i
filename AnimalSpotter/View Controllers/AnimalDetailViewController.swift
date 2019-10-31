//
//  AnimalDetailViewController.swift
//  AnimalSpotter
//
//  Created by John Pitts on 10/31/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit

class AnimalDetailViewController: UIViewController {
    
    @IBOutlet weak var timeSeenLabel: UILabel!
    @IBOutlet weak var coordinatesLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var animalImageView: UIImageView!
    
    var animalName: String?
    var apiController: APIController?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        getDetails()
    }
    
    private func getDetails() {
        guard let apiController = apiController,
            let animalName = animalName else { return }
        
        apiController.fetchDetails(for: animalName) { (result) in
            if let animal = try? result.get() {
                DispatchQueue.main.async {
                    self.updateViews(with: animal)
                }
                apiController.fetchImage(at: animal.imageURL) { (result) in
                    if let image = try? result.get() {
                        DispatchQueue.main.async {
                            self.animalImageView.image = image
                        }
                    }
                }
            }
        }
    }
    
    
    private func updateViews(with animal: Animal) {
        title = animal.name
        descriptionLabel.text = animal.description
        coordinatesLabel.text = "lat: \(animal.latitude), long: \(animal.longitude)"
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .short
        timeSeenLabel.text = dateFormatter.string(from: animal.timeSeen)
        
    }


}
