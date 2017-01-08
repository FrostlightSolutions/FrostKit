//
//  TaskStoreTests.swift
//  FrostKit
//
//  Created by James Barrow on 18/06/2016.
//  Copyright © 2016 - 2017 James Barrow - Frostlight Solutions. All rights reserved.
//

import XCTest
@testable import FrostKit

class TaskStoreTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testTaskStoreAdd() {
        
        let store = TaskStore()
        
        let urlString = "https://httpbin.org/get"
        let task = URLSession.shared.dataTask(with: URL(string: urlString)!)
        _ = store.add(task, urlString: urlString)
        
        let status = store.contains(taskWithURL: urlString)
        XCTAssert(status, "Task not added to the store, but should have been.")
    }
    
    func testTaskStoreOperationAdd() {
        
        let store = TaskStore()
        
        let urlString = "https://httpbin.org/get"
        let operation = Operation()
        _ = store.add(operation, urlString: urlString)
        
        let status = store.contains(taskWithURL: urlString)
        XCTAssert(status, "OPeration not added to the store, but should have been.")
    }
    
    func testRequestStoreRemove() {
        
        let expectation = self.expectation(description: "Test Request Store")
        
        let store = TaskStore()
        
        let urlString = "https://httpbin.org/get"
        let task = URLSession.shared.dataTask(with: URL(string: urlString)!) { (_, _, _) in
            
            store.remove(taskWithURL: urlString)
            
            let status = store.contains(taskWithURL: urlString)
            XCTAssert(status == false, "Task not removed after completion, but should have been.")
            
            expectation.fulfill()
        }
        _ = store.add(task, urlString: urlString)
        task.resume()
        
        waitForExpectations(timeout: 120, handler: { (_) -> Void in })
    }
    
    func testRequestStoreOperationRemove() {
        
        let expectation = self.expectation(description: "Test Request Store")
        
        let store = TaskStore()
        
        let urlString = "https://httpbin.org/get"
        let operation = BlockOperation { 
            
            store.remove(taskWithURL: urlString)
            
            let status = store.contains(taskWithURL: urlString)
            XCTAssert(status == false, "Operation not removed after completion, but should have been.")
            
            expectation.fulfill()
        }
        _ = store.add(operation, urlString: urlString)
        operation.start()
        
        waitForExpectations(timeout: 120, handler: { (_) -> Void in })
    }
    
    func testTaskStoreDoubleAdd() {
        
        let store = TaskStore()
        
        let urlString = "https://httpbin.org/get"
        let task = URLSession.shared.dataTask(with: URL(string: urlString)!)
        _ = store.add(task, urlString: urlString)
        _ = store.add(task, urlString: urlString)
        
        let statusAdd = store.contains(taskWithURL: urlString)
        XCTAssert(statusAdd, "Task not added to the store, but should have been.")
    }
    
    func testTaskStoreOperationDoubleAdd() {
        
        let store = TaskStore()
        
        let urlString = "https://httpbin.org/get"
        let operation = Operation()
        _ = store.add(operation, urlString: urlString)
        _ = store.add(operation, urlString: urlString)
        
        let statusAdd = store.contains(taskWithURL: urlString)
        XCTAssert(statusAdd, "Operation not added to the store, but should have been.")
    }
    
    func testTaskStoreDoubleAddRemove() {
        
        let store = TaskStore()
        
        let urlString = "https://httpbin.org/get"
        let task = URLSession.shared.dataTask(with: URL(string: urlString)!)
        _ = store.add(task, urlString: urlString)
        _ = store.add(task, urlString: urlString)
        
        store.remove(taskWithURL: urlString)
        
        let statusRemove = store.contains(taskWithURL: urlString)
        XCTAssert(statusRemove == false, "Task not removed after completion, but should have been.")
    }
    
    func testTaskStoreOperationDoubleAddRemove() {
        
        let store = TaskStore()
        
        let urlString = "https://httpbin.org/get"
        let operation = Operation()
        _ = store.add(operation, urlString: urlString)
        _ = store.add(operation, urlString: urlString)
        
        store.remove(taskWithURL: urlString)
        
        let statusRemove = store.contains(taskWithURL: urlString)
        XCTAssert(statusRemove == false, "Operation not removed after completion, but should have been.")
    }
    
    func testTaskStoreLock() {
        
        let store = TaskStore()
        
        let urlString = "https://httpbin.org/get"
        let task = URLSession.shared.dataTask(with: URL(string: urlString)!)
        
        _ = store.add(task, urlString: urlString)
        
        DispatchQueue.global(qos: .default).async {
            store.cancelAllTasks()
        }
        
        var status = false
        DispatchQueue.global(qos: .default).async {
            status = store.add(task, urlString: urlString)
        }
        
        XCTAssert(status == false, "Task added, but it shouldn't have been when locked.")
    }
    
    func testTaskStoreOperationLock() {
        
        let store = TaskStore()
        
        let urlString = "https://httpbin.org/get"
        let operation = Operation()
        
        _ = store.add(operation, urlString: urlString)
        
        DispatchQueue.global(qos: .default).async {
            store.cancelAllTasks()
        }
        
        var status = false
        DispatchQueue.global(qos: .default).async {
            status = store.add(operation, urlString: urlString)
        }
        
        XCTAssert(status == false, "Operation added, but it shouldn't have been when locked.")
    }
    
    func testRequestStoreCancalAll() {
        
        let expectation = self.expectation(description: "Test Request Store")
        
        let store = TaskStore()
        
        let urlString = "https://httpbin.org/get"
        let task = URLSession.shared.dataTask(with: URL(string: urlString)!) { (_, _, _) in
            
            store.remove(taskWithURL: urlString)
            
            let status = store.contains(taskWithURL: urlString)
            XCTAssert(status == false, "Task not removed after completion, but should have been.")
            
            expectation.fulfill()
        }
        _ = store.add(task, urlString: urlString)
        task.resume()
        store.cancelAllTasks()
        
        waitForExpectations(timeout: 120, handler: { (_) -> Void in })
    }
    
    func testRequestStoreOperationCancalAll() {
        
        let expectation = self.expectation(description: "Test Request Store")
        
        let store = TaskStore()
        
        let urlString = "https://httpbin.org/get"
        let operation = BlockOperation {
            
            store.remove(taskWithURL: urlString)
            
            let status = store.contains(taskWithURL: urlString)
            XCTAssert(status == false, "Operation not removed after completion, but should have been.")
            
            expectation.fulfill()
        }
        _ = store.add(operation, urlString: urlString)
        operation.start()
        store.cancelAllTasks()
        
        waitForExpectations(timeout: 120, handler: { (_) -> Void in })
    }
    
}
