[![Build Status](https://travis-ci.org/abdullahselek/ASCollectionView.svg?branch=master)](https://travis-ci.org/abdullahselek/ASCollectionView)
[![CocoaPods Compatible](https://img.shields.io/cocoapods/v/ASCollectionView.svg)](http://cocoapods.org/pods/ASCollectionView)
[![Carthage Compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![Coverage Status](https://coveralls.io/repos/github/abdullahselek/ASCollectionView/badge.svg?branch=master)](https://coveralls.io/github/abdullahselek/ASCollectionView?branch=master)
![Platform](https://img.shields.io/cocoapods/p/ASCollectionView.svg?style=flat)
![License](https://img.shields.io/dub/l/vibe-d.svg)

# ASCollectionView
Lightweight custom collection view inspired by Airbnb.

## Screenshots

![portrait](https://github.com/abdullahselek/ASCollectionView/blob/master/screenshots/ascollectionview_1.png)
![portrait_2](https://github.com/abdullahselek/ASCollectionView/blob/master/screenshots/ascollectionview_2.png)
![landscape](https://github.com/abdullahselek/ASCollectionView/blob/master/screenshots/ascollectionview_3.png)

## Requirements

| ASCollectionView Version | Minimum iOS Target  | Swift Version |
|:--------------------:|:---------------------------:|:---------------------------:|
| 1.3.0 | 10.0 | 5.x |
| 1.1.0 | 9.0 | 4.2 |
| 1.0.9 | 9.0 | 4.1 |
| 1.0.8 | 9.0 | 4.0 |
| 1.0.7 | 9.0 | 3.x |
| 1.0.2 | 8.0 | 2.x |

## CocoaPods

CocoaPods is a dependency manager for Cocoa projects. You can install it with the following command:
```	
$ gem install cocoapods
```

To integrate ASCollectionView into your Xcode project using CocoaPods, specify it in your Podfile:
```
source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '10.0'
use_frameworks!

target '<Your Target Name>' do
    pod 'ASCollectionView', '1.3.0'
end
```
Then, run the following command:
```
$ pod install
```

## Carthage

Carthage is a decentralized dependency manager that builds your dependencies and provides you with binary frameworks.

You can install Carthage with Homebrew using the following command:

```
brew update
brew install carthage
```

To integrate ASCollectionView into your Xcode project using Carthage, specify it in your Cartfile:

```
github "abdullahselek/ASCollectionView" ~> 1.3.0
```

Run carthage update to build the framework and drag the built ASCollectionView.framework into your Xcode project.

## Swift Package Manager

Modify your Package.swift file to include the following dependency:

```
.package(url: "https://github.com/abdullahselek/ASCollectionView.git", from: "1.3.0")
```

Run `swift package resolve`

## Example Usage

There is a sample viewcontroller inside demo folder and I added some sample code below.

You can add collectionview to your storyboard, xib file or add programmatically and then set constraints. Turn back to your
viewcontroller and implement custom datasource and delegate methods.
```
class ViewController: UIViewController, ASCollectionViewDataSource, ASCollectionViewDelegate {
...

override func viewDidLoad() {
    super.viewDidLoad()
    collectionView.registerNib(UINib(nibName: collectionElementKindHeader, bundle: nil), forSupplementaryViewOfKind: collectionElementKindHeader, withReuseIdentifier: "header")
    collectionView.delegate = self
    collectionView.asDataSource = self
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
```
GridCell collectionview cell used in sample
```
class GridCell: UICollectionViewCell {

    @IBOutlet var label: UILabel!
    @IBOutlet var imageView: UIImageView!

}
```
ParallaxCell used in sample
```
class ParallaxCell: ASCollectionViewParallaxCell {

	@IBOutlet var label: UILabel!

}
```
## The MIT License (MIT)
```
Copyright (c) 2016 Abdullah Selek

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```
## Credits
```
Inspired by Airbnb and ninjaprox. Improved and all coded in new programming 
language Swift.
```
