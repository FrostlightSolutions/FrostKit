//
//  MBProgressHUDExtensions.swift
//  FrostKit
//
//  Created by James Barrow on 09/02/2015.
//  Copyright © 2015-Current James Barrow - Frostlight Solutions. All rights reserved.
//

import UIKit

extension MBProgressHUD {
    
    public class func progressHUDinMainWindow() -> MBProgressHUD {
        var hud: MBProgressHUD?
        var window: UIWindow?
        if let mainWindow = UIApplication.sharedApplication().delegate?.window {
            window = mainWindow
            hud = MBProgressHUD(window: mainWindow)
        } else {
            hud = MBProgressHUD()
        }
        
        if let mainHUD = hud {
            mainHUD.mode = .Text
            mainHUD.animationType = .Fade
            mainHUD.removeFromSuperViewOnHide = true
            window?.addSubview(mainHUD)
        }
        
        return hud!
    }
    
}
