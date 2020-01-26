//
//  ASCollectionViewParallaxCell.swift
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

@objcMembers public class ASCollectionViewParallaxCell: UICollectionViewCell {
    
    /**
      *  Image view is used for parallax effect.
     */
    public var parallaxImageView: UIImageView!
    
    /**
      *  Image is used for parallax effect.
     */
    public var parallaxImage: UIImage!
    
    /**
      *  Current offset of parallax image view.
     */
    public var parallaxImageOffset: CGPoint!
    
    /**
      *  Maximum offset for parallax image view.
     */
    public var maxParallaxOffset: CGFloat!
    
    /**
      *  Current orientation, used to adjust parallax image view corresponding to orientation.
     */
    public var currentOrienration: UIInterfaceOrientation!
    
    /**
      *  ImageView layout constraints
     */
    private var parallaxImageViewWidthConstraint: NSLayoutConstraint!
    private var parallaxImageViewHeightConstraint: NSLayoutConstraint!
    private var parallaxImageViewCenterXConstraint: NSLayoutConstraint!
    private var parallaxImageViewCenterYConstraint: NSLayoutConstraint!
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setUp()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setUp()
    }
    
    override public func prepareForReuse() {
        parallaxImageView.image = nil
    }
    
    private func setUp() {
        currentOrienration = UIInterfaceOrientation.portrait
        parallaxImageView = UIImageView()
        parallaxImageView.contentMode = .scaleAspectFill
        parallaxImageView.clipsToBounds = true
        parallaxImageView.image = self.parallaxImage
        self.contentView.insertSubview(parallaxImageView, at: 0)
    
        // Add constraints
        parallaxImageView.translatesAutoresizingMaskIntoConstraints = false;
        parallaxImageViewWidthConstraint = NSLayoutConstraint(item: parallaxImageView as Any,
                                                              attribute: .width,
                                                              relatedBy: .equal,
                                                              toItem: self.contentView,
                                                              attribute: .width,
                                                              multiplier: 1,
                                                              constant: 0)
        parallaxImageViewHeightConstraint = NSLayoutConstraint(item: parallaxImageView as Any,
                                                               attribute: .height,
                                                               relatedBy: .equal,
                                                               toItem: self.contentView,
                                                               attribute: .height,
                                                               multiplier: 1,
                                                               constant: 0)
        parallaxImageViewCenterXConstraint = NSLayoutConstraint(item: parallaxImageView as Any,
                                                                attribute: .centerX,
                                                                relatedBy: .equal,
                                                                toItem: self.contentView,
                                                                attribute: .centerX,
                                                                multiplier: 1,
                                                                constant: 0)
        parallaxImageViewCenterYConstraint = NSLayoutConstraint(item: parallaxImageView as Any,
                                                                attribute: .centerY,
                                                                relatedBy: .equal,
                                                                toItem: self.contentView,
                                                                attribute: .centerY,
                                                                multiplier: 1,
                                                                constant: 0)
        
        self.contentView.addConstraint(parallaxImageViewWidthConstraint)
        self.contentView.addConstraint(parallaxImageViewHeightConstraint)
        self.contentView.addConstraint(parallaxImageViewCenterXConstraint)
        self.contentView.addConstraint(parallaxImageViewCenterYConstraint)
    }
    
    public func updateParallaxImage(_ parallaxImage: UIImage) {
        self.parallaxImage = parallaxImage
        parallaxImageView.image = parallaxImage
    }
    
    public func setParallaxImageOffset(_ parallaxImageOffset: CGPoint) {
        parallaxImageViewCenterXConstraint.constant = parallaxImageOffset.x
        parallaxImageViewCenterYConstraint.constant = parallaxImageOffset.y
    }
    
    public func setMaxParallaxOffset(_ maxParallaxOffset: CGFloat) {
        self.maxParallaxOffset = maxParallaxOffset
        if self.currentOrienration.isPortrait {
            parallaxImageViewWidthConstraint.constant = 0
            parallaxImageViewHeightConstraint.constant = 2 * maxParallaxOffset
        } else {
            parallaxImageViewWidthConstraint.constant = 2 * maxParallaxOffset
            parallaxImageViewHeightConstraint.constant = 0
        }
    }
    
    public func setCurrentOrienration(_ currentOrienration: UIInterfaceOrientation) {
        self.currentOrienration = currentOrienration
        setMaxParallaxOffset(maxParallaxOffset)
    }
    
}
