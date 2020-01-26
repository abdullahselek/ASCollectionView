//
//  ASCollectionViewLayout.swift
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

@objcMembers public class ASCollectionViewElement: NSObject {
    public static let Header = "Header"
    public static let MoreLoader = "MoreLoader"
}

@objcMembers public class ASCollectionViewLayout: UICollectionViewLayout {
    
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
    internal var contentSize: CGSize!
    internal var groupSize: CGSize!
    internal var internalGridCellSize: CGSize!
    internal var internalParallaxCellSize: CGSize!
    internal var previousBoundsSize: CGSize!
    internal var cellAttributes: NSMutableDictionary!
    internal var headerAttributes: UICollectionViewLayoutAttributes!
    internal var moreLoaderAttributes: UICollectionViewLayoutAttributes!
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setDefaultValues()
    }
    
    override init() {
        super.init()
        self.setDefaultValues()
    }
    
    override public func prepare() {
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
    
    override public var collectionViewContentSize : CGSize {
        return contentSize
    }
    
    override public func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var result = [UICollectionViewLayoutAttributes]()
        guard let collectionView = self.collectionView as? ASCollectionView else {
            return result
        }
        let numberOfItems = collectionView.numberOfItems(inSection: 0)
        
        for itemCount in 0 ..< numberOfItems {
            let indexPath = IndexPath(item: itemCount, section: SECTION)
            guard let attributes = cellAttributes.object(forKey: indexPath) as? UICollectionViewLayoutAttributes else {
                return result
            }
            
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
    
    override public func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return cellAttributes.object(forKey: indexPath) as? UICollectionViewLayoutAttributes
    }
    
    override public func layoutAttributesForSupplementaryView(ofKind elementKind: String, at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return headerAttributes
    }
    
    override public func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        if previousBoundsSize.equalTo(newBounds.size) {
            previousBoundsSize = newBounds.size
            return true
        }
        return false
    }
    
    // MARK: Calculation methods
    
    internal func calculateContentSize() {
        guard let collectionView = self.collectionView as? ASCollectionView else {
            return
        }
        
        let numberOfItems = collectionView.numberOfItems(inSection: SECTION)
        groupSize = CGSize()
        contentSize = CGSize()
        if currentOrientation.isPortrait {
            groupSize.width = collectionView.bounds.size.width
            let calculatedHeight = gridCellSpacing.height * 4 + internalParallaxCellSize.height * 2 + gridPadding * 4
            groupSize.height = internalGridCellSize.height * 6 + calculatedHeight
            
            contentSize.width = collectionView.bounds.size.width
            contentSize.height = groupSize.height * CGFloat(numberOfItems / 10)
        } else {
            let calculatedWidth = self.gridCellSpacing.width * 4 + internalParallaxCellSize.width * 2 + self.gridPadding * 4
            groupSize.width = internalGridCellSize.width * 6 + calculatedWidth
            groupSize.height = collectionView.bounds.size.height
            contentSize.width = groupSize.width * CGFloat(numberOfItems / 10)
            contentSize.height = self.collectionView!.bounds.size.height
        }
        
        let numberOfItemsInLastGroup = numberOfItems % 10
        let enableLoadMore = collectionView.enableLoadMore
        
        if self.currentOrientation.isPortrait {
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
        guard let collectionView = self.collectionView as? ASCollectionView else {
            return
        }
        
        if self.currentOrientation.isPortrait {
            internalGridCellSize.width = (collectionView.frame.size.width - self.gridCellSpacing.width - self.gridPadding * 2) / 2
            internalParallaxCellSize.width = collectionView.frame.size.width
        } else {
            internalGridCellSize.height = (collectionView.frame.size.height - self.gridCellSpacing.height - self.gridPadding * 2) / 2
            internalParallaxCellSize.height = collectionView.frame.size.height
        }
    }
    
    private func calculateCellAttributes() {
        guard let collectionView = self.collectionView as? ASCollectionView else {
            return
        }
        
        let numberOfItems = collectionView.numberOfItems(inSection: SECTION)
        
        cellAttributes = NSMutableDictionary(capacity: numberOfItems)
        for itemCount in 0 ..< numberOfItems {
            let indexPath = IndexPath(item: itemCount, section: SECTION)
            let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
            cellAttributes.setObject(attributes, forKey: indexPath as NSCopying)
        }
        
        var x: CGFloat = self.gridPadding
        var y: CGFloat = self.gridPadding
        
        // space for header
        if self.currentOrientation.isPortrait {
            y += headerSize.height
        } else {
            x += headerSize.width
        }
        
        for itemCount in 0 ..< numberOfItems {
            let indexInGroup = itemCount % NUMBEROFITEMSINGROUP
            let indexPath = IndexPath(item: itemCount, section: SECTION)
            guard let attributes = cellAttributes.object(forKey: indexPath) as? UICollectionViewLayoutAttributes else {
                return
            }
            var frame = CGRect.zero
            
            if self.currentOrientation.isPortrait {
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
    
    private func calculateHeaderAttributes() {
        guard let collectionView = self.collectionView as? ASCollectionView else {
            return
        }
        
        if headerSize.width == 0 || headerSize.height == 0 {
            return;
        }
    
        headerAttributes = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: ASCollectionViewElement.Header,
                                                            with: IndexPath(row: 0, section: SECTION))
        if currentOrientation.isPortrait {
            headerAttributes.frame = CGRect(x: 0,
                                            y: 0,
                                            width: collectionView.frame.size.width,
                                            height: self.headerSize.height);
        } else {
            headerAttributes.frame = CGRect(x: 0,
                                            y: 0,
                                            width: self.headerSize.width,
                                            height: collectionView.frame.size.height);
        }
    }
    
    private func calculateMoreLoaderAttributes() {
        guard let collectionView = self.collectionView as? ASCollectionView else {
            return
        }

        if !collectionView.enableLoadMore {
            moreLoaderAttributes = nil
            return
        }
        
        let numberOfItems = collectionView.numberOfItems(inSection: SECTION)
        moreLoaderAttributes = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: ASCollectionViewElement.MoreLoader,
                                                                with: IndexPath(row: numberOfItems - 1, section: SECTION))
        if currentOrientation.isPortrait {
            moreLoaderAttributes.frame = CGRect(x: 0,
                                                y: contentSize.height - moreLoaderSize.height,
                                                width: self.collectionView!.frame.size.width,
                                                height: moreLoaderSize.height);
        } else {
            moreLoaderAttributes.frame = CGRect(x: contentSize.width - moreLoaderSize.width,
                                                y: 0,
                                                width: moreLoaderSize.width,
                                                height: self.collectionView!.frame.size.height);
        }
    }
    
    // MARK: Set Defaults Values
    
    private func setDefaultValues() {
        self.previousBoundsSize = .zero
        self.gridCellSize = CGSize(width: 200, height: 100)
        self.parallaxCellSize = CGSize(width: 400, height: 200)
        self.gridCellSpacing = CGSize(width: 10, height: 10)
        self.headerSize = CGSize(width: 200, height: 200)
        self.moreLoaderSize = CGSize(width: 50, height: 50)
        self.gridPadding = 20.0
        self.maxParallaxOffset = 50.0
    }

}
