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
        describe("CollectionView Parallax Cell") {
            context("Check init") {
                it("if sucess") {
                    let parallaxCell = ASCollectionViewParallaxCell()
                    expect(parallaxCell).notTo(beNil())
                }
            }
        }
    }
    
}
