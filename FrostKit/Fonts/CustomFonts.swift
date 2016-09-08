//
//  CustomFonts.swift
//  FrostKit
//
//  Created by James Barrow on 02/10/2014.
//  Copyright © 2014-Current James Barrow - Frostlight Solutions. All rights reserved.
//

#if os(OSX)
import AppKit
#else
import UIKit
#endif

///
/// :FontAwesome Links:
/// - https://raw.githubusercontent.com/FortAwesome/Font-Awesome/master/less/variables.less
/// - https://github.com/FortAwesome/Font-Awesome/blob/master/fonts/fontawesome-webfont.ttf
///
/// :IonIcons Links:
/// - https://raw.githubusercontent.com/driftyco/ionicons/master/less/_ionicons-variables.less
/// - https://github.com/driftyco/ionicons/blob/master/fonts/ionicons.ttf
///
public class CustomFonts {
    
    /// Loads custom fonts imbedded in the Framework.
    public class func loadCustomFonts() {
        loadCustomFont(name: "fontawesome-webfont", withExtension: "ttf", bundle: Bundle(for: CustomFonts.self))
        loadCustomFont(name: "ionicons", withExtension: "ttf", bundle: Bundle(for: CustomFonts.self))
    }
    
    /**
    Load custom fonts with names including the file name and extension.
    
    - parameter names: An array of strings of the font file names.
    - parameter bundle:    The bundle to look for the file names in. By default this uses the main app bundle.
    */
    public class func loadCustomFonts(names: [NSString], bundle: Bundle = Bundle.main) {
        for fontName in names {
            let filename = fontName.components(separatedBy: ".").first
            let ext = fontName.pathExtension
            
            if let name = filename, name.characters.count > 0 && ext.characters.count > 0 {
                loadCustomFont(name: name, withExtension: ext, bundle: bundle)
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
    public class func loadCustomFont(name: String, withExtension ext: String, bundle: Bundle = Bundle.main) {
        
        var error: Unmanaged<CFError>?
        guard let url = bundle.url(forResource: name, withExtension: ext),
            let fontData = NSData(contentsOf: url),
            let provider = CGDataProvider(data: fontData) else {
                NSLog("ERROR: Failed to get URL for \"\(name)\" font!")
                return
        }
        
        let font = CGFont(provider)
        guard CTFontManagerRegisterGraphicsFont(font, &error) == false else {
            NSLog("ERROR: Failed to get URL for \"\(name)\" font!")
            return
        }
        
        if let anError = error {
            let errorCode = CFErrorGetCode(anError.takeRetainedValue())
            if errorCode == CTFontManagerError.alreadyRegistered.rawValue {
                NSLog("Already loaded '\(name)'")
            } else {
                let errorDescription = CFErrorCopyDescription(anError.takeRetainedValue())
                NSLog("ERROR: Failed to load '\(name)' font with error: \(errorDescription)!")
            }
        } else {
            NSLog("Loaded '\(name)' successfully")
        }
    }
    
#if os(iOS) || os(watchOS) || os(tvOS)
    /// Loops though all the fonts families loaded onto the device and prints them to the console.
    public class func printAllFontFamilies() {
        
        for fontFamily in UIFont.familyNames {
            NSLog("\(fontFamily): \(UIFont.fontNames(forFamilyName: fontFamily))")
        }
    }
#endif
    
}
