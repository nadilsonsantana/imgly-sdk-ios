//
//  SeparatorCollectionViewCell.swift
//  imglyKit
//
//  Created by Sascha Schwabbauer on 15/02/16.
//  Copyright © 2016 9elements GmbH. All rights reserved.
//

import UIKit

@objc(IMGLYSeparatorCollectionViewCell) public class SeparatorCollectionViewCell: UICollectionViewCell {

    // MARK: - Properties

    public let separator = UIView()

    // MARK: - Initializers

    public override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    private func commonInit() {
        isAccessibilityElement = false
        contentView.addSubview(separator)

        separator.translatesAutoresizingMaskIntoConstraints = false

        var constraints = [NSLayoutConstraint]()

        constraints.append(NSLayoutConstraint(item: separator, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: 1))
        constraints.append(NSLayoutConstraint(item: separator, attribute: .CenterX, relatedBy: .Equal, toItem: contentView, attribute: .CenterX, multiplier: 1, constant: 0))
        constraints.append(NSLayoutConstraint(item: separator, attribute: .Top, relatedBy: .Equal, toItem: contentView, attribute: .Top, multiplier: 1, constant: 16))
        constraints.append(NSLayoutConstraint(item: separator, attribute: .Bottom, relatedBy: .Equal, toItem: contentView, attribute: .Bottom, multiplier: 1, constant: -16))

        NSLayoutConstraint.activateConstraints(constraints)
    }
}
