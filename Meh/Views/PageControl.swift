//
//  PageControl.swift
//  Meh
//
//  Created by Bradley Smith on 3/2/16.
//  Copyright © 2016 Brad Smith. All rights reserved.
//

import UIKit
import pop

class PageControl: UIView {

    // MARK: - Properties

    private static let pageIndicatorSize = CGSize(width: 10.0, height: 10.0)
    private let animationInterval = 0.05
    private lazy var pageIndicatorLayers = [CAShapeLayer]()

    var currentPage = 0 {
        didSet {
            for (index, shapeLayer) in pageIndicatorLayers.enumerate() {
                shapeLayer.fillColor = (index == currentPage) ? currentPageIndicatorTintColor?.CGColor : UIColor.clearColor().CGColor
            }
        }
    }

    var numberOfPages = 0 {
        didSet {
            hidden = (numberOfPages == 1) && hidesForSinglePage

            pageIndicatorLayers.removeAll()
            layer.sublayers?.removeAll()

            var origin = CGPoint(x: 1.0, y: 1.0)
            for _ in 0 ..< numberOfPages {
                let shapeLayer = CAShapeLayer()
                shapeLayer.strokeColor = pageIndicatorTintColor?.CGColor
                shapeLayer.fillColor = UIColor.clearColor().CGColor
                shapeLayer.lineWidth = 1.0

                let frame = CGRect(origin: origin, size: PageControl.pageIndicatorSize)
                shapeLayer.frame = frame

                let path = UIBezierPath(ovalInRect: shapeLayer.bounds)
                shapeLayer.path = path.CGPath

                pageIndicatorLayers.append(shapeLayer)
                layer.addSublayer(shapeLayer)

                origin.x = frame.maxX + PageControl.pageIndicatorSize.width
            }

            invalidateIntrinsicContentSize()
        }
    }

    var hidesForSinglePage = true {
        didSet {
            if hidesForSinglePage {
                hidden = (numberOfPages == 1)
            }
            else {
                hidden = false
            }
        }
    }

    var pageIndicatorTintColor: UIColor? {
        didSet {
            for shapeLayer in pageIndicatorLayers {
                shapeLayer.strokeColor = pageIndicatorTintColor?.CGColor
            }
        }
    }

    var currentPageIndicatorTintColor: UIColor? {
        didSet {
            if currentPage < pageIndicatorLayers.count {
                pageIndicatorLayers[currentPage].fillColor = currentPageIndicatorTintColor?.CGColor
            }
        }
    }

    // MARK: - Lifecycle

    override init(frame: CGRect) {
        super.init(frame: frame)

        backgroundColor = UIColor.clearColor()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func intrinsicContentSize() -> CGSize {
        let count = max(0, (2 * numberOfPages) - 1)

        if count > 0 {
            let width = CGFloat(count) * PageControl.pageIndicatorSize.width + 2.0
            let height = PageControl.pageIndicatorSize.height + 2.0

            return CGSize(width: width, height: height)
        }
        else {
            return CGSize.zero
        }
    }

    // MARK: - Actions

    func showAnimated(animated: Bool) {
        for (index, shapeLayer) in pageIndicatorLayers.enumerate() {
            if animated {
                let animation = POPSpringAnimation(propertyNamed: kPOPLayerScaleXY)
                animation.toValue = NSValue(CGPoint: CGPoint(x: 1.0, y: 1.0))
                animation.springBounciness = 12.0
                animation.beginTime = CACurrentMediaTime() + (animationInterval * Double(index))

                shapeLayer.pop_addAnimation(animation, forKey: "scale")
            }
            else {
                shapeLayer.transform = CATransform3DIdentity
            }
        }
    }

    func hide() {
        for shapeLayer in pageIndicatorLayers {
            shapeLayer.transform = CATransform3DMakeScale(0.1, 0.1, 1.0)
        }
    }

    class func height() -> CGFloat {
        return PageControl.pageIndicatorSize.height + 2.0
    }
}
