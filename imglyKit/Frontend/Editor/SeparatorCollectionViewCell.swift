//
//  SeparatorCollectionViewCell.swift
//  imglyKit
//
//  Created by Sascha Schwabbauer on 15/02/16.
//  Copyright © 2016 9elements GmbH. All rights reserved.
//

import UIKit

class SeparatorCollectionViewCell: UICollectionViewCell {

    // MARK: - Properties

    lazy var separator: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    // MARK: - Initializers

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    private func commonInit() {
        isAccessibilityElement = false
        contentView.addSubview(separator)

        var constraints = [NSLayoutConstraint]()

        constraints.append(NSLayoutConstraint(item: separator, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: 1))
        constraints.append(NSLayoutConstraint(item: separator, attribute: .CenterX, relatedBy: .Equal, toItem: contentView, attribute: .CenterX, multiplier: 1, constant: 0))
        constraints.append(NSLayoutConstraint(item: separator, attribute: .Top, relatedBy: .Equal, toItem: contentView, attribute: .Top, multiplier: 1, constant: 4))
        constraints.append(NSLayoutConstraint(item: separator, attribute: .Bottom, relatedBy: .Equal, toItem: contentView, attribute: .Bottom, multiplier: 1, constant: -4))

        NSLayoutConstraint.activateConstraints(constraints)
    }

}
