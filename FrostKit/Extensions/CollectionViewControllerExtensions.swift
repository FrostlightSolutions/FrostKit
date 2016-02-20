//
//  CollectionViewControllerExtensions.swift
//  FrostKit
//
//  Created by James Barrow on 27/01/2015.
//  Copyright (c) 2015 Frostlight Solutions. All rights reserved.
//

import UIKit

///
/// Extention functions for UICollectionViewController
///
public extension UICollectionViewController {
    
    /// Allows easy access to a collection view controller's refrsh control the same way as in a table view controller.
    public var refreshControl: UIRefreshControl? {
        get {
            return collectionView?.viewWithTag(1404120146) as? UIRefreshControl
        }
        set {
            
            if let collectionView = self.collectionView {
                
                if let oldRefreshControl = collectionView.viewWithTag(1404120146) as? UIRefreshControl {
                    oldRefreshControl.removeFromSuperview()
                    collectionView.alwaysBounceVertical = false
                }
                
                if let refreshControl = newValue {
                    refreshControl.tag = 1404120146
                    
                    if collectionView.backgroundView == nil {
                        
                        let backgroundView = UIView(frame: collectionView.bounds)
                        backgroundView.backgroundColor = collectionView.backgroundColor
                        collectionView.backgroundView = backgroundView
                    }
                    
                    collectionView.insertSubview(refreshControl, belowSubview: collectionView.backgroundView!)
                    collectionView.alwaysBounceVertical = true
                }
            }
        }
    }
}
