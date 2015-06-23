//
//  CustomFonts.swift
//  FrostKit
//
//  Created by James Barrow on 02/10/2014.
//  Copyright (c) 2014-2015 James Barrow - Frostlight Solutions. All rights reserved.
//

import UIKit

///
/// :FontAwesome Links:
/// - https://raw.githubusercontent.com/FortAwesome/Font-Awesome/master/less/variables.less
/// - https://github.com/FortAwesome/Font-Awesome/blob/master/fonts/fontawesome-webfont.ttf
///
/// :IonIcons Links:
/// - https://raw.githubusercontent.com/driftyco/ionicons/master/less/_ionicons-variables.less
/// - https://github.com/driftyco/ionicons/blob/master/fonts/ionicons.ttf
///
public class CustomFonts: NSObject {
    
    /// Loads custom fonts imbedded in the Framework.
    public class func loadCustomFonts() {
        loadCustomFont("fontawesome-webfont", withExtension: "ttf", bundle: NSBundle(forClass: CustomFonts.self))
        loadCustomFont("ionicons", withExtension: "ttf", bundle: NSBundle(forClass: CustomFonts.self))
    }
    
    /**
    Load custom fonts with names including the file name and extension.
    
    - parameter fontNames: An array of strings of the font file names.
    - parameter bundle:    The bundle to look for the file names in. By default this uses the main app bundle.
    */
    public class func loadCustomFonts(fontNames: [String], bundle: NSBundle = NSBundle.mainBundle()) {
        for fontName in fontNames {
            let filename = fontName.componentsSeparatedByString(".").first
            let ext = fontName.pathExtension
            
            if let name = filename where name.characters.count > 0 && ext.characters.count > 0 {
                loadCustomFont(name, withExtension: ext, bundle: bundle)
            } else {
                NSLog("ERROR: Failed to load '\(fontName)' font as the name or extension are invalid!")
            }
        }
    }
    
    /**
        Load a custom font from it's name and extention from within the bundle without having to declare it in the `Info.plist`.
        
        - parameter name:    The name of the font file name.
        - parameter ext:     The extention of the file.
        - parameter bundle:  The bundle the files are located in. By default this uses the main app bundle.
    */
    public class func loadCustomFont(name: String, withExtension ext: String, bundle: NSBundle = NSBundle.mainBundle()) {
        
        if let url = bundle.URLForResource(name, withExtension: ext) {
            let fontData = NSData(contentsOfURL: url)
            var error: Unmanaged<CFErrorRef>?
            let provider = CGDataProviderCreateWithCFData(fontData)
            if let font = CGFontCreateWithDataProvider(provider) where CTFontManagerRegisterGraphicsFont(font, &error) == false {
                if let anError = error {
                    let errorCode = CFErrorGetCode(anError.takeRetainedValue())
                    if errorCode == CTFontManagerError.AlreadyRegistered.rawValue {
                        NSLog("Already loaded '\(name)'")
                    } else {
                        let errorDescription = CFErrorCopyDescription(anError.takeRetainedValue()) as NSString
                        NSLog("ERROR: Failed to load '\(name)' font with error: \(errorDescription)!")
                    }
                }
            } else {
                NSLog("Loaded '\(name)' successfully")
            }
        } else {
            NSLog("ERROR: Failed to get URL for \"\(name)\" font!")
        }
    }
    
    /// Loops though all the fonts families loaded onto the device and prints them to the console.
    public class func printAllFontFamilies() {
        
        for fontFamily in UIFont.familyNames() {
            
            let name = fontFamily as String
            NSLog("\(name): \(UIFont.fontNamesForFamilyName(name))")
        }
    }
    
}
