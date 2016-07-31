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
                    expect(collectionView.numberOfSectionsInCollectionView(collectionView)).to(equal(1))
                }
            }
        }
        describe(".numberOfItemsInSection") {
            context("When datasource is empty") {
                it("Should return zero") {
                    let collectionView = self.createCollectionview()
                    expect(collectionView.numberOfItemsInSection(0)).to(equal(0))
                }
            }
            context("When datasource is not empty") {
                it("Should return item number") {
                    let collectionView = self.createCollectionview()
                    collectionView.asDataSource = MockDataSource()
                    expect(collectionView.numberOfItemsInSection(0)).to(equal(10))
                }
            }
        }
        describe(".cellForItemAtIndexPath") {
            context("When datasource is not empty") {
                it("Should return a valid cell") {
                    let collectionView = self.createCollectionview()
                    collectionView.asDataSource = MockDataSource()
                    expect(collectionView.collectionView(collectionView, cellForItemAtIndexPath:
                        NSIndexPath(forRow: 1, inSection: 0))).to(beAKindOf(ASCollectionViewParallaxCell))
                    
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
                    expect(collectionView.collectionView(collectionView, viewForSupplementaryElementOfKind: "Header",
                        atIndexPath: NSIndexPath(forRow: 1, inSection: 0))).notTo(beNil())
                }
            }
        }
        describe(".orientationChanged") {
            context("When device orientation changed") {
                it("Orientation should be portrait") {
                    let collectionView = self.createCollectionview()
                    let collectionViewLayout: ASCollectionViewLayout = collectionView.collectionViewLayout as! ASCollectionViewLayout
                    collectionView.orientationChanged(NSNotification(name: "", object: nil))
                    expect(collectionViewLayout.currentOrientation).to(equal(UIInterfaceOrientation.Portrait))
                }
            }
        }
    }
    
    func createCollectionview() -> ASCollectionView {
        let collectionViewLayout = ASCollectionViewLayout()
        return ASCollectionView(frame: CGRectMake(0.0, 0.0, 320.0, 480.0),
                                              collectionViewLayout: collectionViewLayout)
    }
    
    class MockDataSource: NSObject, ASCollectionViewDataSource {
        func numberOfItemsInASCollectionView(asCollectionView: ASCollectionView) -> Int {
            return 10
        }
        func collectionView(asCollectionView: ASCollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
            return ASCollectionViewParallaxCell(frame: CGRectMake(5.0, 5.0, 310.0, 50.0))
        }
        func collectionView(asCollectionView: ASCollectionView, parallaxCellForItemAtIndexPath indexPath: NSIndexPath) -> ASCollectionViewParallaxCell {
            return ASCollectionViewParallaxCell(frame: CGRectMake(5.0, 5.0, 310.0, 50.0))
        }
        func moreLoaderInASCollectionView(asCollectionView: ASCollectionView) -> UIView {
            return UIView()
        }
        func collectionView(asCollectionView: ASCollectionView, headerAtIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
            return UICollectionReusableView()
        }
    }
    
}
