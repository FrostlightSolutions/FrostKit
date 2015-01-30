//
//  ImageCacheTests.swift
//  FrostKit
//
//  Created by James Barrow on 30/01/2015.
//  Copyright (c) 2015 Frostlight Solutions. All rights reserved.
//

import UIKit
import XCTest
import FrostKit

class ImageCacheTests: XCTestCase {
    
    var image: UIImage? {
        if let filePath = NSBundle(forClass: self.dynamicType).pathForResource("SmallLogoBlue", ofType: "png") {
            return UIImage(contentsOfFile: filePath)
        }
        return nil
    }
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        if let image = self.image {
            LocalStorage.saveToDocuments(data: image, reletivePath: "", fileName: "Logo.png")
        }
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testLoadCachedImage() {
        ImageCache.shared.loadImage(directory: .DocumentDirectory, reletivePath: "", fileName: "Logo.png") { (image) -> () in
        }
        
        measureBlock { () -> Void in
            ImageCache.shared.loadImage(directory: .DocumentDirectory, reletivePath: "", fileName: "Logo.png") { (image) -> () in
                if let anImage = image {
                    XCTAssert(true, "Success!")
                } else {
                    XCTAssert(false, "Failed! No image loaded from cache")
                }
            }
        }
    }
    
    func testLoadCachedThumbnailImage() {
        ImageCache.shared.loadTumbnailImage(directory: .DocumentDirectory, reletivePath: "", fileName: "Logo.png", size: CGSize(width: 100, height: 100)) { (image) -> () in
        }
        
        measureBlock { () -> Void in
            ImageCache.shared.loadTumbnailImage(directory: .DocumentDirectory, reletivePath: "", fileName: "Logo.png", size: CGSize(width: 100, height: 100)) { (image) -> () in
                if let anImage = image {
                    XCTAssert(true, "Success!")
                } else {
                    XCTAssert(false, "Failed! No thumbnail image loaded from cache")
                }
            }
        }
    }

}
