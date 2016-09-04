//
//  CollectionViewController.swift
//  iOS Example
//
//  Created by James Barrow on 28/08/16.
//  Copyright © 2016 James Barrow - Frostlight Solutions. All rights reserved.
//

import UIKit
import FrostKit

class CollectionViewController: UICollectionViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        clearsSelectionOnViewWillAppear = true
        
        let refreshControl = UIRefreshControl()
        refreshControl.tintColor = UIColor.lightGrayColor()
        self.refreshControl = refreshControl
    }
    
    // MARK: - Collection View

    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }


    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 40
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("TestCollectionCell", forIndexPath: indexPath)
    
        // Configure the cell
    
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewFlowLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
        let width = (view.frame.width - collectionViewLayout.sectionInset.left - collectionViewLayout.sectionInset.right)
        return CGSize(width: width, height: 120)
    }
    
}
