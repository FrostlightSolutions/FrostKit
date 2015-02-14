//
//  CarouselViewController.swift
//  PagedCollectionView
//
//  Created by James Barrow on 14/02/2015.
//  Copyright (c) 2015 Pig on a Hill Productions. All rights reserved.
//

import UIKit

public class CarouselViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIScrollViewDelegate {
    
    enum Direction: Int {
        case None = 0
        case LeftToRight = -1
        case RightToLeft = 1
    }
    
    public var collectionView: UICollectionView?
    public lazy var pageControl = UIPageControl()
    @IBInspectable public var numberOfPages: Int = 0 {
        didSet {
            pageControl.numberOfPages = numberOfPages
        }
    }
    @IBInspectable public var showPageControl: Bool = true {
        didSet {
            pageControl.hidden = !showPageControl
        }
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = UICollectionViewScrollDirection.Horizontal
        flowLayout.minimumInteritemSpacing = 0
        flowLayout.minimumLineSpacing = 0
        flowLayout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        
        let collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: flowLayout)
        collectionView.autoresizingMask = .FlexibleWidth | .FlexibleHeight
        collectionView.backgroundColor = UIColor.clearColor()
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.pagingEnabled = true
        collectionView.scrollsToTop = false
        collectionView.delegate = self
        collectionView.dataSource = self
        view.addSubview(collectionView)
        self.collectionView = collectionView
        
        let pageControlHeight: CGFloat = 20
        let pageControl = UIPageControl(frame: CGRect(x: 0, y: view.bounds.height - pageControlHeight, width: view.bounds.width, height: pageControlHeight))
        pageControl.autoresizingMask = .FlexibleWidth | .FlexibleTopMargin
        pageControl.numberOfPages = numberOfPages
        pageControl.addTarget(self, action: "pageControlDidChange:", forControlEvents: .ValueChanged)
        pageControl.hidden = !showPageControl
        view.addSubview(pageControl)
        self.pageControl = pageControl
    }
    
    public override func willAnimateRotationToInterfaceOrientation(toInterfaceOrientation: UIInterfaceOrientation, duration: NSTimeInterval) {
        collectionView?.performBatchUpdates(nil, completion: { (completed) -> Void in
                self.pageControlDidChange(self.pageControl)
            })
    }
    
    // MARK: - UICollectionViewDataSource
    
    public func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    public func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return numberOfPages
    }
    
    public func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        return collectionView.dequeueReusableCellWithReuseIdentifier("CarouselCell", forIndexPath: indexPath) as UICollectionViewCell
    }
    
    // MARK: - UICollectionViewDelegate
    
    
    
    // MARK: - UICollectionViewDelegateFlowLayout
    
    public func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewFlowLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return collectionView.bounds.size
    }
    
    // MARK: - UIPageControl Methods
    
    internal func pageControlDidChange(sender: UIPageControl) {
        collectionView?.scrollToItemAtIndexPath(NSIndexPath(forRow: sender.currentPage, inSection: 0), atScrollPosition: .None, animated: true)
    }
    
    // MARK: - UIScrollViewDelegate Methods
    
    public func scrollViewDidScroll(scrollView: UIScrollView) {
        
        // Update Page number
        let pageNumber = Int((scrollView.contentOffset.x / scrollView.bounds.width) + 0.5)
        if pageNumber != pageControl.currentPage && pageNumber >= 0 && scrollView.dragging == true {
            pageControl.currentPage = pageNumber
        }
        
        let xOffset = scrollView.contentOffset.x - (CGFloat(pageNumber) * scrollView.frame.width)
        let percent = xOffset / scrollView.frame.width
        
        var direction: Direction = .None
        var otherPercent = percent
        if percent > 0 {
            direction = .RightToLeft
            otherPercent = 1 - percent
        } else if percent < 0 {
            direction = .LeftToRight
            otherPercent = (1 + percent) * -1
        }
        
        if let cell = collectionView?.cellForItemAtIndexPath(NSIndexPath(forRow: pageNumber, inSection: 0)) {
            animate(cell, percent: percent * -1, pageNumber: pageNumber)
        }
        
        if let cell = collectionView?.cellForItemAtIndexPath(NSIndexPath(forRow: pageNumber + direction.rawValue, inSection: 0)) {
            animate(cell, percent: otherPercent, pageNumber: pageNumber + direction.rawValue)
        }
    }
    
    public func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        // Update Page number
        let pageNumber = Int(scrollView.contentOffset.x / scrollView.bounds.width)
        pageControl.currentPage = pageNumber
        
        if let cell = collectionView?.cellForItemAtIndexPath(NSIndexPath(forRow: pageNumber, inSection: 0)) {
            let transformation = CATransform3DIdentity
            view.layer.transform = CATransform3DIdentity
        }
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
        
        transformation = CATransform3DRotate(transformation, degreesToRadians(45 * percent) * rotateDirection, 0, percent, 0)
        transformation = CATransform3DScale(transformation, 1 - (scale / 2), 1 - (scale / 2), 1)
        
        view.layer.transform = transformation
    }
}
