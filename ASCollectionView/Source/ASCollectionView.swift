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
func numberOfItemsInASCollectionView(_ asCollectionView: ASCollectionView) -> Int

/**
  *  Return grid cell for collection view at specified index path.
  *
  *  @param collectionView The collection view using this data source.
  *  @param indexPath      The index path of grid cell.
  *
  *  @return Grid cell at index path.
 */
func collectionView(_ asCollectionView: ASCollectionView, cellForItemAtIndexPath indexPath: IndexPath) -> UICollectionViewCell

/**
  *  Return parallax cell for collection view at specified index path.
  *
  *  @param collectionView The collection view using this data source.
  *  @param indexPath      The index path of parallax cell.
  *
  *  @return Parallax cell at index path.
 */
func collectionView(_ asCollectionView: ASCollectionView, parallaxCellForItemAtIndexPath indexPath: IndexPath) -> ASCollectionViewParallaxCell
    
/**
  *  Return header of collection view. Header must be subclass of `UICollectionReusableView`.
  *
  *  @param collectionView The collection view using this data source.
  *  @param indexPath      Used to dequeue reusable view from collection view.
  *
  *  @return Header of collection view.
 */
@objc optional func collectionView(_ asCollectionView: ASCollectionView, headerAtIndexPath indexPath: IndexPath) -> UICollectionReusableView

/**
  *  Return more loader view of collection view. This view will be added into the section at bottom of collection view.
  *
  *  @param collectionView The collection view using this data source.
  *
  *  @return More loader view of collection view.
 */
@objc optional func moreLoaderInASCollectionView(_ asCollectionView: ASCollectionView) -> UIView
    
}

@objc
public protocol ASCollectionViewDelegate: UICollectionViewDelegate {
    
/**
  *  Collection view delegates to this method once hitting most bottom.
  *
  *  @param collectionView The collection view using this delegate.
*/
@objc optional func loadMoreInASCollectionView(_ asCollectionView: ASCollectionView)

}

open class ASCollectionView: UICollectionView, UICollectionViewDataSource {
    
    let kMoreLoaderIdentifier = "moreLoader"
    let kContentOffset = "contentOffset"

    /**
      *  Indicate the collection view is waiting for loading more data.
     */
    open var loadingMore: Bool!
    
    /**
      *  Indicate if the collection view has load more ability.
     */
    open var enableLoadMore: Bool!
    
    /**
      * Custom data source
     */
    open var asDataSource: ASCollectionViewDataSource?
    
    fileprivate var displayLink: CADisplayLink!
    fileprivate var currentOrientation: UIInterfaceOrientation!
    
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
    
    fileprivate func setUp() {
        dataSource = self        
        enableLoadMore = true
        loadingMore = false
        currentOrientation = UIInterfaceOrientation.portrait
        (self.collectionViewLayout as? ASCollectionViewLayout)?.currentOrientation = currentOrientation
        NotificationCenter.default.addObserver(self, selector: #selector(ASCollectionView.orientationChanged(_:)), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
        register(UICollectionReusableView.self, forSupplementaryViewOfKind: ASCollectionViewElement.MoreLoader, withReuseIdentifier: kMoreLoaderIdentifier)
        addObserver(self, forKeyPath: kContentOffset, options: NSKeyValueObservingOptions.new, context: nil)
    }
    
    fileprivate func setUpParallax() {
        weak var weakSelf = self
        displayLink = CADisplayLink(target: weakSelf!, selector: #selector(ASCollectionView.doParallax(_:)))
        if #available(iOS 10.0, *) {
            displayLink.preferredFramesPerSecond = 1
        } else {
            displayLink.frameInterval = 1
        }
        displayLink.add(to: RunLoop.current, forMode: RunLoopMode.commonModes)
    }
    
    // MARK: Key-Value Observer
    
    override open func didChangeValue(forKey key: String) {
        if key == kContentOffset && self.contentOffset.equalTo(CGPoint.zero) {
            if ((UIInterfaceOrientationIsPortrait(currentOrientation) && contentOffset.y > (contentSize.height - frame.size.height)) ||
                (UIInterfaceOrientationIsLandscape(currentOrientation) && contentOffset.x > (contentSize.width - self.frame.size.width))) {
                    if enableLoadMore == true && !loadingMore {
                        loadMore()
                    }
            }
        }
    }
    
    open func setEnableLoadMore(_ enableLoadMore: Bool) {
        self.enableLoadMore = enableLoadMore
        self.collectionViewLayout.invalidateLayout()
    }
    
    // MARK: UICollectionViewDataSource
    
    open func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1;
    }
    
    open func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int{
        if asDataSource != nil {
            return asDataSource!.numberOfItemsInASCollectionView(self)
        }
        return 0
    }
    
    open func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if (indexPath as NSIndexPath).row % 10 % 3 == 0 && (indexPath as NSIndexPath).row % 10 / 3 % 2 == 1 {
            let collectionViewCell: ASCollectionViewParallaxCell
            
            if !collectionView.collectionViewLayout.isKind(of: ASCollectionViewLayout.self) {
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

    open func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        var reusableView : UICollectionReusableView? = nil
        if kind == ASCollectionViewElement.Header {
            if let header = asDataSource?.collectionView?(self, headerAtIndexPath: indexPath) {
                reusableView = header
                return reusableView!
            }
        } else if kind == ASCollectionViewElement.MoreLoader {
            let reusableView = self.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: kMoreLoaderIdentifier, for: indexPath)
            var moreLoaderView = reusableView.viewWithTag(1)
            if moreLoaderView == nil {
                if let view = asDataSource?.moreLoaderInASCollectionView?(self) {
                    moreLoaderView = view
                }
                if moreLoaderView == nil {
                    moreLoaderView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
                    (moreLoaderView as! UIActivityIndicatorView).startAnimating()
                }
                moreLoaderView!.center = CGPoint(x: reusableView.bounds.size.width / 2, y: reusableView.bounds.size.height / 2)
                moreLoaderView!.tag = 1
                reusableView.addSubview(moreLoaderView!)
                moreLoaderView?.translatesAutoresizingMaskIntoConstraints = false
                reusableView.addConstraint(NSLayoutConstraint(item: moreLoaderView!, attribute: NSLayoutAttribute.centerX, relatedBy: NSLayoutRelation.equal, toItem: reusableView, attribute: NSLayoutAttribute.centerX, multiplier: 1, constant: 0))
                reusableView.addConstraint(NSLayoutConstraint(item: moreLoaderView!, attribute: NSLayoutAttribute.centerY, relatedBy: NSLayoutRelation.equal, toItem: reusableView, attribute: NSLayoutAttribute.centerY, multiplier: 1, constant: 0))
            }
            return reusableView
        } else {
            assertionFailure("Unsupported view supplementary element kind")
        }
        return reusableView!
    }
    
    // MARK: Parallax Effects
    
    func doParallax(_ displayLink: CADisplayLink) {
        let visibleCells = self.visibleCells
        for cell in visibleCells {
            if cell.isKind(of: ASCollectionViewParallaxCell.self) {
                let parallaxCell = cell as! ASCollectionViewParallaxCell
                
                let bounds = self.bounds
                let boundsCenter = CGPoint(x: bounds.midX, y: bounds.midY)
                let cellCenter = parallaxCell.center
                let offsetFromCenter = CGPoint(x: boundsCenter.x - cellCenter.x, y: boundsCenter.y - cellCenter.y)
                let cellSize = parallaxCell.bounds.size
                let maxVerticalOffset = (bounds.size.height / 2) + (cellSize.height / 2)
                let scaleFactor = parallaxCell.maxParallaxOffset / maxVerticalOffset
                let parallaxOffset: CGPoint
                
                if UIInterfaceOrientationIsPortrait(currentOrientation) {
                    parallaxOffset = CGPoint(x: 0, y: -offsetFromCenter.y * scaleFactor)
                } else {
                    parallaxOffset = CGPoint(x: -offsetFromCenter.x * scaleFactor, y: 0)
                }
                parallaxCell.setParallaxImageOffset(parallaxOffset)
            }
        }
    }
    
    // MARK: Orientation
    
    func orientationChanged(_ notification: Notification) {
        currentOrientation = UIApplication.shared.statusBarOrientation
        (self.collectionViewLayout as! ASCollectionViewLayout).currentOrientation = currentOrientation
        self.collectionViewLayout.invalidateLayout()
    }
    
    // MARK: Load More
    
    fileprivate func loadMore() {
        if self.delegate!.conforms(to: ASCollectionViewDelegate.self) {
            loadingMore = true
            (self.delegate as! ASCollectionViewDelegate).loadMoreInASCollectionView!(self)
        }
    }
    
    // MARK: Deinit
    
    deinit {
        displayLink.invalidate()
        NotificationCenter.default.removeObserver(self)
        removeObserver(self, forKeyPath: kContentOffset)
    }

}
