//
//  CollectionViewControllerExtensions.swift
//  FrostKit
//
//  Created by James Barrow on 27/01/2015.
//  Copyright © 2015 - 2017 James Barrow - Frostlight Solutions. All rights reserved.
//

import UIKit

///
/// Extention functions for UICollectionViewController
///
public extension UICollectionViewController {
    
    /// Allows easy access to a collection view controller's refrsh control the same way as in a table view controller.
    var refreshControl: UIRefreshControl? {
        get {
            if #available(iOS 10, *) {
                return collectionView?.refreshControl
            } else {
                return collectionView?.viewWithTag(1_404_120_146) as? UIRefreshControl
            }
        }
        set {
            
            if #available(iOS 10, *) {
                collectionView?.refreshControl = newValue
            } else {
                
                guard let collectionView = self.collectionView else {
                    return
                }
                
                if let oldRefreshControl = collectionView.viewWithTag(1_404_120_146) as? UIRefreshControl {
                    oldRefreshControl.removeFromSuperview()
                    collectionView.alwaysBounceVertical = false
                }
                
                if let refreshControl = newValue {
                    refreshControl.tag = 1_404_120_146
                    
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
