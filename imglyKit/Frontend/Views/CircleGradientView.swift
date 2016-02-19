//
// Created by Carsten Przyluczky on 01/03/15.
// Copyright (c) 2015 9elements GmbH. All rights reserved.
//

import UIKit

/**
 This class represents the circle gradient view. It is used within the focus editor view controller
 to visualize the choosen focus parameters. Basicaly a circle shaped area is left unblured.
 Two controlpoints define two opposing points on the border of the induced circle. Therefore they determin the rotation,
 position and size of the circle.
 */
@objc(IMGLYCircleGradientView) public class CircleGradientView: UIView {

    /// :nodoc:
    public var centerPoint = CGPoint.zero

    /// The receiver’s delegate.
    /// seealso: `GradientViewDelegate`.
    public weak var gradientViewDelegate: GradientViewDelegate?

    ///  The first control point.
    public var controlPoint1 = CGPoint.zero

    /// The second control point.
    public var controlPoint2 = CGPoint.zero {
        didSet {
            calculateCenterPointFromOtherControlPoints()
            setNeedsDisplay()
            gradientViewDelegate?.gradientViewControlPointChanged(self)
        }
    }

    /// The normalized first control point.
    public var normalizedControlPoint1: CGPoint {
        return CGPoint(x: controlPoint1.x / frame.size.width, y: controlPoint1.y / frame.size.height)
    }

    /// The normalized second control point.
    public var normalizedControlPoint2: CGPoint {
        return CGPoint(x: controlPoint2.x / frame.size.width, y: controlPoint2.y / frame.size.height)
    }

    private var setup = false

    /**
     Initializes and returns a newly allocated view with the specified frame rectangle.

     - parameter frame: The frame rectangle for the view, measured in points.

     - returns: An initialized view object or `nil` if the object couldn't be created.
     */
    public override init(frame: CGRect) {
        super.init(frame:frame)
        commonInit()
    }

    /**
     Returns an object initialized from data in a given unarchiver.

     - parameter aDecoder: An unarchiver object.

     - returns: `self`, initialized using the data in decoder.
     */
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    private func commonInit() {
        if setup {
            return
        }
        setup = true

        backgroundColor = UIColor.clearColor()
        configureControlPoints()
        configurePanGestureRecognizer()
        configurePinchGestureRecognizer()

        isAccessibilityElement = true
        accessibilityTraits |= UIAccessibilityTraitAdjustable
        accessibilityLabel = Localize("Radial focus area")
        accessibilityHint = Localize("Double-tap and hold to move focus area")
    }

    public func configureControlPoints() {
        controlPoint1 = CGPoint(x: 150, y: 100)
        controlPoint2 = CGPoint(x: 150, y: 200)
        calculateCenterPointFromOtherControlPoints()
    }

    public func configurePanGestureRecognizer() {
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: "handlePanGesture:")
        addGestureRecognizer(panGestureRecognizer)
    }

    public func configurePinchGestureRecognizer() {
        let pinchGestureRecognizer = UIPinchGestureRecognizer(target: self, action: "handlePinchGesture:")
        addGestureRecognizer(pinchGestureRecognizer)
    }

    private func diagonalLengthOfFrame() -> CGFloat {
        return sqrt(frame.size.width * frame.size.width +
            frame.size.height * frame.size.height)
    }

    /**
     Draws the receiver’s image within the passed-in rectangle.

     - parameter rect: The portion of the view’s bounds that needs to be updated.
     */
    public override func drawRect(rect: CGRect) {
        let aPath = UIBezierPath(arcCenter: centerPoint, radius: distanceBetweenControlPoints() * 0.5, startAngle: 0, endAngle: CGFloat(M_PI * 2.0), clockwise: true)
        UIColor.whiteColor().setStroke()
        aPath.closePath()

        let aRef = UIGraphicsGetCurrentContext()
        CGContextSaveGState(aRef)
        aPath.lineWidth = 2
        aPath.stroke()
        CGContextRestoreGState(aRef)
    }

    private func distanceBetweenControlPoints() -> CGFloat {
        return CGVector(startPoint: controlPoint1, endPoint: controlPoint2).length
    }

    private func calculateCenterPointFromOtherControlPoints() {
        centerPoint = (controlPoint1 + controlPoint2) * 0.5
    }

    private func informDelegateAboutRecognizerStates(recognizer recognizer: UIGestureRecognizer) {
        if recognizer.state == .Began {
            gradientViewDelegate?.gradientViewUserInteractionStarted(self)
        }

        if recognizer.state == .Ended || recognizer.state == .Cancelled {
            gradientViewDelegate?.gradientViewUserInteractionEnded(self)
        }
    }

    @objc private func handlePanGesture(recognizer: UIPanGestureRecognizer) {
        informDelegateAboutRecognizerStates(recognizer: recognizer)

        let translation = recognizer.translationInView(self)

        controlPoint1 = controlPoint1 + translation
        controlPoint2 = controlPoint2 + translation

        recognizer.setTranslation(CGPoint.zero, inView: self)
    }

    @objc private func handlePinchGesture(recognizer: UIPinchGestureRecognizer) {
        informDelegateAboutRecognizerStates(recognizer: recognizer)

        let vector1 = CGVector(startPoint: centerPoint, endPoint: controlPoint1).normalizedVector()
        let vector2 = CGVector(startPoint: centerPoint, endPoint: controlPoint2).normalizedVector()

        let length = CGVector(startPoint: controlPoint1, endPoint: controlPoint2).length * recognizer.scale / 2

        controlPoint1 = centerPoint + vector1 * length
        controlPoint2 = centerPoint + vector2 * length

        recognizer.scale = 1
    }

    /**
     Lays out subviews.
     */
    public override func layoutSubviews() {
        super.layoutSubviews()

        let distance = distanceBetweenControlPoints()
        accessibilityFrame = convertRect(CGRect(x: centerPoint.x - distance / 2, y: centerPoint.y - distance / 2, width: distance, height: distance), toView: nil)
        UIAccessibilityPostNotification(UIAccessibilityLayoutChangedNotification, nil)
    }

    /**
     Centers the ui-elements within the views frame.
     */
    public func centerGUIElements() {
        let x1 = frame.size.width * 0.25
        let x2 = frame.size.width * 0.75
        let y1 = frame.size.height * 0.25
        let y2 = frame.size.height * 0.75
        controlPoint1 = CGPoint(x: x1, y: y1)
        controlPoint2 = CGPoint(x: x2, y: y2)
    }

    // MARK: - Accessibility

    public override func accessibilityIncrement() {
        let vector1 = CGVector(startPoint: centerPoint, endPoint: controlPoint1).normalizedVector()
        let vector2 = CGVector(startPoint: centerPoint, endPoint: controlPoint2).normalizedVector()

        // Widen gap by 20 points
        controlPoint1 = controlPoint1 + 10 * vector1
        controlPoint2 = controlPoint2 + 10 * vector2
    }

    public override func accessibilityDecrement() {
        let vector1 = CGVector(startPoint: centerPoint, endPoint: controlPoint1).normalizedVector()
        let vector2 = CGVector(startPoint: centerPoint, endPoint: controlPoint2).normalizedVector()

        // Reduce gap by 20 points
        controlPoint1 = controlPoint1 - 10 * vector1
        controlPoint2 = controlPoint2 - 10 * vector2
    }
}
