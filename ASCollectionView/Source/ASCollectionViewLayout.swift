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

public class ASCollectionViewLayout: UICollectionViewLayout {
    
    let SECTION = 0
    let NUMBEROFITEMSINGROUP = 10
    
    /**
      *  Grid cell size. Default value is (200, 100).
     */
    public var gridCellSize: CGSize!
    
    /**
      *  Parallax cell size. Default value is (400, 200).
     */
    public var parallaxCellSize: CGSize!
    
    /**
      *  Header size. Default value is (200, 200).
      *
      *  Set (0, 0) for no header
     */
    public var headerSize: CGSize!
    
    /**
      *  Size for more loader section. Default value is (50, 50).
     */
    public var moreLoaderSize: CGSize!
    
    /**
      *  Space between grid cells. Default value is (10, 10).
     */
    public var gridCellSpacing: CGSize!
    
    /**
      *  Padding for grid. Default value is 20.
     */
    public var gridPadding: CGFloat! = 20.0
    
    /**
      *  Maximum parallax offset. Default value is 50.
     */
    public var maxParallaxOffset: CGFloat! = 50.0
    
    /**
      *  Current orientation, used to layout correctly corresponding to orientation.
     */
    public var currentOrientation: UIInterfaceOrientation!
    
    /**
      * Internal variables
     */
    private var contentSize: CGSize!
    private var groupSize: CGSize!
    private var internalGridCellSize: CGSize!
    private var internalParallaxCellSize: CGSize!
    private var previousBoundsSize: CGSize!
    private var cellAttributes: NSMutableDictionary!
    private var headerAttributes: UICollectionViewLayoutAttributes!
    private var moreLoaderAttributes: UICollectionViewLayoutAttributes!
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setDefaultValues()
    }
    
    override init() {
        super.init()
        self.setDefaultValues()
    }
    
    override public func prepareLayout() {        
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
    
    override public func collectionViewContentSize() -> CGSize {
        return contentSize
    }
    
    override public func layoutAttributesForElementsInRect(rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var result = [UICollectionViewLayoutAttributes]()
        let numberOfItems = self.collectionView!.numberOfItemsInSection(0)
        
        for itemCount in 0 ..< numberOfItems {
            let indexPath = NSIndexPath(forItem: itemCount, inSection: SECTION)
            let attributes = cellAttributes.objectForKey(indexPath) as! UICollectionViewLayoutAttributes
            
            if CGRectIntersectsRect(rect, attributes.frame) {
                result.append(attributes)
            }
        }
        
        // now add header attributes if it is in rect
        if headerAttributes != nil && CGRectIntersectsRect(rect, headerAttributes.frame) == true {
            result.append(headerAttributes)
        }
        
        // add more loader attributes if it is in rect
        if moreLoaderAttributes != nil && CGRectIntersectsRect(rect, moreLoaderAttributes.frame) == true {
            result.append(moreLoaderAttributes)
        }
        
        return result
    }
    
    override public func layoutAttributesForItemAtIndexPath(indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes? {
        return cellAttributes.objectForKey(indexPath) as? UICollectionViewLayoutAttributes
    }
    
    override public func layoutAttributesForSupplementaryViewOfKind(elementKind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes? {
        return headerAttributes
    }
    
    override public func shouldInvalidateLayoutForBoundsChange(newBounds: CGRect) -> Bool {
        if CGSizeEqualToSize(previousBoundsSize, newBounds.size) {
            previousBoundsSize = newBounds.size
            return true
        }
        return false
    }
    
    // MARK: Calculation methods
    
    private func calculateContentSize() {
        if self.collectionView == nil {
            return
        }
        
        let numberOfItems = self.collectionView!.numberOfItemsInSection(SECTION)
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
    
    private func calculateCellSize() {
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
    
    private func calculateCellAttributes() {
        if self.collectionView == nil {
            return
        }
        
        let numberOfItems = self.collectionView!.numberOfItemsInSection(SECTION)
        
        cellAttributes = NSMutableDictionary(capacity: numberOfItems)
        for itemCount in 0 ..< numberOfItems {
            let indexPath = NSIndexPath(forItem: itemCount, inSection: SECTION)
            let attributes = UICollectionViewLayoutAttributes(forCellWithIndexPath: indexPath)
            cellAttributes.setObject(attributes, forKey: indexPath)
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
            let indexPath = NSIndexPath(forItem: itemCount, inSection: SECTION)
            let attributes = cellAttributes.objectForKey(indexPath) as! UICollectionViewLayoutAttributes
            var frame = CGRectZero
            
            if UIInterfaceOrientationIsPortrait(self.currentOrientation) {
                switch (indexInGroup) {
                case 0:
                    frame = CGRectMake(x, y, internalGridCellSize.width, internalGridCellSize.height)
                    break
                case 1:
                    frame = CGRectMake(x + internalGridCellSize.width + self.gridCellSpacing.width, y, internalGridCellSize.width, internalGridCellSize.height * 2 + self.gridCellSpacing.height)
                    y += frame.size.height + self.gridPadding
                    break
                case 2:
                    frame = CGRectMake(x, y - internalGridCellSize.height - self.gridPadding, internalGridCellSize.width, internalGridCellSize.height)
                    
                    break
                case 3:
                    frame = CGRectMake(0, y, internalParallaxCellSize.width, internalParallaxCellSize.height)
                    y += frame.size.height + self.gridPadding
                    break
                case 4:
                    frame = CGRectMake(x, y, internalGridCellSize.width, internalGridCellSize.height)
                    break
                case 5:
                    frame = CGRectMake(x + internalGridCellSize.width + self.gridCellSpacing.width, y, internalGridCellSize.width, internalGridCellSize.height)
                    y += frame.size.height + self.gridCellSpacing.height
                    break
                case 6:
                    frame = CGRectMake(x, y, internalGridCellSize.width * 2 + self.gridCellSpacing.width, internalGridCellSize.height * 2 + self.gridCellSpacing.height)
                    y += frame.size.height + self.gridCellSpacing.height
                    break
                case 7:
                    frame = CGRectMake(x, y, internalGridCellSize.width, internalGridCellSize.height)
                    break
                case 8:
                    frame = CGRectMake(x + internalGridCellSize.width + self.gridCellSpacing.width, y, internalGridCellSize.width, internalGridCellSize.height)
                    y += frame.size.height + self.gridPadding
                    break
                case 9:
                    frame = CGRectMake(0, y, internalParallaxCellSize.width, internalParallaxCellSize.height)
                    y += frame.size.height + self.gridPadding
                    break
                default:
                    break
                }
            } else {
                switch (indexInGroup) {
                case 0:
                    frame = CGRectMake(x, y, internalGridCellSize.width, internalGridCellSize.height)
                    break
                case 1:
                    frame = CGRectMake(x + internalGridCellSize.width + self.gridCellSpacing.width, y, internalGridCellSize.width, internalGridCellSize.height * 2 + self.gridCellSpacing.height)
                    break
                case 2:
                    frame = CGRectMake(x, y + internalGridCellSize.height + self.gridCellSpacing.height, internalGridCellSize.width, internalGridCellSize.height)
                    x += internalGridCellSize.width * 2 + self.gridCellSpacing.width + self.gridPadding
                    break
                case 3:
                    frame = CGRectMake(x, 0, internalParallaxCellSize.width, internalParallaxCellSize.height)
                    x += frame.size.width + self.gridPadding
                    break
                case 4:
                    frame = CGRectMake(x, y, internalGridCellSize.width, internalGridCellSize.height)
                    break
                case 5:
                    frame = CGRectMake(x + internalGridCellSize.width + self.gridCellSpacing.width, y, internalGridCellSize.width * 2 + self.gridCellSpacing.width, internalGridCellSize.height * 2 + self.gridCellSpacing.height)
                    break
                case 6:
                    frame = CGRectMake(x, y + internalGridCellSize.height + self.gridCellSpacing.height, internalGridCellSize.width, internalGridCellSize.height)
                    x += internalGridCellSize.width * 3 + self.gridCellSpacing.width * 3
                    break
                case 7:
                    frame = CGRectMake(x, y, internalGridCellSize.width, internalGridCellSize.height)
                    break
                case 8:
                    frame = CGRectMake(x, y + internalGridCellSize.height + self.gridCellSpacing.height, internalGridCellSize.width, internalGridCellSize.height)
                    x += frame.size.width + self.gridPadding
                    break
                case 9:
                    frame = CGRectMake(x, 0, internalParallaxCellSize.width, internalParallaxCellSize.height)
                    x += frame.size.width + self.gridPadding
                    break
                default:
                    break
                }
            }
            attributes.frame = frame
        }
    }
    
    private func calculateHeaderAttributes() {
        if self.collectionView == nil {
            return
        }
        
        if (headerSize.width == 0 || headerSize.height == 0) {
            return;
        }
    
        headerAttributes = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: ASCollectionViewElement.Header, withIndexPath: NSIndexPath(forRow: 0, inSection: SECTION))
        if (UIInterfaceOrientationIsPortrait(currentOrientation)) {
            headerAttributes.frame = CGRectMake(0, 0, self.collectionView!.frame.size.width, self.headerSize.height);
        } else {
            headerAttributes.frame = CGRectMake(0, 0, self.headerSize.width, self.collectionView!.frame.size.height);
        }
    }
    
    private func calculateMoreLoaderAttributes() {
        if self.collectionView == nil {
            return
        }
        
        if (self.collectionView as! ASCollectionView).enableLoadMore == false {
            moreLoaderAttributes = nil;
            return;
        }
        
        let numberOfItems = self.collectionView!.numberOfItemsInSection(SECTION)
        moreLoaderAttributes = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: ASCollectionViewElement.MoreLoader, withIndexPath: NSIndexPath(forRow: numberOfItems - 1, inSection: SECTION))
        if (UIInterfaceOrientationIsPortrait(currentOrientation)) {
            moreLoaderAttributes.frame = CGRectMake(0, contentSize.height - moreLoaderSize.height, self.collectionView!.frame.size.width, moreLoaderSize.height);
        } else {
            moreLoaderAttributes.frame = CGRectMake(contentSize.width - moreLoaderSize.width, 0, moreLoaderSize.width, self.collectionView!.frame.size.height);
        }
    }
    
    // MARK: Set Defaults Values
    
    private func setDefaultValues() {
        self.previousBoundsSize = CGSizeZero;
        self.gridCellSize = CGSizeMake(200, 100)
        self.parallaxCellSize = CGSizeMake(400, 200)
        self.gridCellSpacing = CGSizeMake(10, 10)
        self.headerSize = CGSizeMake(200, 200)
        self.moreLoaderSize = CGSizeMake(50, 50)
        self.gridPadding = 20.0
        self.maxParallaxOffset = 50.0
    }

}
