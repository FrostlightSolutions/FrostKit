//
//  MapControllerTests.swift
//  FrostKit
//
//  Created by James Barrow on 06/02/2015.
//  Copyright (c) 2015 Frostlight Solutions. All rights reserved.
//

import UIKit
import XCTest
import FrostKit
import CoreLocation

class MapControllerTests: XCTestCase {
    
    let coordinate = CLLocationCoordinate2DMake(59.314446, 18.074375)
    let addressName = "Frostlight Solutions AB"
    let addressString = "Folkungagatan 49, 11622 Stockholm, SWEDEN"
    lazy var addressDictionary = NSDictionary()
    lazy var address = Address()
    lazy var annotation = Annotation()
    
    override func setUp() {
        super.setUp()
        
        // Put setup code here. This method is called before the invocation of each test method in the class.§
        addressDictionary = ["latitude": coordinate.latitude, "longitude": coordinate.longitude, "name": addressName, "addressString": addressString]
        address = Address(dictionary: addressDictionary)
        annotation = Annotation(address: address)
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    // MARK: - Address Tests
    
    func testAddressIsValid() {
        if address.isValid == true {
            XCTAssert(true, "Pass")
        } else {
            XCTAssert(false, "Failed! Address is invalid but should be valid.")
        }
    }
    
    func testAddressCoordinate() {
        if address.coordinate.latitude == coordinate.latitude && address.coordinate.longitude == coordinate.longitude {
            XCTAssert(true, "Pass")
        } else {
            XCTAssert(false, "Failed! Address coordinates do not match.")
        }
    }
    
    func testAddressLatitude() {
        if address.latitude == coordinate.latitude {
            XCTAssert(true, "Pass")
        } else {
            XCTAssert(false, "Failed! Address latitude is '\(address.latitude)' but should be '\(coordinate.latitude)'.")
        }
    }
    
    func testAddressLongitude() {
        if address.longitude == coordinate.longitude {
            XCTAssert(true, "Pass")
        } else {
            XCTAssert(false, "Failed! Address longitude is '\(address.longitude)' but should be '\(coordinate.longitude)'.")
        }
    }
    
    func testAddressName() {
        if address.name == addressName {
            XCTAssert(true, "Pass")
        } else {
            XCTAssert(false, "Failed! Address name is '\(address.name)' but should be '\(addressName)'.")
        }
    }
    
    func testAddressStringAddress() {
        if address.addressString == addressString {
            XCTAssert(true, "Pass")
        } else {
            XCTAssert(false, "Failed! Address simple address is '\(address.addressString)' but should be '\(addressString)'.")
        }
    }
    
    // MARK: - Annotation Tests
    
    func testAnnotationAddress() {
        if annotation.address.isEqualToAddress(address) {
            XCTAssert(true, "Pass")
        } else {
            XCTAssert(false, "Failed! Annotation address is '\(address.description)' but should be '\(address.description)'.")
        }
    }
    
    func testAnnotationUpdateAddress() {
        let annotation = Annotation()
        annotation.updateAddress(address)
        if annotation.address.isEqualToAddress(address) {
            XCTAssert(true, "Pass")
        } else {
            XCTAssert(false, "Failed! Annotation address is '\(address.description)' but should be '\(address.description)'.")
        }
    }
    
}
