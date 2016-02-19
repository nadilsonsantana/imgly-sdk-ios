//
// Created by Carsten Przyluczky on 01/03/15.
// Copyright (c) 2015 9elements GmbH. All rights reserved.
//

import UIKit

@objc(IMGLYGradientViewDelegate) public protocol GradientViewDelegate {
    func gradientViewUserInteractionStarted(gradientView: UIView)
    func gradientViewUserInteractionEnded(gradientView: UIView)
    func gradientViewControlPointChanged(gradientView: UIView)
}
