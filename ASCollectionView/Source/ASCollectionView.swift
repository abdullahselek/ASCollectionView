//
//  ASCollectionView.swift
//  ASCollectionView
//
//  Copyright © 2016 Abdullah Selek. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.

import UIKit
import QuartzCore

@objc public protocol ASCollectionViewDataSource : class {

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

@objc public protocol ASCollectionViewDelegate: UICollectionViewDelegate {
    
/**
  *  Collection view delegates to this method once hitting most bottom.
  *
  *  @param collectionView The collection view using this delegate.
*/
@objc optional func loadMoreInASCollectionView(_ asCollectionView: ASCollectionView)

}

@objcMembers public class ASCollectionView: UICollectionView, UICollectionViewDataSource {
    
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

    private var currentOrientation: UIInterfaceOrientation!
    
    // MARK: LifeCycle
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setUp()
    }
    
    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
        self.setUp()
    }
    
    private func setUp() {
        dataSource = self        
        enableLoadMore = true
        loadingMore = false
        currentOrientation = UIInterfaceOrientation.portrait
        (self.collectionViewLayout as? ASCollectionViewLayout)?.currentOrientation = currentOrientation
        NotificationCenter.default.addObserver(self, selector: #selector(ASCollectionView.orientationChanged(_:)), name: UIDevice.orientationDidChangeNotification, object: nil)
        register(UICollectionReusableView.self, forSupplementaryViewOfKind: ASCollectionViewElement.MoreLoader, withReuseIdentifier: kMoreLoaderIdentifier)
        addObserver(self, forKeyPath: kContentOffset, options: NSKeyValueObservingOptions.new, context: nil)
    }
    
    // MARK: Key-Value Observer
    
    override public func didChangeValue(forKey key: String) {
        if key == kContentOffset && self.contentOffset.equalTo(CGPoint.zero) {
            if ((currentOrientation.isPortrait && contentOffset.y > (contentSize.height - frame.size.height)) ||
                (currentOrientation.isLandscape && contentOffset.x > (contentSize.width - self.frame.size.width))) {
                    if enableLoadMore == true && !loadingMore {
                        loadMore()
                    }
            }
        }
    }
    
    public func setEnableLoadMore(_ enableLoadMore: Bool) {
        self.enableLoadMore = enableLoadMore
        self.collectionViewLayout.invalidateLayout()
    }
    
    // MARK: UICollectionViewDataSource
    
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1;
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if asDataSource != nil {
            return asDataSource!.numberOfItemsInASCollectionView(self)
        }
        return 0
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if (indexPath as NSIndexPath).row % 10 % 3 == 0 && (indexPath as NSIndexPath).row % 10 / 3 % 2 == 1 {
            let collectionViewCell: ASCollectionViewParallaxCell
            
            if !collectionView.collectionViewLayout.isKind(of: ASCollectionViewLayout.self) {
                assertionFailure("CollectionView layout should be extended ASCollectionViewLauout")
            }
            
            if let collectionViewLayout: ASCollectionViewLayout = collectionView.collectionViewLayout as? ASCollectionViewLayout {
                if let cell = asDataSource?.collectionView(self, parallaxCellForItemAtIndexPath: indexPath) {
                    collectionViewCell = cell
                
                    collectionViewCell.setMaxParallaxOffset(collectionViewLayout.maxParallaxOffset)
                    collectionViewCell.setCurrentOrienration(collectionViewLayout.currentOrientation)
                    return collectionViewCell
                }
            }
        }
        return asDataSource!.collectionView(self, cellForItemAtIndexPath: indexPath)
    }

    public func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        var reusableView : UICollectionReusableView? = nil
        if kind == ASCollectionViewElement.Header {
            if let header = asDataSource?.collectionView?(self, headerAtIndexPath: indexPath) {
                reusableView = header
                return reusableView!
            }
        } else if kind == ASCollectionViewElement.MoreLoader {
            let reusableView = self.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: kMoreLoaderIdentifier, for: indexPath)
            var moreLoaderView = reusableView.viewWithTag(1) as? UIActivityIndicatorView
            if moreLoaderView == nil {
                if let view = asDataSource?.moreLoaderInASCollectionView?(self) {
                    moreLoaderView = view as? UIActivityIndicatorView
                }
                if moreLoaderView == nil {
                    moreLoaderView = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.gray)
                    moreLoaderView?.startAnimating()
                }
                moreLoaderView!.center = CGPoint(x: reusableView.bounds.size.width / 2, y: reusableView.bounds.size.height / 2)
                moreLoaderView!.tag = 1
                reusableView.addSubview(moreLoaderView!)
                moreLoaderView?.translatesAutoresizingMaskIntoConstraints = false
                reusableView.addConstraint(NSLayoutConstraint(item: moreLoaderView!, attribute: NSLayoutConstraint.Attribute.centerX, relatedBy: NSLayoutConstraint.Relation.equal, toItem: reusableView, attribute: NSLayoutConstraint.Attribute.centerX, multiplier: 1, constant: 0))
                reusableView.addConstraint(NSLayoutConstraint(item: moreLoaderView!, attribute: NSLayoutConstraint.Attribute.centerY, relatedBy: NSLayoutConstraint.Relation.equal, toItem: reusableView, attribute: NSLayoutConstraint.Attribute.centerY, multiplier: 1, constant: 0))
            }
            return reusableView
        } else {
            assertionFailure("Unsupported view supplementary element kind")
        }
        return reusableView!
    }
    
    // MARK: Parallax Effects
    
    func doParallax() {
        let visibleCells = self.visibleCells
        for cell in visibleCells {
            if cell.isKind(of: ASCollectionViewParallaxCell.self) {
                guard let parallaxCell = cell as? ASCollectionViewParallaxCell else {
                    return
                }
                
                let bounds = self.bounds
                let boundsCenter = CGPoint(x: bounds.midX, y: bounds.midY)
                let cellCenter = parallaxCell.center
                let offsetFromCenter = CGPoint(x: boundsCenter.x - cellCenter.x, y: boundsCenter.y - cellCenter.y)
                let cellSize = parallaxCell.bounds.size
                let maxVerticalOffset = (bounds.size.height / 2) + (cellSize.height / 2)
                let scaleFactor = parallaxCell.maxParallaxOffset / maxVerticalOffset
                let parallaxOffset: CGPoint
                
                if currentOrientation.isPortrait {
                    parallaxOffset = CGPoint(x: 0, y: -offsetFromCenter.y * scaleFactor)
                } else {
                    parallaxOffset = CGPoint(x: -offsetFromCenter.x * scaleFactor, y: 0)
                }
                parallaxCell.setParallaxImageOffset(parallaxOffset)
            }
        }
    }

    // MARK: Overridden Setters / Getters

    override public var contentOffset: CGPoint {
        didSet {
            doParallax()
        }
    }
    
    // MARK: Orientation
    
    @objc func orientationChanged(_ notification: Notification) {
        currentOrientation = UIApplication.shared.statusBarOrientation
        guard let collectionViewLayout = self.collectionViewLayout as? ASCollectionViewLayout else {
            return
        }
        collectionViewLayout.currentOrientation = currentOrientation
        self.collectionViewLayout.invalidateLayout()
    }
    
    // MARK: Load More
    
    private func loadMore() {
        guard let delegate = self.delegate as? ASCollectionViewDelegate else {
            return
        }
        if delegate.conforms(to: ASCollectionViewDelegate.self) {
            loadingMore = true
            delegate.loadMoreInASCollectionView?(self)
        }
    }
    
    // MARK: Deinit
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        removeObserver(self, forKeyPath: kContentOffset)
    }

}
