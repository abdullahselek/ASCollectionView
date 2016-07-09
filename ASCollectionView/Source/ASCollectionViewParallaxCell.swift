//
//  ASCollectionViewParallaxCell.swift
//  ASCollectionView
//
//  Created by Abdullah Selek on 28/02/16.
//  Copyright © 2016 Abdullah Selek. All rights reserved.
//

import UIKit

public class ASCollectionViewParallaxCell: UICollectionViewCell {
    
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
        currentOrienration = UIInterfaceOrientation.Portrait
        parallaxImageView = UIImageView();
        parallaxImageView.contentMode = UIViewContentMode.ScaleAspectFill;
        parallaxImageView.clipsToBounds = true;
        parallaxImageView.image = self.parallaxImage;
        self.contentView.insertSubview(parallaxImageView, atIndex: 0)
    
        // Add constraints
        parallaxImageView.translatesAutoresizingMaskIntoConstraints = false;
        parallaxImageViewWidthConstraint = NSLayoutConstraint(item: parallaxImageView, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: self.contentView, attribute: NSLayoutAttribute.Width, multiplier: 1, constant: 0)
        parallaxImageViewHeightConstraint = NSLayoutConstraint(item: parallaxImageView, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: self.contentView, attribute: NSLayoutAttribute.Height, multiplier: 1, constant: 0)
        parallaxImageViewCenterXConstraint = NSLayoutConstraint(item: parallaxImageView, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: self.contentView, attribute: NSLayoutAttribute.CenterX, multiplier: 1, constant: 0)
        parallaxImageViewCenterYConstraint = NSLayoutConstraint(item: parallaxImageView, attribute: NSLayoutAttribute.CenterY, relatedBy: NSLayoutRelation.Equal, toItem: self.contentView, attribute: NSLayoutAttribute.CenterY, multiplier: 1, constant: 0)
        
        self.contentView.addConstraint(parallaxImageViewWidthConstraint)
        self.contentView.addConstraint(parallaxImageViewHeightConstraint)
        self.contentView.addConstraint(parallaxImageViewCenterXConstraint)
        self.contentView.addConstraint(parallaxImageViewCenterYConstraint)
    }
    
    public func updateParallaxImage(parallaxImage: UIImage) {
        self.parallaxImage = parallaxImage
        parallaxImageView.image = parallaxImage
    }
    
    public func setParallaxImageOffset(parallaxImageOffset: CGPoint) {
        parallaxImageViewCenterXConstraint.constant = parallaxImageOffset.x
        parallaxImageViewCenterYConstraint.constant = parallaxImageOffset.y
    }
    
    public func setMaxParallaxOffset(maxParallaxOffset: CGFloat) {
        self.maxParallaxOffset = maxParallaxOffset
        if UIInterfaceOrientationIsPortrait(self.currentOrienration) {
            parallaxImageViewWidthConstraint.constant = 0
            parallaxImageViewHeightConstraint.constant = 2 * maxParallaxOffset
        } else {
            parallaxImageViewWidthConstraint.constant = 2 * maxParallaxOffset
            parallaxImageViewHeightConstraint.constant = 0
        }
    }
    
    public func setCurrentOrienration(currentOrienration: UIInterfaceOrientation) {
        self.currentOrienration = currentOrienration
        setMaxParallaxOffset(maxParallaxOffset)
    }
    
}
