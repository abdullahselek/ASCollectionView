//
//  ASCollectionViewParallaxCell.swift
//  ASCollectionView
//
//  Created by Abdullah Selek on 28/02/16.
//  Copyright © 2016 Abdullah Selek. All rights reserved.
//

import UIKit

open class ASCollectionViewParallaxCell: UICollectionViewCell {
    
    /**
      *  Image view is used for parallax effect.
     */
    open var parallaxImageView: UIImageView!
    
    /**
      *  Image is used for parallax effect.
     */
    open var parallaxImage: UIImage!
    
    /**
      *  Current offset of parallax image view.
     */
    open var parallaxImageOffset: CGPoint!
    
    /**
      *  Maximum offset for parallax image view.
     */
    open var maxParallaxOffset: CGFloat!
    
    /**
      *  Current orientation, used to adjust parallax image view corresponding to orientation.
     */
    open var currentOrienration: UIInterfaceOrientation!
    
    /**
      *  ImageView layout constraints
     */
    fileprivate var parallaxImageViewWidthConstraint: NSLayoutConstraint!
    fileprivate var parallaxImageViewHeightConstraint: NSLayoutConstraint!
    fileprivate var parallaxImageViewCenterXConstraint: NSLayoutConstraint!
    fileprivate var parallaxImageViewCenterYConstraint: NSLayoutConstraint!
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setUp()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setUp()
    }
    
    override open func prepareForReuse() {
        parallaxImageView.image = nil
    }
    
    fileprivate func setUp() {
        currentOrienration = UIInterfaceOrientation.portrait
        parallaxImageView = UIImageView();
        parallaxImageView.contentMode = UIViewContentMode.scaleAspectFill;
        parallaxImageView.clipsToBounds = true;
        parallaxImageView.image = self.parallaxImage;
        self.contentView.insertSubview(parallaxImageView, at: 0)
    
        // Add constraints
        parallaxImageView.translatesAutoresizingMaskIntoConstraints = false;
        parallaxImageViewWidthConstraint = NSLayoutConstraint(item: parallaxImageView, attribute: NSLayoutAttribute.width, relatedBy: NSLayoutRelation.equal, toItem: self.contentView, attribute: NSLayoutAttribute.width, multiplier: 1, constant: 0)
        parallaxImageViewHeightConstraint = NSLayoutConstraint(item: parallaxImageView, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: self.contentView, attribute: NSLayoutAttribute.height, multiplier: 1, constant: 0)
        parallaxImageViewCenterXConstraint = NSLayoutConstraint(item: parallaxImageView, attribute: NSLayoutAttribute.centerX, relatedBy: NSLayoutRelation.equal, toItem: self.contentView, attribute: NSLayoutAttribute.centerX, multiplier: 1, constant: 0)
        parallaxImageViewCenterYConstraint = NSLayoutConstraint(item: parallaxImageView, attribute: NSLayoutAttribute.centerY, relatedBy: NSLayoutRelation.equal, toItem: self.contentView, attribute: NSLayoutAttribute.centerY, multiplier: 1, constant: 0)
        
        self.contentView.addConstraint(parallaxImageViewWidthConstraint)
        self.contentView.addConstraint(parallaxImageViewHeightConstraint)
        self.contentView.addConstraint(parallaxImageViewCenterXConstraint)
        self.contentView.addConstraint(parallaxImageViewCenterYConstraint)
    }
    
    open func updateParallaxImage(_ parallaxImage: UIImage) {
        self.parallaxImage = parallaxImage
        parallaxImageView.image = parallaxImage
    }
    
    open func setParallaxImageOffset(_ parallaxImageOffset: CGPoint) {
        parallaxImageViewCenterXConstraint.constant = parallaxImageOffset.x
        parallaxImageViewCenterYConstraint.constant = parallaxImageOffset.y
    }
    
    open func setMaxParallaxOffset(_ maxParallaxOffset: CGFloat) {
        self.maxParallaxOffset = maxParallaxOffset
        if UIInterfaceOrientationIsPortrait(self.currentOrienration) {
            parallaxImageViewWidthConstraint.constant = 0
            parallaxImageViewHeightConstraint.constant = 2 * maxParallaxOffset
        } else {
            parallaxImageViewWidthConstraint.constant = 2 * maxParallaxOffset
            parallaxImageViewHeightConstraint.constant = 0
        }
    }
    
    open func setCurrentOrienration(_ currentOrienration: UIInterfaceOrientation) {
        self.currentOrienration = currentOrienration
        setMaxParallaxOffset(maxParallaxOffset)
    }
    
}
