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
        collectionView.register(UINib(nibName: collectionElementKindHeader, bundle: nil), forSupplementaryViewOfKind: collectionElementKindHeader, withReuseIdentifier: "header")
        collectionView.delegate = self
        collectionView.asDataSource = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: ASCollectionViewDataSource
    
    func numberOfItemsInASCollectionView(_ asCollectionView: ASCollectionView) -> Int {
        return numberOfItems
    }
    
    func collectionView(_ asCollectionView: ASCollectionView, cellForItemAtIndexPath indexPath: IndexPath) -> UICollectionViewCell {
        let gridCell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! GridCell
        gridCell.label.text = NSString(format: "Item %ld ", (indexPath as NSIndexPath).row) as String
        gridCell.imageView.image = UIImage(named: NSString(format: "image-%ld", (indexPath as NSIndexPath).row % 10) as String)
        return gridCell
    }
    
    func collectionView(_ asCollectionView: ASCollectionView, parallaxCellForItemAtIndexPath indexPath: IndexPath) -> ASCollectionViewParallaxCell {
        let parallaxCell = collectionView.dequeueReusableCell(withReuseIdentifier: "parallaxCell", for: indexPath) as! ParallaxCell
        parallaxCell.label.text = NSString(format: "Item %ld ", (indexPath as NSIndexPath).row) as String
        parallaxCell.updateParallaxImage(UIImage(named: NSString(format: "image-%ld", (indexPath as NSIndexPath).row % 10) as String)!)
        return parallaxCell
    }
    
    func collectionView(_ asCollectionView: ASCollectionView, headerAtIndexPath indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: ASCollectionViewElement.Header, withReuseIdentifier: "header", for: indexPath)
        return header
    }
    
    func loadMoreInASCollectionView(_ asCollectionView: ASCollectionView) {
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

