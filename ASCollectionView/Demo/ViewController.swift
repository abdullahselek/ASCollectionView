//
//  ViewController.swift
//  ASCollectionView
//
//  Created by Abdullah Selek on 27/02/16.
//  Copyright © 2016 Abdullah Selek. All rights reserved.
//

import UIKit

class ViewController: UIViewController, ASCollectionViewDataSource, ASCollectionViewDelegate {

    @IBOutlet var collectionView: ASCollectionView!
    var numberOfItems: Int = 10
    
    let collectionElementKindHeader = "Header";
    let collectionElementKindMoreLoader = "MoreLoader";
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.registerNib(UINib(nibName: collectionElementKindHeader, bundle: nil), forSupplementaryViewOfKind: collectionElementKindHeader, withReuseIdentifier: "header")
        collectionView.delegate = self
        collectionView.asDataSource = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: ASCollectionViewDataSource
    
    func numberOfItemsInASCollectionView(asCollectionView: ASCollectionView) -> Int {
        return numberOfItems
    }
    
    func collectionView(asCollectionView: ASCollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let gridCell = collectionView.dequeueReusableCellWithReuseIdentifier("cell", forIndexPath: indexPath) as! GridCell
        gridCell.label.text = NSString(format: "Item %ld ", indexPath.row) as String
        gridCell.imageView.image = UIImage(named: NSString(format: "image-%ld", indexPath.row % 10) as String)
        return gridCell
    }
    
    func collectionView(asCollectionView: ASCollectionView, parallaxCellForItemAtIndexPath indexPath: NSIndexPath) -> ASCollectionViewParallaxCell {
        let parallaxCell = collectionView.dequeueReusableCellWithReuseIdentifier("parallaxCell", forIndexPath: indexPath) as! ParallaxCell
        parallaxCell.label.text = NSString(format: "Item %ld ", indexPath.row) as String
        parallaxCell.updateParallaxImage(UIImage(named: NSString(format: "image-%ld", indexPath.row % 10) as String)!)
        return parallaxCell
    }
    
    func collectionView(asCollectionView: ASCollectionView, headerAtIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryViewOfKind(ASCollectionViewElement.Header, withReuseIdentifier: "header", forIndexPath: indexPath)
        return header
    }
    
    func loadMoreInASCollectionView(asCollectionView: ASCollectionView) {
        if numberOfItems > 30 {
            collectionView.enableLoadMore = false
            return
        }
        numberOfItems += 10
        collectionView.loadingMore = false
        collectionView.reloadData()
    }

}

class GridCell: UICollectionViewCell {
    
    @IBOutlet var label: UILabel!
    @IBOutlet var imageView: UIImageView!
    
}

class ParallaxCell: ASCollectionViewParallaxCell {
    
    @IBOutlet var label: UILabel!
    
}

