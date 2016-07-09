//
//  ASCollectionView.swift
//  ASCollectionView
//
//  Created by Abdullah Selek on 28/02/16.
//  Copyright © 2016 Abdullah Selek. All rights reserved.
//

import UIKit
import QuartzCore

@objc
public protocol ASCollectionViewDataSource : NSObjectProtocol {

/**
  *  Return number of items in collection view.
  *
  *  @param collectionView The collection view using this data source.
  *
  *  @return Number of items in collection view.
 */
func numberOfItemsInASCollectionView(asCollectionView: ASCollectionView) -> Int

/**
  *  Return grid cell for collection view at specified index path.
  *
  *  @param collectionView The collection view using this data source.
  *  @param indexPath      The index path of grid cell.
  *
  *  @return Grid cell at index path.
 */
func collectionView(asCollectionView: ASCollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell

/**
  *  Return parallax cell for collection view at specified index path.
  *
  *  @param collectionView The collection view using this data source.
  *  @param indexPath      The index path of parallax cell.
  *
  *  @return Parallax cell at index path.
 */
func collectionView(asCollectionView: ASCollectionView, parallaxCellForItemAtIndexPath indexPath: NSIndexPath) -> ASCollectionViewParallaxCell
    
/**
  *  Return header of collection view. Header must be subclass of `UICollectionReusableView`.
  *
  *  @param collectionView The collection view using this data source.
  *  @param indexPath      Used to dequeue reusable view from collection view.
  *
  *  @return Header of collection view.
 */
optional func collectionView(asCollectionView: ASCollectionView, headerAtIndexPath indexPath: NSIndexPath) -> UICollectionReusableView

/**
  *  Return more loader view of collection view. This view will be added into the section at bottom of collection view.
  *
  *  @param collectionView The collection view using this data source.
  *
  *  @return More loader view of collection view.
 */
optional func moreLoaderInASCollectionView(asCollectionView: ASCollectionView) -> UIView
    
}

@objc
public protocol ASCollectionViewDelegate: UICollectionViewDelegate {
    
/**
  *  Collection view delegates to this method once hitting most bottom.
  *
  *  @param collectionView The collection view using this delegate.
*/
optional func loadMoreInASCollectionView(asCollectionView: ASCollectionView)

}

public class ASCollectionView: UICollectionView, UICollectionViewDataSource {
    
    let kMoreLoaderIdentifier = "moreLoader"
    let kContentOffset = "contentOffset"

    /**
      *  Indicate the collection view is waiting for loading more data.
     */
    public var loadingMore: Bool!
    
    /**
      *  Indicate if the collection view has load more ability.
     */
    public var enableLoadMore: Bool!
    
    /**
      * Custom data source
     */
    public var asDataSource: ASCollectionViewDataSource?
    
    private var displayLink: CADisplayLink!
    private var currentOrientation: UIInterfaceOrientation!
    
    // MARK: LifeCycle
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setUp()
        self.setUpParallax()
    }
    
    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
        self.setUp()
        self.setUpParallax()
    }
    
    private func setUp() {
        dataSource = self        
        enableLoadMore = true
        loadingMore = false
        currentOrientation = UIInterfaceOrientation.Portrait
        (self.collectionViewLayout as? ASCollectionViewLayout)?.currentOrientation = currentOrientation
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ASCollectionView.orientationChanged(_:)), name: UIDeviceOrientationDidChangeNotification, object: nil)
        registerClass(UICollectionReusableView.self, forSupplementaryViewOfKind: ASCollectionViewElement.MoreLoader, withReuseIdentifier: kMoreLoaderIdentifier)
        addObserver(self, forKeyPath: kContentOffset, options: NSKeyValueObservingOptions.New, context: nil)
    }
    
    private func setUpParallax() {
        weak var weakSelf = self
        displayLink = CADisplayLink(target: weakSelf!, selector: #selector(ASCollectionView.doParallax(_:)))
        displayLink.frameInterval = 1
        displayLink.addToRunLoop(NSRunLoop.currentRunLoop(), forMode: NSRunLoopCommonModes)
    }
    
    // MARK: Key-Value Observer
    
    override public func didChangeValueForKey(key: String) {
        if key == kContentOffset && CGPointEqualToPoint(self.contentOffset, CGPointZero) {
            if ((UIInterfaceOrientationIsPortrait(currentOrientation) && contentOffset.y > (contentSize.height - frame.size.height)) ||
                (UIInterfaceOrientationIsLandscape(currentOrientation) && contentOffset.x > (contentSize.width - self.frame.size.width))) {
                    if enableLoadMore == true && !loadingMore {
                        loadMore()
                    }
            }
        }
    }
    
    public func setEnableLoadMore(enableLoadMore: Bool) {
        self.enableLoadMore = enableLoadMore
        self.collectionViewLayout.invalidateLayout()
    }
    
    // MARK: UICollectionViewDataSource
    
    public func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1;
    }
    
    public func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int{
        if asDataSource != nil {
            return asDataSource!.numberOfItemsInASCollectionView(self)
        }
        return 0
    }
    
    public func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        if indexPath.row % 10 % 3 == 0 && indexPath.row % 10 / 3 % 2 == 1 {
            let collectionViewCell: ASCollectionViewParallaxCell
            
            if !collectionView.collectionViewLayout.isKindOfClass(ASCollectionViewLayout) {
                assertionFailure("CollectionView layout should be extended ASCollectionViewLauout")
            }
            
            let collectionViewLayout: ASCollectionViewLayout = collectionView.collectionViewLayout as! ASCollectionViewLayout
            if let cell = asDataSource?.collectionView(self, parallaxCellForItemAtIndexPath: indexPath) {
                collectionViewCell = cell
                
                collectionViewCell.setMaxParallaxOffset(collectionViewLayout.maxParallaxOffset)
                collectionViewCell.setCurrentOrienration(collectionViewLayout.currentOrientation)
                return collectionViewCell
            }
        }
        return asDataSource!.collectionView(self, cellForItemAtIndexPath: indexPath)
    }

    public func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        var reusableView : UICollectionReusableView? = nil
        if kind == ASCollectionViewElement.Header {
            if let header = asDataSource?.collectionView?(self, headerAtIndexPath: indexPath) {
                reusableView = header
                return reusableView!
            }
        } else if kind == ASCollectionViewElement.MoreLoader {
            let reusableView = self.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: kMoreLoaderIdentifier, forIndexPath: indexPath)
            var moreLoaderView = reusableView.viewWithTag(1)
            if moreLoaderView == nil {
                if let view = asDataSource?.moreLoaderInASCollectionView?(self) {
                    moreLoaderView = view
                }
                if moreLoaderView == nil {
                    moreLoaderView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
                    (moreLoaderView as! UIActivityIndicatorView).startAnimating()
                }
                moreLoaderView!.center = CGPointMake(reusableView.bounds.size.width / 2, reusableView.bounds.size.height / 2)
                moreLoaderView!.tag = 1
                reusableView.addSubview(moreLoaderView!)
                moreLoaderView?.translatesAutoresizingMaskIntoConstraints = false
                reusableView.addConstraint(NSLayoutConstraint(item: moreLoaderView!, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: reusableView, attribute: NSLayoutAttribute.CenterX, multiplier: 1, constant: 0))
                reusableView.addConstraint(NSLayoutConstraint(item: moreLoaderView!, attribute: NSLayoutAttribute.CenterY, relatedBy: NSLayoutRelation.Equal, toItem: reusableView, attribute: NSLayoutAttribute.CenterY, multiplier: 1, constant: 0))
            }
            return reusableView
        } else {
            assertionFailure("Unsupported view supplementary element kind")
        }
        return reusableView!
    }
    
    // MARK: Parallax Effects
    
    func doParallax(displayLink: CADisplayLink) {
        let visibleCells = self.visibleCells()
        for cell in visibleCells {
            if cell.isKindOfClass(ASCollectionViewParallaxCell) {
                let parallaxCell = cell as! ASCollectionViewParallaxCell
                
                let bounds = self.bounds
                let boundsCenter = CGPointMake(CGRectGetMidX(bounds), CGRectGetMidY(bounds))
                let cellCenter = parallaxCell.center
                let offsetFromCenter = CGPointMake(boundsCenter.x - cellCenter.x, boundsCenter.y - cellCenter.y)
                let cellSize = parallaxCell.bounds.size
                let maxVerticalOffset = (bounds.size.height / 2) + (cellSize.height / 2)
                let scaleFactor = parallaxCell.maxParallaxOffset / maxVerticalOffset
                let parallaxOffset: CGPoint
                
                if UIInterfaceOrientationIsPortrait(currentOrientation) {
                    parallaxOffset = CGPointMake(0, -offsetFromCenter.y * scaleFactor)
                } else {
                    parallaxOffset = CGPointMake(-offsetFromCenter.x * scaleFactor, 0)
                }
                parallaxCell.setParallaxImageOffset(parallaxOffset)
            }
        }
    }
    
    // MARK: Orientation
    
    func orientationChanged(notification: NSNotification) {
        currentOrientation = UIApplication.sharedApplication().statusBarOrientation
        (self.collectionViewLayout as! ASCollectionViewLayout).currentOrientation = currentOrientation
        self.collectionViewLayout.invalidateLayout()
    }
    
    // MARK: Load More
    
    private func loadMore() {
        if self.delegate!.conformsToProtocol(ASCollectionViewDelegate) {
            loadingMore = true
            (self.delegate as! ASCollectionViewDelegate).loadMoreInASCollectionView!(self)
        }
    }
    
    // MARK: Deinit
    
    deinit {
        displayLink.invalidate()
        NSNotificationCenter.defaultCenter().removeObserver(self)
        removeObserver(self, forKeyPath: kContentOffset)
    }

}
