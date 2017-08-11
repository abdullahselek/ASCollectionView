//
//  ASCollectionViewParallaxCellTests.swift
//  ASCollectionView
//
//  Created by Abdullah Selek on 31/07/16.
//  Copyright © 2016 Abdullah Selek. All rights reserved.
//

import Quick
import Nimble

@testable import ASCollectionView

class ASCollectionViewParallaxCellTests: QuickSpec {
    
    override func spec() {
        describe("ASCollectionViewParallaxCell Tests") {
            context("init(frame:)") {
                var parallaxCell: ASCollectionViewParallaxCell!

                beforeEach {
                    parallaxCell = ASCollectionViewParallaxCell(frame: CGRect(x: 0.0,
                                                                              y: 0.0,
                                                                              width: 320.0,
                                                                              height: 40.0))
                }

                it("should return a cell") {
                    expect(parallaxCell).notTo(beNil())
                }
            }
        }
    }
    
}
