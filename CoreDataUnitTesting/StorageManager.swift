//
//  StorageManager.swift
//  CoreDataUnitTesting
//
//  Created by Robert Kerr on 6/16/18.
//  Copyright © 2018 kerr. All rights reserved.
//

import UIKit
import CoreData

class StorageManager {
    
    let persistentContainer: NSPersistentContainer!
    
    //MARK: Init with dependency
    init(container: NSPersistentContainer) {
        self.persistentContainer = container
        self.persistentContainer.viewContext.automaticallyMergesChangesFromParent = true
    }
    
    convenience init() {
        //Use the default container for production environment
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            fatalError("AppDelegate unavailable")
        }
        self.init(container: appDelegate.persistentContainer)
    }
    
    lazy var backgroundContext: NSManagedObjectContext = {
        return self.persistentContainer.newBackgroundContext()
    }()
    
    //MARK: CRUD
    @discardableResult func insertPlace( city: String, country: String ) -> Place? {
        guard let place = NSEntityDescription.insertNewObject(forEntityName: "Place", into: backgroundContext) as? Place else { return nil }
        
        place.city = city
        place.country = country
        
        return place
    }
    
    func fetchAll(sorted: Bool = true) -> [Place] {
        let request: NSFetchRequest<Place> = Place.fetchRequest()
        
        if sorted {
            let countrySort = NSSortDescriptor(key: #keyPath(Place.country), ascending: true)
            let citySort = NSSortDescriptor(key: #keyPath(Place.city), ascending: true)
            request.sortDescriptors = [countrySort, citySort]
        }
        
        let results = try? persistentContainer.viewContext.fetch(request)
        return results ?? [Place]()
    }
    
    func fetch(country: String) -> [Place] {
        let request: NSFetchRequest<Place> = Place.fetchRequest()
        
        request.predicate = NSPredicate(format: "country == %@", country)
        
        let citySort = NSSortDescriptor(key: #keyPath(Place.city), ascending: true)
        request.sortDescriptors = [citySort]
        
        let results = try? persistentContainer.viewContext.fetch(request)
        return results ?? [Place]()
    }
    
    func fetch(city: String) -> [Place] {
        let request: NSFetchRequest<Place> = Place.fetchRequest()
        
        request.predicate = NSPredicate(format: "city == %@", city)
        
        let countrySort = NSSortDescriptor(key: #keyPath(Place.country), ascending: true)
        request.sortDescriptors = [countrySort]
        
        let results = try? persistentContainer.viewContext.fetch(request)
        return results ?? [Place]()
    }
    
    func remove( objectID: NSManagedObjectID ) {
        let obj = backgroundContext.object(with: objectID)
        backgroundContext.delete(obj)
    }
    
    func save() {
        if backgroundContext.hasChanges {
            do {
                try backgroundContext.save()
            } catch {
                print("Save error \(error)")
            }
        }
        
    }
}

