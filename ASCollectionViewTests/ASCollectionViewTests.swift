//
//  ASCollectionViewTests.swift
//  ASCollectionViewTests
//
//  Created by Abdullah Selek on 27/02/16.
//  Copyright © 2016 Abdullah Selek. All rights reserved.
//

import Quick
import Nimble

@testable import ASCollectionView

class ASCollectionViewTests: QuickSpec {
    
    override func spec() {
        describe(".init with frame and collectionViewLayout") {
            context("Init success") {
                it("With valid frame and collectionview layout") {
                    let collectionView = self.createCollectionview()
                    expect(collectionView).notTo(beNil())
                }
            }
        }
        describe(".setEnableLoadMore") {
            context("Load more") {
                it("With true parameter") {
                    let collectionView = self.createCollectionview()
                    collectionView.setEnableLoadMore(true)
                    expect(collectionView.enableLoadMore).to(equal(true))
                }
            }
            context("Load more") {
                it("With false parameter") {
                    let collectionView = self.createCollectionview()
                    collectionView.setEnableLoadMore(false)
                    expect(collectionView.enableLoadMore).to(equal(false))
                }
            }
        }
        describe(".numberOfSectionsInCollectionView") {
            context("Total section number") {
                it("Should return one") {
                    let collectionView = self.createCollectionview()
                    expect(collectionView.numberOfSections(in: collectionView)).to(equal(1))
                }
            }
        }
        describe(".numberOfItemsInSection") {
            context("When datasource is empty") {
                it("Should return zero") {
                    let collectionView = self.createCollectionview()
                    expect(collectionView.numberOfItems(inSection: 0)).to(equal(0))
                }
            }
            context("When datasource is not empty") {
                it("Should return item number") {
                    let collectionView = self.createCollectionview()
                    collectionView.asDataSource = MockDataSource()
                    expect(collectionView.numberOfItems(inSection: 0)).to(equal(10))
                }
            }
        }
        describe(".cellForItemAtIndexPath") {
            context("When datasource is not empty") {
                it("Should return a valid cell") {
                    let collectionView = self.createCollectionview()
                    collectionView.asDataSource = MockDataSource()
                    expect(collectionView.collectionView(collectionView,
                        cellForItemAt: IndexPath(row: 1, section: 0))).to(beAKindOf(ASCollectionViewParallaxCell.self))
                }
            }
        }
        describe(".moreLoaderInASCollectionView") {
            context("When datasource is not empty") {
                it("Should return a valid view") {
                    let collectionView = self.createCollectionview()
                    collectionView.asDataSource = MockDataSource()
                    expect(collectionView.asDataSource!.moreLoaderInASCollectionView!(collectionView)).notTo(beNil())
                }
            }
        }
        describe(".viewForSupplementaryElementOfKind") {
            context("When datasource is not empty") {
                it("Should return a valid header view") {
                    let collectionView = self.createCollectionview()
                    collectionView.asDataSource = MockDataSource()
                    expect(collectionView.collectionView(collectionView, viewForSupplementaryElementOfKind: "Header", at: IndexPath(row: 1, section: 0))).notTo(beNil())
                }
            }
        }
        describe(".orientationChanged") {
            context("When device orientation changed") {
                it("Orientation should be changed") {
                    let collectionView = self.createCollectionview()
                    let collectionViewLayout: ASCollectionViewLayout = collectionView.collectionViewLayout as! ASCollectionViewLayout
                    let orientation = collectionViewLayout.currentOrientation
                    collectionView.orientationChanged(NSNotification(name: NSNotification.Name(rawValue: ""), object: nil) as Notification)
                    expect(collectionViewLayout.currentOrientation).notTo(equal(orientation))
                }
            }
        }
    }
    
    func createCollectionview() -> ASCollectionView {
        let collectionViewLayout = ASCollectionViewLayout()
        return ASCollectionView(frame: CGRect(x: 0, y: 0, width: 320, height: 480),
                                              collectionViewLayout: collectionViewLayout)
    }
    
    class MockDataSource: NSObject, ASCollectionViewDataSource {
        func numberOfItemsInASCollectionView(_ asCollectionView: ASCollectionView) -> Int {
            return 10
        }
        func collectionView(_ asCollectionView: ASCollectionView, cellForItemAtIndexPath indexPath: IndexPath) -> UICollectionViewCell {
            return ASCollectionViewParallaxCell(frame: CGRect(x: 0, y: 0, width: 310, height: 50))
        }
        func collectionView(_ asCollectionView: ASCollectionView, parallaxCellForItemAtIndexPath indexPath: IndexPath) -> ASCollectionViewParallaxCell {
            return ASCollectionViewParallaxCell(frame: CGRect(x: 0, y: 0, width: 310, height: 50))
        }
        func moreLoaderInASCollectionView(_ asCollectionView: ASCollectionView) -> UIView {
            return UIView()
        }
        func collectionView(_ asCollectionView: ASCollectionView, headerAtIndexPath indexPath: IndexPath) -> UICollectionReusableView {
            return UICollectionReusableView()
        }
    }
    
}
