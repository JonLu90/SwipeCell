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

protocol SwipeTransitionLayout {
    func container(view: UIView, didChangeVisibleWidthWithContext context: ActionViewLayoutContext)
    func layout(view: UIView, with context: ActionViewLayoutContext)
    func visibleWidthForView(with context: ActionViewLayoutContext) -> CGFloat
}

struct ActionViewLayoutContext {
    let contentSize: CGSize
    let visibleWidth: CGFloat
    let minimumButtonWidth: CGFloat
    
    init(contentSize: CGSize,
         visibleWidth: CGFloat,
         minimumButtonWidth: CGFloat) {
        self.contentSize = contentSize
        self.visibleWidth = visibleWidth
        self.minimumButtonWidth = minimumButtonWidth
    }
}

class RevealTransitionLayout: SwipeTransitionLayout {
    func container(view: UIView, didChangeVisibleWidthWithContext context: ActionViewLayoutContext) {
        let width = context.minimumButtonWidth
        view.bounds.origin.x = width - context.visibleWidth
    }
    
    func visibleWidthForView(with context: ActionViewLayoutContext) -> CGFloat {
        
    }
    
    func layout(view: UIView, with context: ActionViewLayoutContext) {
        let diff = context.visibleWidth - context.contentSize.width
        view.frame.origin.x = (CGFloat(0) * context.contentSize.width / CGFloat(1) + diff) * 1
    }
}

class SwipeActionView: UIView {
    
    var actionButton: SwipeActionButton
    var minimumButtonWidth: CGFloat = 0
//    var feebackGenerator: SwipeFeedback
//    consider safeAreaMargin
    public var isExpanded: Bool = false  // set true if cell is dragged past center
    var delegate: SwipeActionViewDelegate?
    var buttonWidth: CGFloat = 120
    let transitionLayout: SwipeTransitionLayout
    var layoutContext: ActionViewLayoutContext
    var expansionDelegate: SwipeExpanding?
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
    // for actionButton spring animation if swiped past half of the cell
    func expandIfNeeded(feedback enabled: Bool = true) {}
}

class SwipeActionButtonWrapperView: UIView {
    let contentRect: CGRect
    var backgroundColor: UIColor?
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
