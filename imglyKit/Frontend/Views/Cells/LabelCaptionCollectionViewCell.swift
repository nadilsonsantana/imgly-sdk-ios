//
//  LabelCaptionCollectionViewCell.swift
//  imglyKit
//
//  Created by Sascha Schwabbauer on 18/02/16.
//  Copyright © 2016 9elements GmbH. All rights reserved.
//

import UIKit

@objc(IMGLYLabelCaptionCollectionViewCell) public class LabelCaptionCollectionViewCell: UICollectionViewCell {

    // MARK: - Properties

    public let label = UILabel()
    public let captionLabel = UILabel()
    public let selectionIndicator = UIView()

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
        var constraints = [NSLayoutConstraint]()

        contentView.addSubview(selectionIndicator)
        selectionIndicator.hidden = true
        selectionIndicator.translatesAutoresizingMaskIntoConstraints = false
        selectionIndicator.backgroundColor = UIColor(red: 0.24, green: 0.67, blue: 0.93, alpha: 1)
        constraints.append(NSLayoutConstraint(item: selectionIndicator, attribute: .Left, relatedBy: .Equal, toItem: contentView, attribute: .Left, multiplier: 1, constant: 0))
        constraints.append(NSLayoutConstraint(item: selectionIndicator, attribute: .Right, relatedBy: .Equal, toItem: contentView, attribute: .Right, multiplier: 1, constant: 0))
        constraints.append(NSLayoutConstraint(item: selectionIndicator, attribute: .Bottom, relatedBy: .Equal, toItem: contentView, attribute: .Bottom, multiplier: 1, constant: 0))
        constraints.append(NSLayoutConstraint(item: selectionIndicator, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: 2))

        contentView.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = UIColor.whiteColor()
        label.font = UIFont.systemFontOfSize(28)
        constraints.append(NSLayoutConstraint(item: label, attribute: .CenterX, relatedBy: .Equal, toItem: contentView, attribute: .CenterX, multiplier: 1, constant: 0))

        let spacingView1 = UIView()
        spacingView1.translatesAutoresizingMaskIntoConstraints = false
        spacingView1.hidden = true
        contentView.addSubview(spacingView1)
        constraints.append(NSLayoutConstraint(item: spacingView1, attribute: .Left, relatedBy: .Equal, toItem: contentView, attribute: .Left, multiplier: 1, constant: 0))
        constraints.append(NSLayoutConstraint(item: spacingView1, attribute: .Right, relatedBy: .Equal, toItem: contentView, attribute: .Right, multiplier: 1, constant: 0))
        constraints.append(NSLayoutConstraint(item: spacingView1, attribute: .Top, relatedBy: .Equal, toItem: contentView, attribute: .Top, multiplier: 1, constant: 0))
        constraints.append(NSLayoutConstraint(item: spacingView1, attribute: .Bottom, relatedBy: .Equal, toItem: label, attribute: .Top, multiplier: 1, constant: 0))

        let spacingView2 = UIView()
        spacingView2.translatesAutoresizingMaskIntoConstraints = false
        spacingView2.hidden = true
        contentView.addSubview(spacingView2)
        constraints.append(NSLayoutConstraint(item: spacingView2, attribute: .Left, relatedBy: .Equal, toItem: contentView, attribute: .Left, multiplier: 1, constant: 0))
        constraints.append(NSLayoutConstraint(item: spacingView2, attribute: .Right, relatedBy: .Equal, toItem: contentView, attribute: .Right, multiplier: 1, constant: 0))
        constraints.append(NSLayoutConstraint(item: spacingView2, attribute: .Top, relatedBy: .Equal, toItem: label, attribute: .Bottom, multiplier: 1, constant: 0))
        constraints.append(NSLayoutConstraint(item: spacingView2, attribute: .Bottom, relatedBy: .Equal, toItem: captionLabel, attribute: .Top, multiplier: 1, constant: 0))

        constraints.append(NSLayoutConstraint(item: spacingView1, attribute: .Height, relatedBy: .Equal, toItem: spacingView2, attribute: .Height, multiplier: 1, constant: 0))

        contentView.addSubview(captionLabel)
        captionLabel.translatesAutoresizingMaskIntoConstraints = false
        captionLabel.setContentCompressionResistancePriority(UILayoutPriorityRequired, forAxis: .Vertical)
        captionLabel.textColor = UIColor.whiteColor().colorWithAlphaComponent(0.7)
        captionLabel.font = UIFont.systemFontOfSize(11)
        constraints.append(NSLayoutConstraint(item: captionLabel, attribute: .CenterX, relatedBy: .Equal, toItem: contentView, attribute: .CenterX, multiplier: 1, constant: 0))
        constraints.append(NSLayoutConstraint(item: captionLabel, attribute: .Bottom, relatedBy: .Equal, toItem: contentView, attribute: .Bottom, multiplier: 1, constant: -12))

        NSLayoutConstraint.activateConstraints(constraints)
    }

    // MARK: - UICollectionViewCell

    /*
    :nodoc:
    */
    public override func prepareForReuse() {
        super.prepareForReuse()
        captionLabel.text = nil
        label.text = nil
    }

    /*
    :nodoc:
    */
    public override var selected: Bool {
        didSet {
            selectionIndicator.hidden = !selected
        }
    }

    /*
    :nodoc:
    */
    public override var highlighted: Bool {
        didSet {
            selectionIndicator.hidden = !highlighted
        }
    }
}
