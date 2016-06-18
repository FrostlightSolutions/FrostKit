//
//  MapControllerTests.swift
//  FrostKit
//
//  Created by James Barrow on 06/02/2015.
//  Copyright © 2015-Current James Barrow - Frostlight Solutions. All rights reserved.
//

import XCTest
import CoreLocation
@testable import FrostKit

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
        
        measure { () -> Void in
            
            if self.address.isValid == true {
                XCTAssert(true, "Pass")
            } else {
                XCTAssert(false, "Failed! Address is invalid but should be valid.")
            }
        }
    }
    
    func testAddressCoordinate() {
        
        measure { () -> Void in
            
            if self.address.coordinate.latitude == self.coordinate.latitude && self.address.coordinate.longitude == self.coordinate.longitude {
                XCTAssert(true, "Pass")
            } else {
                XCTAssert(false, "Failed! Address coordinates do not match.")
            }
        }
    }
    
    func testAddressLatitude() {
        
        measure { () -> Void in
            
            if self.address.latitude == self.coordinate.latitude {
                XCTAssert(true, "Pass")
            } else {
                XCTAssert(false, "Failed! Address latitude is '\(self.address.latitude)' but should be '\(self.coordinate.latitude)'.")
            }
        }
    }
    
    func testAddressLongitude() {
        
        measure { () -> Void in
            
            if self.address.longitude == self.coordinate.longitude {
                XCTAssert(true, "Pass")
            } else {
                XCTAssert(false, "Failed! Address longitude is '\(self.address.longitude)' but should be '\(self.coordinate.longitude)'.")
            }
        }
    }
    
    func testAddressName() {
        
        measure { () -> Void in
            
            if self.address.name == self.addressName {
                XCTAssert(true, "Pass")
            } else {
                XCTAssert(false, "Failed! Address name is '\(self.address.name)' but should be '\(self.addressName)'.")
            }
        }
    }
    
    func testAddressStringAddress() {
        
        measure { () -> Void in
            
            if self.address.addressString == self.addressString {
                XCTAssert(true, "Pass")
            } else {
                XCTAssert(false, "Failed! Address simple address is '\(self.address.addressString)' but should be '\(self.addressString)'.")
            }
        }
    }
    
    // MARK: - Annotation Tests
    
    func testAnnotationAddress() {
        
        measure { () -> Void in
            
            if self.annotation.address == self.address {
                XCTAssert(true, "Pass")
            } else {
                XCTAssert(false, "Failed! Annotation address is '\(self.address.description)' but should be '\(self.address.description)'.")
            }
        }
    }
    
    func testAnnotationUpdateAddress() {
        
        measure { () -> Void in
            
            let annotation = Annotation()
            annotation.updateAddress(self.address)
            if annotation.address == self.address {
                XCTAssert(true, "Pass")
            } else {
                XCTAssert(false, "Failed! Annotation address is '\(self.address.description)' but should be '\(self.address.description)'.")
            }
        }
    }
    
}
