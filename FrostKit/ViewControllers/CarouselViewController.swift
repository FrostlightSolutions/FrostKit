//
//  CarouselViewController.swift
//  FrostKit
//
//  Created by James Barrow on 14/02/2015.
//  Copyright © 2015-Current James Barrow - Frostlight Solutions. All rights reserved.
//

import UIKit

public class CarouselViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UIScrollViewDelegate {
    
    enum Direction: Int {
        case none = 0
        case leftToRight = -1
        case rightToLeft = 1
    }
    
    @IBOutlet public weak var collectionView: UICollectionView! {
        didSet {
            
            collectionView.backgroundColor = .white
            collectionView.showsHorizontalScrollIndicator = false
            collectionView.showsVerticalScrollIndicator = false
            collectionView.isPagingEnabled = true
            collectionView.scrollsToTop = false
            collectionView.dataSource = self
            collectionView.delegate = self
            
            if let flowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
                
                flowLayout.scrollDirection = UICollectionViewScrollDirection.horizontal
                flowLayout.minimumInteritemSpacing = 0
                flowLayout.minimumLineSpacing = 0
                flowLayout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            }
            
            collectionView.reloadData()
        }
    }
    @IBOutlet public weak var pageControl: UIPageControl? {
        didSet {
            
            pageControl?.numberOfPages = numberOfPages
            pageControl?.addTarget(self, action: #selector(CarouselViewController.pageControlDidChange(sender:)), for: UIControlEvents.valueChanged)
        }
    }
    public var numberOfPages: Int {
        
        if collectionView.numberOfSections > 0 {
            return collectionView.numberOfItems(inSection: 0)
        } else {
            return 0
        }
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        let pageControlHeight: CGFloat = 20
        let pageControl = UIPageControl(frame: CGRect(x: 0, y: view.bounds.height - pageControlHeight, width: view.bounds.width, height: pageControlHeight))
        pageControl.autoresizingMask = [.flexibleWidth, .flexibleTopMargin]
        
    }
    
    public override func willAnimateRotation(to toInterfaceOrientation: UIInterfaceOrientation, duration: TimeInterval) {
        
        if let pageControl = self.pageControl {
            
            collectionView?.performBatchUpdates(nil, completion: { (completed) -> Void in
                self.pageControlDidChange(sender: pageControl)
            })
        }
    }
    
    // MARK: - UICollectionViewDataSource and UICollectionViewDelegate
    
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 0
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return collectionView.dequeueReusableCell(withReuseIdentifier: "CarouselCell", for: indexPath)
    }
    
    // MARK: - UICollectionViewDelegateFlowLayout
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return collectionView.frame.size
    }
    
    public override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        collectionView?.collectionViewLayout.invalidateLayout()
    }
    
    // MARK: - UIPageControl Methods
    
    final public func pageControlDidChange(sender: UIPageControl) {
        collectionView?.scrollToItem(at: IndexPath(row: sender.currentPage, section: 0), at: [], animated: true)
    }
    
    // MARK: - UIScrollViewDelegate Methods
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        // Update Page number
        let pageNumber = Int((scrollView.contentOffset.x / scrollView.bounds.width) + 0.5)
        if let pageControl = self.pageControl {
            
            if pageNumber != pageControl.currentPage && pageNumber >= 0 && scrollView.isDragging == true {
                pageControl.currentPage = pageNumber
            }
        }
        
        let xOffset = scrollView.contentOffset.x - (CGFloat(pageNumber) * scrollView.frame.width)
        let percent = xOffset / scrollView.frame.width
        
        var direction: Direction = .none
        var otherPercent = percent
        if percent > 0 {
            direction = .rightToLeft
            otherPercent = 1 - percent
        } else if percent < 0 {
            direction = .leftToRight
            otherPercent = (1 + percent) * -1
        }
        
        if let cell = collectionView?.cellForItem(at: IndexPath(row: pageNumber, section: 0)) {
            animate(view: cell, percent: percent * -1, pageNumber: pageNumber)
        }
        
        if let cell = collectionView?.cellForItem(at: IndexPath(row: pageNumber + direction.rawValue, section: 0)) {
            animate(view: cell, percent: otherPercent, pageNumber: pageNumber + direction.rawValue)
        }
    }
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
        // Update Page number
        if let pageControl = self.pageControl {
            
            let pageNumber = Int(scrollView.contentOffset.x / scrollView.bounds.width)
            pageControl.currentPage = pageNumber
        }
        
        // Reset the transform to the default
        view.layer.transform = CATransform3DIdentity
    }
    
    // MARK: - Animation Methods
    
    private func degreesToRadians(angle: CGFloat) -> CGFloat {
        return (angle/180)*CGFloat(M_PI)
    }
    
    private func animate(view: UIView, percent: CGFloat, pageNumber: Int) {
        
        let scale = percent < 0 ? percent * -1.0 : percent
        let rotateDirection: CGFloat = percent < 0 ? -1.0 : 1.0
        
        var transformation = CATransform3DIdentity
        transformation.m34 = 1.0 / -500
        
        transformation = CATransform3DRotate(transformation, degreesToRadians(angle: 45 * percent) * rotateDirection, 0, percent, 0)
        transformation = CATransform3DScale(transformation, 1 - (scale / 2), 1 - (scale / 2), 1)
        
        view.layer.transform = transformation
    }
}
