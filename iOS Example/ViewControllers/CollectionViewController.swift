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
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        clearsSelectionOnViewWillAppear = true
        
        let refreshControl = UIRefreshControl()
        refreshControl.tintColor = UIColor.lightGray
        refreshControl.addTarget(self, action: #selector(refreshControlTriggered(_:)), for: .valueChanged)
        self.refreshControl = refreshControl
    }
    
    // MARK: - Actions
    
    func refreshControlTriggered(_ sender: AnyObject) {
        _ = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(endRefreshing), userInfo: nil, repeats: false)
    }
    
    func endRefreshing() {
        
        if let refreshControl = self.refreshControl, refreshControl.isRefreshing == true {
            refreshControl.endRefreshing()
        }
    }
    
    // MARK: - Collection View
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 40
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TestCollectionCell", for: indexPath as IndexPath)
        
        // Configure the cell
        cell.backgroundColor = .orange
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewFlowLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
        let width = (view.frame.width - collectionViewLayout.sectionInset.left - collectionViewLayout.sectionInset.right)
        return CGSize(width: width, height: 120)
    }
}
