//
//  CoreDataUnitTestingTests.swift
//  CoreDataUnitTestingTests
//
//  Created by Robert Kerr on 6/16/18.
//  Copyright © 2018 kerr. All rights reserved.
//

import XCTest
import CoreData
@testable import CoreDataUnitTesting

class CoreDataUnitTestingTests: XCTestCase {
    
    var mgr: StorageManager?
    
    var managedObjectModel: NSManagedObjectModel = {
        let managedObjectModel = NSManagedObjectModel.mergedModel(from: [Bundle.main])!
        return managedObjectModel
    }()
    
    lazy var mockPersistantContainer: NSPersistentContainer = {
        
        let container = NSPersistentContainer(name: "CoreDataUnitTesting", managedObjectModel: self.managedObjectModel)
        let description = NSPersistentStoreDescription()
        description.type = NSInMemoryStoreType
        description.shouldAddStoreAsynchronously = false
        
        container.persistentStoreDescriptions = [description]
        container.loadPersistentStores { (description, error) in
            // Check if the data store is in memory
            precondition( description.type == NSInMemoryStoreType )
            
            // Check if creating container wrong
            if let error = error {
                fatalError("In memory coordinator creation failed \(error)")
            }
        }
        return container
    }()
    
    override func setUp() {
        super.setUp()
        mgr = StorageManager(container: mockPersistantContainer)
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testCheckEmpty() {
        if let mgr = self.mgr {
            let rows = mgr.fetchAll()
            XCTAssertEqual(rows.count, 0)
        } else {
            XCTFail()
        }
    }
    
    func testInsert() {
        guard let mgr = self.mgr else {
            XCTFail()
            return
        }
        
        let rowsBefore = mgr.fetchAll()
        XCTAssertEqual(rowsBefore.count, 0)
        
        for i in 1...10 {
            XCTAssertNotNil(mgr.insertPlace(city: "City \(i)", country: "Country \(i)"))
        }
        mgr.save()
        
        let rowsAfter = mgr.fetchAll()
        XCTAssertEqual(rowsAfter.count, 10)
    }
    
    func testQuery() {
        guard let mgr = self.mgr else {
            XCTFail()
            return
        }
        
        let rowsBefore = mgr.fetchAll()
        XCTAssertEqual(rowsBefore.count, 0)
        
        XCTAssertNotNil(mgr.insertPlace(city: "London", country: "UK"))
        XCTAssertNotNil(mgr.insertPlace(city: "Paris", country: "France"))
        XCTAssertNotNil(mgr.insertPlace(city: "New York", country: "USA"))
        XCTAssertNotNil(mgr.insertPlace(city: "Chicago", country: "USA"))
        XCTAssertNotNil(mgr.insertPlace(city: "Tokyo", country: "Japan"))
        XCTAssertNotNil(mgr.insertPlace(city: "Ann Arbor", country: "USA"))
        XCTAssertNotNil(mgr.insertPlace(city: "Bristol", country: "UK"))
        XCTAssertNotNil(mgr.insertPlace(city: "Rome", country: "Italy"))
        XCTAssertNotNil(mgr.insertPlace(city: "London", country: "Canada"))
        XCTAssertNotNil(mgr.insertPlace(city: "Lisbon", country: "Spain"))
        XCTAssertNotNil(mgr.insertPlace(city: "Beijing", country: "China"))
        
        mgr.save()
        
        
        var rows = mgr.fetch(country: "USA")
        XCTAssertEqual(rows.count, 3)

        rows = mgr.fetch(country: "Spain")
        XCTAssertEqual(rows.count, 1)
        
        rows = mgr.fetch(city: "London")
        XCTAssertEqual(rows.count, 2)       // test correct number of rows
        XCTAssertEqual(rows[0].country, "Canada") // test country sort order        
    }
    
    func testPerformanceExample() {
        guard let mgr = self.mgr else {
            XCTFail()
            return
        }
        
        self.measure {
            for i in 1...1000 {
                XCTAssertNotNil(mgr.insertPlace(city: "City \(i)", country: "Country \(i)"))
            }
            mgr.save()
        }
    }
}
