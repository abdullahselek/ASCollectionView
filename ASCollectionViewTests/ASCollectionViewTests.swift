//
//  ASCollectionViewTests.swift
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

import Quick
import Nimble

@testable import ASCollectionView

class ASCollectionViewTests: QuickSpec {
    
    override func spec() {
        describe("ASCollectionView Tests") {
            var collectionView: ASCollectionView!

            beforeEach {
                let collectionViewLayout = ASCollectionViewLayout()
                collectionView = ASCollectionView(frame: CGRect(x: 0, y: 0, width: 320, height: 480),
                                                  collectionViewLayout: collectionViewLayout)
            }

            context(".init(frame:collectionViewLayout:)") {
                it("should creata a collection view") {
                    expect(collectionView).notTo(beNil())
                }
            }

            describe(".setEnableLoadMore(_:)") {
                context("when set with a true value") {
                    beforeEach {
                        collectionView.setEnableLoadMore(true)
                    }

                    it("should return true when its called") {
                        expect(collectionView.enableLoadMore).to(equal(true))
                    }
                }

                context("when set with a false value") {
                    beforeEach {
                        collectionView.setEnableLoadMore(false)
                    }

                    it("should return false when its called") {
                        expect(collectionView.enableLoadMore).to(equal(false))
                    }
                }
            }

            context(".numberOfSections(in:)") {
                it("should return one") {
                    expect(collectionView.numberOfSections(in: collectionView)).to(equal(1))
                }
            }

            describe(".collectionView(_:numberOfItemsInSection:)") {
                context("when datasource is empty") {
                    it("should return zero") {
                        expect(collectionView.numberOfItems(inSection: 0)).to(equal(0))
                    }
                }

                context("when datasource is not empty") {
                    beforeEach {
                        collectionView.asDataSource = MockDataSource()
                    }

                    it("should return item number") {
                        expect(collectionView.numberOfItems(inSection: 0)).to(equal(10))
                    }
                }
            }

            describe(".collectionView(_:cellForItemAt:)") {
                context("when datasource is not empty") {
                    beforeEach {
                        collectionView.asDataSource = MockDataSource()
                    }

                    it("should return a valid cell") {
                        expect(collectionView.collectionView(collectionView,
                                                             cellForItemAt: IndexPath(row: 1, section: 0))).to(beAKindOf(ASCollectionViewParallaxCell.self))
                    }
                }
            }

            describe(".moreLoaderInASCollectionView(_:)") {
                context("when datasource is not empty") {
                    beforeEach {
                        collectionView.asDataSource = MockDataSource()
                    }

                    it("should return a view") {
                        expect(collectionView.asDataSource!.moreLoaderInASCollectionView!(collectionView)).notTo(beNil())
                    }
                }
            }

            describe(".collectionView(_:viewForSupplementaryElementOfKind:at:)") {
                context("when datasource is not empty") {
                    beforeEach {
                        collectionView.asDataSource = MockDataSource()
                    }

                    it("should return a header view") {
                        expect(collectionView.collectionView(collectionView, viewForSupplementaryElementOfKind: "Header", at: IndexPath(row: 1, section: 0))).notTo(beNil())
                    }
                }
            }

            describe(".orientationChanged(_:)") {
                context("when device orientation changed") {
                    var collectionViewLayout: ASCollectionViewLayout!
                    var orientation: UIInterfaceOrientation!

                    beforeEach {
                        collectionViewLayout = collectionView.collectionViewLayout as! ASCollectionViewLayout
                        orientation = collectionViewLayout.currentOrientation
                        let value = UIInterfaceOrientation.landscapeLeft.rawValue
                        UIDevice.current.setValue(value, forKey: "orientation")
                        collectionView.orientationChanged(NSNotification(name: NSNotification.Name(rawValue: ""), object: nil) as Notification)
                    }
                    
                    it("orientation should be changed") {
                        expect(collectionViewLayout.currentOrientation.isPortrait).notTo(equal(orientation?.isPortrait))
                    }
                }
            }
        }
    }
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
