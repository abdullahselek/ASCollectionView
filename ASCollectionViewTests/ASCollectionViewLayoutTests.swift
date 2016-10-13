//
//  ASCollectionViewLayoutTests.swift
//  ASCollectionView
//
//  Created by Abdullah Selek on 31/07/16.
//  Copyright © 2016 Abdullah Selek. All rights reserved.
//

import Quick
import Nimble

@testable import ASCollectionView

class ASCollectionViewLayoutTests: QuickSpec {
    
    override func spec() {
        describe("CollectionView Layout") {
            context("When init success") {
                var collectionViewLayout: ASCollectionViewLayout!
                beforeEach {
                    collectionViewLayout = ASCollectionViewLayout()
                }
                
                it("just init") {
                    expect(collectionViewLayout).notTo(beNil())
                }
            }
            context("Check content size is set") {
                var collectionViewLayout: ASCollectionViewLayout!
                beforeEach {
                    collectionViewLayout = MockCollectionViewLayout()
                }
                it("should returns set value") {
                    expect(collectionViewLayout.collectionViewContentSize()).to(equal(CGSizeMake(200, 200)))
                }
            }
            context("Attributes for elements") {
                var collectionViewLayout: ASCollectionViewLayout!
                beforeEach {
                    collectionViewLayout = MockCollectionViewLayout()
                }
                it("should return set elements") {
                    expect(collectionViewLayout.layoutAttributesForElementsInRect(CGRectMake(0.0, 0.0, 320.0, 50.0))).to(haveCount(2))
                }
            }
            context("Attributes for item item index path") {
                var collectionViewLayout: ASCollectionViewLayout!
                beforeEach {
                    collectionViewLayout = MockCollectionViewLayout()
                }
                it("should return a valid attribute") {
                    collectionViewLayout.layoutAttributesForElementsInRect(CGRectMake(0.0, 0.0, 320.0, 50.0))
                    expect(collectionViewLayout.layoutAttributesForItemAtIndexPath(NSIndexPath(forRow: 1, inSection: 0))).notTo(beNil())
                    expect(collectionViewLayout.layoutAttributesForItemAtIndexPath(NSIndexPath(forRow: 1, inSection: 0))).notTo(equal(UICollectionViewLayoutAttributes(forCellWithIndexPath: NSIndexPath(forRow: 0, inSection: 0))))
                }
            }
            context("Attributes for supplementary view") {
                var collectionViewLayout: ASCollectionViewLayout!
                beforeEach {
                    collectionViewLayout = MockCollectionViewLayout()
                }
                it("should return a valid attribute") {
                    expect(collectionViewLayout.layoutAttributesForSupplementaryViewOfKind("Header", atIndexPath: NSIndexPath(forRow: 1, inSection: 0))).notTo(beNil())
                }
            }
            context("Invalidate layout") {
                var collectionViewLayout: ASCollectionViewLayout!
                beforeEach {
                    collectionViewLayout = MockCollectionViewLayout()
                }
                it("should return true") {
                    expect(collectionViewLayout.shouldInvalidateLayoutForBoundsChange(CGRectMake(0.0, 0.0, 320.0, 50.0))).to(equal(true))
                }
            }
        }
    }
    
    class MockCollectionViewLayout: ASCollectionViewLayout {
        let cellAttributes = NSMutableDictionary(capacity: 2)
        var headerAttributes: UICollectionViewLayoutAttributes!
        
        override func collectionViewContentSize() -> CGSize {
            return CGSizeMake(200, 200)
        }
        
        override func layoutAttributesForElementsInRect(_ rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
            var result = [UICollectionViewLayoutAttributes]()
            for itemCount in 0 ..< 2 {
                let indexPath = NSIndexPath(forItem: itemCount, inSection: SECTION)
                let attributes = UICollectionViewLayoutAttributes(forCellWithIndexPath: indexPath)
                cellAttributes.setObject(attributes, forKey: indexPath)
            }
            for itemCount in 0 ..< 2 {
                let indexPath = NSIndexPath(forItem: itemCount, inSection: SECTION)
                let attributes = cellAttributes.objectForKey(indexPath) as! UICollectionViewLayoutAttributes
                
                if CGRectIntersectsRect(rect, attributes.frame) {
                    result.append(attributes)
                }
            }
            
            return result
        }
        
        override func layoutAttributesForItemAtIndexPath(_ indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes? {
            return cellAttributes.objectForKey(indexPath) as? UICollectionViewLayoutAttributes
        }
        
        override func layoutAttributesForSupplementaryViewOfKind(_ elementKind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes? {
            headerAttributes = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: ASCollectionViewElement.Header, withIndexPath: NSIndexPath(forRow: 0, inSection: SECTION))
            headerAttributes.frame = CGRectMake(0, 0, 320, self.headerSize.height);
            return headerAttributes
        }
        
        override func shouldInvalidateLayoutForBoundsChange(_ newBounds: CGRect) -> Bool {
            return true
        }
    }
    
}
