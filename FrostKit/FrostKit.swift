//
//  FrostKit.swift
//  FrostKit
//
//  Created by James Barrow on 03/10/2014.
//  Copyright (c) 2014 Frostlight Solutions. All rights reserved.
//

import UIKit

internal func FKLocalizedString(key: String, comment: String = "") -> String {
    return NSLocalizedString(key, bundle: NSBundle(forClass: FrostKit.self), comment: comment)
}

public class FrostKit {
    
    public var tintColor: UIColor?
    
    // MARK: - Singleton
    
    public class var shared: FrostKit {
    struct Singleton {
        static let instance : FrostKit = FrostKit()
        }
        return Singleton.instance
    }
    
    init() {
        CustomFonts.loadCustomFonts()
    }
}
