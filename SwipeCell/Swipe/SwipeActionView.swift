//
//  SwipeActionView.swift
//  SwipeCell
//
//  Created by Jon Lu on 1/11/19.
//  Copyright © 2019 Jon Lu. All rights reserved.
//

import Foundation
import UIKit

protocol SwipeActionViewDelegate: class {
    func swipeActionView(_ actionView: SwipeActionView, didSelect action: SwipeAction)
}

class SwipeActionView: UIView {
    
//    var actionButton: SwipeActionButton
//    var buttonWidth: CGFloat
//    var feebackGenerator: SwipeFeedback
    var visibleWidth: CGFloat = 0 {
        didSet {
            setNeedsLayout()
            layoutIfNeeded()
        }
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        let backgroundColor = UIColor.blue
        let context = UIGraphicsGetCurrentContext()
        backgroundColor.setFill()
        context?.fill(rect)
    }
    
    func setExpanded() {
        // TODO
        let expansionAnimator = UIViewPropertyAnimator(duration: 0.6, dampingRatio: 1.0, animations: nil)
        expansionAnimator.addAnimations {
            self.setNeedsLayout()
            self.layoutIfNeeded()
        }
        expansionAnimator.startAnimation(afterDelay: 0)
        
    }
}

class SwipeFeedback {
    enum Style {
        case light
        case medium
        case heavy
    }
    
    @available(iOS 10.0.1, *)
    private var feedbackGenerator: UIImpactFeedbackGenerator? {
        get {
            return _feedbackGenerator as? UIImpactFeedbackGenerator
        }
        set {
            _feedbackGenerator = newValue
        }
    }
    
    private var _feedbackGenerator: Any?
    
    init(style: Style) {
        if #available(iOS 10.0.1, *) {
            switch style {
            case .light:
                feedbackGenerator = UIImpactFeedbackGenerator(style: .light)
            case .medium:
                feedbackGenerator = UIImpactFeedbackGenerator(style: .medium)
            case .heavy:
                feedbackGenerator = UIImpactFeedbackGenerator(style: .heavy)
            }
        }
        else { _feedbackGenerator = nil }
    }
    
    func prepare() {
        if #available(iOS 10.0.1, *) {
            feedbackGenerator?.prepare()
        }
    }
    
    func impactOccurred() {
        if #available(iOS 10.0.1, *) {
            feedbackGenerator?.impactOccurred()
        }
    }
}
