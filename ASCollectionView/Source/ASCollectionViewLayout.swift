//
//  ASCollectionViewLayout.swift
//  ASCollectionView
//
//  Created by Abdullah Selek on 27/02/16.
//  Copyright © 2016 Abdullah Selek. All rights reserved.
//

import UIKit

public struct ASCollectionViewElement {
    public static let Header = "Header"
    public static let MoreLoader = "MoreLoader"
}

open class ASCollectionViewLayout: UICollectionViewLayout {
    
    let SECTION = 0
    let NUMBEROFITEMSINGROUP = 10
    
    /**
      *  Grid cell size. Default value is (200, 100).
     */
    open var gridCellSize: CGSize!
    
    /**
      *  Parallax cell size. Default value is (400, 200).
     */
    open var parallaxCellSize: CGSize!
    
    /**
      *  Header size. Default value is (200, 200).
      *
      *  Set (0, 0) for no header
     */
    open var headerSize: CGSize!
    
    /**
      *  Size for more loader section. Default value is (50, 50).
     */
    open var moreLoaderSize: CGSize!
    
    /**
      *  Space between grid cells. Default value is (10, 10).
     */
    open var gridCellSpacing: CGSize!
    
    /**
      *  Padding for grid. Default value is 20.
     */
    open var gridPadding: CGFloat! = 20.0
    
    /**
      *  Maximum parallax offset. Default value is 50.
     */
    open var maxParallaxOffset: CGFloat! = 50.0
    
    /**
      *  Current orientation, used to layout correctly corresponding to orientation.
     */
    open var currentOrientation: UIInterfaceOrientation!
    
    /**
      * Internal variables
     */
    fileprivate var contentSize: CGSize!
    fileprivate var groupSize: CGSize!
    fileprivate var internalGridCellSize: CGSize!
    fileprivate var internalParallaxCellSize: CGSize!
    fileprivate var previousBoundsSize: CGSize!
    fileprivate var cellAttributes: NSMutableDictionary!
    fileprivate var headerAttributes: UICollectionViewLayoutAttributes!
    fileprivate var moreLoaderAttributes: UICollectionViewLayoutAttributes!
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setDefaultValues()
    }
    
    override init() {
        super.init()
        self.setDefaultValues()
    }
    
    override open func prepare() {        
        internalGridCellSize = self.gridCellSize
        internalParallaxCellSize = self.parallaxCellSize
        
        // Calculate content height
        calculateContentSize()
        // Calculate cell size
        calculateCellSize()
        // Calculate cell attributes
        calculateCellAttributes()
        // Calculate header attributes
        calculateHeaderAttributes()
        // Calculate more loader attributes
        calculateMoreLoaderAttributes()
    }
    
    override open var collectionViewContentSize : CGSize {
        return contentSize
    }
    
    override open func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var result = [UICollectionViewLayoutAttributes]()
        let numberOfItems = self.collectionView!.numberOfItems(inSection: 0)
        
        for itemCount in 0 ..< numberOfItems {
            let indexPath = IndexPath(item: itemCount, section: SECTION)
            let attributes = cellAttributes.object(forKey: indexPath) as! UICollectionViewLayoutAttributes
            
            if rect.intersects(attributes.frame) {
                result.append(attributes)
            }
        }
        
        // now add header attributes if it is in rect
        if headerAttributes != nil && rect.intersects(headerAttributes.frame) == true {
            result.append(headerAttributes)
        }
        
        // add more loader attributes if it is in rect
        if moreLoaderAttributes != nil && rect.intersects(moreLoaderAttributes.frame) == true {
            result.append(moreLoaderAttributes)
        }
        
        return result
    }
    
    override open func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return cellAttributes.object(forKey: indexPath) as? UICollectionViewLayoutAttributes
    }
    
    override open func layoutAttributesForSupplementaryView(ofKind elementKind: String, at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return headerAttributes
    }
    
    override open func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        if previousBoundsSize.equalTo(newBounds.size) {
            previousBoundsSize = newBounds.size
            return true
        }
        return false
    }
    
    // MARK: Calculation methods
    
    fileprivate func calculateContentSize() {
        if self.collectionView == nil {
            return
        }
        
        let numberOfItems = self.collectionView!.numberOfItems(inSection: SECTION)
        groupSize = CGSize()
        contentSize = CGSize()
        if UIInterfaceOrientationIsPortrait(currentOrientation) {
            groupSize.width = self.collectionView!.bounds.size.width
            groupSize.height = internalGridCellSize.height * 6 + gridCellSpacing.height * 4 + internalParallaxCellSize.height * 2 + gridPadding * 4
            
            contentSize.width = self.collectionView!.bounds.size.width
            contentSize.height = groupSize.height * CGFloat(numberOfItems / 10)
        } else {
            groupSize.width = internalGridCellSize.width * 6 + self.gridCellSpacing.width * 4 + internalParallaxCellSize.width * 2 + self.gridPadding * 4
            groupSize.height = self.collectionView!.bounds.size.height
            contentSize.width = groupSize.width * CGFloat(numberOfItems / 10)
            contentSize.height = self.collectionView!.bounds.size.height
        }
        
        let numberOfItemsInLastGroup = numberOfItems % 10
        let enableLoadMore = (self.collectionView as! ASCollectionView).enableLoadMore
        
        if UIInterfaceOrientationIsPortrait(self.currentOrientation) {
            if numberOfItemsInLastGroup > 0 {
                contentSize.height += internalGridCellSize.height + self.gridPadding
            }
            if numberOfItemsInLastGroup > 1 {
                contentSize.height += internalGridCellSize.height + self.gridCellSpacing.height
            }
            if numberOfItemsInLastGroup > 3 {
                contentSize.height += internalParallaxCellSize.height + self.gridPadding
            }
            if numberOfItemsInLastGroup > 4 {
                contentSize.height += internalGridCellSize.height + self.gridPadding
            }
            if numberOfItemsInLastGroup > 6 {
                contentSize.height += internalGridCellSize.height * 2 + self.gridCellSpacing.height * 2
            }
            if numberOfItemsInLastGroup > 7 {
                contentSize.height += internalGridCellSize.height + self.gridCellSpacing.height
            }
            contentSize.height += self.headerSize.height
            contentSize.height += (enableLoadMore == true) ? self.moreLoaderSize.height : 0
        } else {
            if numberOfItemsInLastGroup > 0 {
                contentSize.width += internalGridCellSize.width + self.gridPadding
            }
            if numberOfItemsInLastGroup > 1 {
                contentSize.width += internalGridCellSize.width + self.gridCellSpacing.width
            }
            if numberOfItemsInLastGroup > 3 {
                contentSize.width += internalParallaxCellSize.width + self.gridPadding
            }
            if numberOfItemsInLastGroup > 4 {
                contentSize.width += internalGridCellSize.width + self.gridPadding
            }
            if numberOfItemsInLastGroup > 5 {
                contentSize.width += internalGridCellSize.width * 2 + self.gridCellSpacing.width * 2
            }
            if numberOfItemsInLastGroup > 7 {
                contentSize.width += internalGridCellSize.width + self.gridCellSpacing.width
            }
            contentSize.width += self.headerSize.width
            contentSize.width += (enableLoadMore == true) ? self.moreLoaderSize.width : 0
        }
    }
    
    fileprivate func calculateCellSize() {
        if self.collectionView == nil {
            return
        }
        
        if UIInterfaceOrientationIsPortrait(self.currentOrientation) {
            internalGridCellSize.width = (self.collectionView!.frame.size.width - self.gridCellSpacing.width - self.gridPadding * 2) / 2
            internalParallaxCellSize.width = self.collectionView!.frame.size.width
        } else {
            internalGridCellSize.height = (self.collectionView!.frame.size.height - self.gridCellSpacing.height - self.gridPadding * 2) / 2
            internalParallaxCellSize.height = self.collectionView!.frame.size.height
        }
    }
    
    fileprivate func calculateCellAttributes() {
        if self.collectionView == nil {
            return
        }
        
        let numberOfItems = self.collectionView!.numberOfItems(inSection: SECTION)
        
        cellAttributes = NSMutableDictionary(capacity: numberOfItems)
        for itemCount in 0 ..< numberOfItems {
            let indexPath = IndexPath(item: itemCount, section: SECTION)
            let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
            cellAttributes.setObject(attributes, forKey: indexPath as NSCopying)
        }
        
        var x: CGFloat = self.gridPadding
        var y: CGFloat = self.gridPadding
        
        // space for header
        if UIInterfaceOrientationIsPortrait(self.currentOrientation) {
            y += headerSize.height
        } else {
            x += headerSize.width
        }
        
        for itemCount in 0 ..< numberOfItems {
            let indexInGroup = itemCount % NUMBEROFITEMSINGROUP
            let indexPath = IndexPath(item: itemCount, section: SECTION)
            let attributes = cellAttributes.object(forKey: indexPath) as! UICollectionViewLayoutAttributes
            var frame = CGRect.zero
            
            if UIInterfaceOrientationIsPortrait(self.currentOrientation) {
                switch (indexInGroup) {
                case 0:
                    frame = CGRect(x: x, y: y, width: internalGridCellSize.width, height: internalGridCellSize.height)
                    break
                case 1:
                    frame = CGRect(x: x + internalGridCellSize.width + self.gridCellSpacing.width, y: y, width: internalGridCellSize.width, height: internalGridCellSize.height * 2 + self.gridCellSpacing.height)
                    y += frame.size.height + self.gridPadding
                    break
                case 2:
                    frame = CGRect(x: x, y: y - internalGridCellSize.height - self.gridPadding, width: internalGridCellSize.width, height: internalGridCellSize.height)
                    
                    break
                case 3:
                    frame = CGRect(x: 0, y: y, width: internalParallaxCellSize.width, height: internalParallaxCellSize.height)
                    y += frame.size.height + self.gridPadding
                    break
                case 4:
                    frame = CGRect(x: x, y: y, width: internalGridCellSize.width, height: internalGridCellSize.height)
                    break
                case 5:
                    frame = CGRect(x: x + internalGridCellSize.width + self.gridCellSpacing.width, y: y, width: internalGridCellSize.width, height: internalGridCellSize.height)
                    y += frame.size.height + self.gridCellSpacing.height
                    break
                case 6:
                    frame = CGRect(x: x, y: y, width: internalGridCellSize.width * 2 + self.gridCellSpacing.width, height: internalGridCellSize.height * 2 + self.gridCellSpacing.height)
                    y += frame.size.height + self.gridCellSpacing.height
                    break
                case 7:
                    frame = CGRect(x: x, y: y, width: internalGridCellSize.width, height: internalGridCellSize.height)
                    break
                case 8:
                    frame = CGRect(x: x + internalGridCellSize.width + self.gridCellSpacing.width, y: y, width: internalGridCellSize.width, height: internalGridCellSize.height)
                    y += frame.size.height + self.gridPadding
                    break
                case 9:
                    frame = CGRect(x: 0, y: y, width: internalParallaxCellSize.width, height: internalParallaxCellSize.height)
                    y += frame.size.height + self.gridPadding
                    break
                default:
                    break
                }
            } else {
                switch (indexInGroup) {
                case 0:
                    frame = CGRect(x: x, y: y, width: internalGridCellSize.width, height: internalGridCellSize.height)
                    break
                case 1:
                    frame = CGRect(x: x + internalGridCellSize.width + self.gridCellSpacing.width, y: y, width: internalGridCellSize.width, height: internalGridCellSize.height * 2 + self.gridCellSpacing.height)
                    break
                case 2:
                    frame = CGRect(x: x, y: y + internalGridCellSize.height + self.gridCellSpacing.height, width: internalGridCellSize.width, height: internalGridCellSize.height)
                    x += internalGridCellSize.width * 2 + self.gridCellSpacing.width + self.gridPadding
                    break
                case 3:
                    frame = CGRect(x: x, y: 0, width: internalParallaxCellSize.width, height: internalParallaxCellSize.height)
                    x += frame.size.width + self.gridPadding
                    break
                case 4:
                    frame = CGRect(x: x, y: y, width: internalGridCellSize.width, height: internalGridCellSize.height)
                    break
                case 5:
                    frame = CGRect(x: x + internalGridCellSize.width + self.gridCellSpacing.width, y: y, width: internalGridCellSize.width * 2 + self.gridCellSpacing.width, height: internalGridCellSize.height * 2 + self.gridCellSpacing.height)
                    break
                case 6:
                    frame = CGRect(x: x, y: y + internalGridCellSize.height + self.gridCellSpacing.height, width: internalGridCellSize.width, height: internalGridCellSize.height)
                    x += internalGridCellSize.width * 3 + self.gridCellSpacing.width * 3
                    break
                case 7:
                    frame = CGRect(x: x, y: y, width: internalGridCellSize.width, height: internalGridCellSize.height)
                    break
                case 8:
                    frame = CGRect(x: x, y: y + internalGridCellSize.height + self.gridCellSpacing.height, width: internalGridCellSize.width, height: internalGridCellSize.height)
                    x += frame.size.width + self.gridPadding
                    break
                case 9:
                    frame = CGRect(x: x, y: 0, width: internalParallaxCellSize.width, height: internalParallaxCellSize.height)
                    x += frame.size.width + self.gridPadding
                    break
                default:
                    break
                }
            }
            attributes.frame = frame
        }
    }
    
    fileprivate func calculateHeaderAttributes() {
        if self.collectionView == nil {
            return
        }
        
        if (headerSize.width == 0 || headerSize.height == 0) {
            return;
        }
    
        headerAttributes = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: ASCollectionViewElement.Header, with: IndexPath(row: 0, section: SECTION))
        if (UIInterfaceOrientationIsPortrait(currentOrientation)) {
            headerAttributes.frame = CGRect(x: 0, y: 0, width: self.collectionView!.frame.size.width, height: self.headerSize.height);
        } else {
            headerAttributes.frame = CGRect(x: 0, y: 0, width: self.headerSize.width, height: self.collectionView!.frame.size.height);
        }
    }
    
    fileprivate func calculateMoreLoaderAttributes() {
        if self.collectionView == nil {
            return
        }
        
        if (self.collectionView as! ASCollectionView).enableLoadMore == false {
            moreLoaderAttributes = nil;
            return;
        }
        
        let numberOfItems = self.collectionView!.numberOfItems(inSection: SECTION)
        moreLoaderAttributes = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: ASCollectionViewElement.MoreLoader, with: IndexPath(row: numberOfItems - 1, section: SECTION))
        if (UIInterfaceOrientationIsPortrait(currentOrientation)) {
            moreLoaderAttributes.frame = CGRect(x: 0, y: contentSize.height - moreLoaderSize.height, width: self.collectionView!.frame.size.width, height: moreLoaderSize.height);
        } else {
            moreLoaderAttributes.frame = CGRect(x: contentSize.width - moreLoaderSize.width, y: 0, width: moreLoaderSize.width, height: self.collectionView!.frame.size.height);
        }
    }
    
    // MARK: Set Defaults Values
    
    fileprivate func setDefaultValues() {
        self.previousBoundsSize = CGSize.zero;
        self.gridCellSize = CGSize(width: 200, height: 100)
        self.parallaxCellSize = CGSize(width: 400, height: 200)
        self.gridCellSpacing = CGSize(width: 10, height: 10)
        self.headerSize = CGSize(width: 200, height: 200)
        self.moreLoaderSize = CGSize(width: 50, height: 50)
        self.gridPadding = 20.0
        self.maxParallaxOffset = 50.0
    }

}
