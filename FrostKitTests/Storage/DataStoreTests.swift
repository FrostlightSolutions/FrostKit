//
//  DataStoreTests.swift
//  FrostKit
//
//  Created by James Barrow on 21/01/2015.
//  Copyright (c) 2015 Frostlight Solutions. All rights reserved.
//

import UIKit
import XCTest
import FrostKit

class DataStoreTests: XCTestCase {

    var dataStore: DataStore {
        let dataStore = DataStore(totalCount: 8, objectsPerPage: 3)
        dataStore.setObjects(["1", "2", "3"], page: 1)
        dataStore.setObjects(["4", "5", "6"], page: 2)
        dataStore.setObjects(["7", "8"], page: 3)
        return dataStore
    }
    var pagedJSON: [String: AnyObject] {
        if  let filePath = NSBundle(forClass: self.dynamicType).pathForResource("Notifications", ofType: "json"),
            let fileData = NSData(contentsOfFile: filePath) {
                do {
                    let jsonDict = try NSJSONSerialization.JSONObjectWithData(fileData, options: .MutableContainers) as! [String: AnyObject]
                    return jsonDict
                } catch let error as NSError {
                    NSLog("Error serializing paged JSON: \(error.localizedDescription)\n\(error)")
                }
        }
        return Dictionary<String,AnyObject>()
    }
    var nonPagedObjects: [AnyObject] {
        if let array = pagedJSON["results"] as? [AnyObject] {
            return array
        }
        return Array<AnyObject>()
    }
    var dictionary: [String:AnyObject] {
        return self.nonPagedObjects[0] as! [String:AnyObject]
    }
    var totalCount: Int {
        return pagedJSON["count"] as! Int
    }
    var objectsPerPage: Int {
        return pagedJSON["per_page"] as! Int
    }
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testDataStoreSecondPageSubscript() {
        
        let four = dataStore[3] as! String
        if four == "4" {
            XCTAssert(true, "Success! 1st item of the 2nd page is \(four)")
        } else {
            XCTAssert(false, "Failed! 1st item of the 2nd page is \(four) instead of 4")
        }
    }
    
    func testDataStoreCount() {
        
        let count = dataStore.count
        if count == 8 {
            XCTAssert(true, "Success! Count is \(count)")
        } else {
            XCTAssert(false, "Failed! Count is \(count) instead of 8")
        }
    }
    
    func testDataStoreFirstObject() {
        
        let object = dataStore.firstObject as! String
        if object == "1" {
            XCTAssert(true, "Success! First object is \(object)")
        } else {
            XCTAssert(false, "Failed! First object is \(object) instead of 1")
        }
    }
    
    func testDataStoreLastObject() {
        
        let object = dataStore.lastObject as! String
        if object == "8" {
            XCTAssert(true, "Success! Lasr object is \(object)")
        } else {
            XCTAssert(false, "Failed! Last object is \(object) instead of 1")
        }
    }
    
    func testDataStoreUpdateBiggerTotalCount() {
        
        let dataStore = self.dataStore
        dataStore.setObjects(["7", "8", "9"], page: 3, totalCount: 9)
        let count = dataStore.count
        if count == 9 {
            XCTAssert(true, "Success! Count is now \(count)")
        } else {
            XCTAssert(false, "Failed! Count is \(count) instead of 9")
        }
    }
    
    func testDataStoreUpdateSmallerTotalCount() {
        
        let dataStore = self.dataStore
        dataStore.setObjects(["4"], page: 2, totalCount: 4)
        let count = dataStore.count
        if count == 4 {
            XCTAssert(true, "Success! Count is now \(count)")
        } else {
            XCTAssert(false, "Failed! Count is \(count) instead of 4")
        }
    }
    
    func testDataStoreHash() {
        let dataStore = self.dataStore
        let hash = dataStore.hash
        if hash == 3 {
            XCTAssert(true, "Success! Hash is: \(hash)")
        } else {
            XCTAssert(false, "Failed! Hash is: \(hash) but should be 3")
        }
    }
    
    func testCreateDataStoreFromTotalCountAndObjectsPerPage() {
        measureBlock { () -> Void in
            let dataStore = DataStore(totalCount: self.totalCount, objectsPerPage: self.objectsPerPage)
            if dataStore.count > 0 {
                XCTAssert(true, "Success!")
            } else {
                XCTAssert(false, "Failed! No items in created DataStore from Total Count and Object Per Page")
            }
        }
    }
    
    func testCreateDataStoreFromJSON() {
        measureBlock { () -> Void in
            let dataStore = DataStore(json: self.pagedJSON)
            if dataStore.count > 0 {
                XCTAssert(true, "Success!")
            } else {
                XCTAssert(false, "Failed! No items in created DataStore from JSON")
            }
        }
    }
    
    func testCreateDataStoreFromNonPagedObjects() {
        measureBlock { () -> Void in
            let dataStore = DataStore(nonPagedObjects: self.nonPagedObjects)
            if dataStore.count > 0 {
                XCTAssert(true, "Success!")
            } else {
                XCTAssert(false, "Failed! No items in created DataStore from Non-Paged Objects")
            }
        }
    }
    
    func testCreateDataStoreFromDictionary() {
        measureBlock { () -> Void in
            let dataStore = DataStore(dictionary: self.dictionary)
            if dataStore.count > 0 {
                XCTAssert(true, "Success!")
            } else {
                XCTAssert(false, "Failed! No items in created DataStore from Dictionary")
            }
        }
    }
    
    func testCreateDataStoreFromObjectJSON() {
        measureBlock { () -> Void in
            let dataStore = DataStore(object: self.pagedJSON)
            if dataStore.count > 0 {
                XCTAssert(true, "Success!")
            } else {
                XCTAssert(false, "Failed! No items in created DataStore from Object -> JSON")
            }
        }
    }
    
    func testCreateDataStoreFromObjectNonPagedObjects() {
        measureBlock { () -> Void in
            let dataStore = DataStore(object: self.nonPagedObjects)
            if dataStore.count > 0 {
                XCTAssert(true, "Success!")
            } else {
                XCTAssert(false, "Failed! No items in created DataStore from Object -> Non-Paged Objects")
            }
        }
    }
    
    func testCreateDataStoreFromObjectDictionary() {
        measureBlock { () -> Void in
            let dataStore = DataStore(object: self.dictionary)
            if dataStore.count > 0 {
                XCTAssert(true, "Success!")
            } else {
                XCTAssert(false, "Failed! No items in created DataStore from Object -> Dictionary")
            }
        }
    }

}
