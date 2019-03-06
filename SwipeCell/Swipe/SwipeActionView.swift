//
//  SwipeActionView.swift
//  SwipeCell
//
//  Created by Jon Lu on 1/11/19.
//  Copyright © 2019 Jon Lu. All rights reserved.
//

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
    
    init(contentSize: CGSize = .zero,
         visibleWidth: CGFloat = 0,
         minimumButtonWidth: CGFloat = 0) {
        self.contentSize = contentSize
        self.visibleWidth = visibleWidth
        self.minimumButtonWidth = minimumButtonWidth
    }
    
    static func newContext(for actionView: SwipeActionView) -> ActionViewLayoutContext {
        return ActionViewLayoutContext(contentSize: actionView.contentSize,
                                       visibleWidth: actionView.visibleWidth,
                                       minimumButtonWidth: actionView.minimumButtonWidth)
    }
}
// TODO
//class RevealTransitionLayout: SwipeTransitionLayout {
//    func container(view: UIView, didChangeVisibleWidthWithContext context: ActionViewLayoutContext) {
//        let width = context.minimumButtonWidth
//        view.bounds.origin.x = width - context.visibleWidth
//    }
//
//    // TODO
//    // func visibleWidthForView(with context: ActionViewLayoutContext) -> CGFloat {}
//
//    func layout(view: UIView, with context: ActionViewLayoutContext) {
//        let diff = context.visibleWidth - context.contentSize.width
//        view.frame.origin.x = (CGFloat(0) * context.contentSize.width / CGFloat(1) + diff) * 1
//    }
//}

class SwipeActionView: UIView {
    //var actionButton: SwipeActionButton
    var minimumButtonWidth: CGFloat = 0
    let action: SwipeAction
    //    TODO: SwipeAnimator
    //    var expansionAnimator: SwipeAnimator?
    //    TODO: feebackGenerator: SwipeFeedback
    //    TODO: consider safeAreaMargin
    public var isExpanded: Bool = false  // set true if cell is dragged past center
    var delegate: SwipeActionViewDelegate?
    var buttonWidth: CGFloat = 120
    // let transitionLayout: SwipeTransitionLayout
    // var layoutContext: ActionViewLayoutContext
    var expansionDelegate: SwipeExpanding?
    var visibleWidth: CGFloat = 0 {
        didSet {
            visibleWidth = max(0, visibleWidth)
    //        let preLayoutVisibleWidth = transitionLayout.visibleWidthForView(with: layoutContext)
    //        layoutContext = ActionViewLayoutContext.newContext(for: self)
    //        transitionLayout.container(view: self, didChangeVisibleWidthWithContext: layoutContext)
            
            setNeedsLayout()
            layoutIfNeeded()
            
    //        notifyVisibleWidthChanged(oldWidth: preLayoutVisibleWidth, newWidth: transitionLayout.visibleWidthForView(with: layoutContext))
        }
    }
    var contentSize: CGSize {
        return CGSize(width: visibleWidth, height: bounds.height)
    }
    private(set) var expanded: Bool = false
    // TODO: var expandableAction: SwipeAction
    
    init(action: SwipeAction) {
        self.action = action
        super.init(frame: .zero)
        // jondebug
        let action = SwipeAction()
        let frame = CGRect(origin: .zero, size: CGSize(width: bounds.width, height: bounds.height))
        let wrapperView = SwipeActionButtonWrapperView(frame: frame, action: action, contentWidth: minimumButtonWidth)
        addSubview(wrapperView)
        wrapperView.translatesAutoresizingMaskIntoConstraints = false
        wrapperView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        wrapperView.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        
        wrapperView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        wrapperView.topAnchor.constraint(equalTo: topAnchor).isActive = true
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
    
    func addButton(for action: SwipeAction,
                   withMaximum size: CGSize,
                   contentEdgeInsets: UIEdgeInsets) -> SwipeActionButton
    {
        let actionButton = SwipeActionButton(action: action)
        actionButton.addTarget(self, action: #selector(actionButtonTapped(button:)), for: .touchUpInside)
        actionButton.autoresizingMask = [.flexibleHeight, .flexibleRightMargin]
        // actionButton.contentEdgeInsets =
        
        // TODO:
        // AUTO LAYOUT
        let frame = CGRect(origin: .zero, size: CGSize(width: bounds.width, height: bounds.height))
        let wrapperView = SwipeActionButtonWrapperView(frame: frame, action: action, contentWidth: minimumButtonWidth)
        wrapperView.translatesAutoresizingMaskIntoConstraints = false
        // wrapperview addsubview button
        // TODO: setup button property
        addSubview(wrapperView)
        
        wrapperView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        wrapperView.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        
        let topConstraint = wrapperView.topAnchor.constraint(equalTo: topAnchor, constant: contentEdgeInsets.top)
        topConstraint.priority = contentEdgeInsets.top == 0 ? .required : .defaultHigh
        topConstraint.isActive = true
        
        let bottomConstraint = wrapperView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -1 * contentEdgeInsets.bottom)
        bottomConstraint.priority = contentEdgeInsets.bottom == 0 ? .required : .defaultHigh
        bottomConstraint.isActive = true
        
        // button related
//        if contentEdgeInsets != .zero {
//            let heightConstraint = wrapperView.heightAnchor.constraint(greaterThanOrEqualToConstant: button.intrinsicContentSize.height)
//            heightConstraint.priority = .required
//            heightConstraint.isActive = true
//        }
        
        return actionButton
    }
    
    @objc func actionButtonTapped(button: SwipeActionButton) {
        // delegate?.swipeActionView(self, didSelect: swipeAction)
    }
    
    func notifyVisibleWidthChanged(oldWidth: CGFloat, newWidth: CGFloat) {}

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class SwipeActionButtonWrapperView: UIView {
    let contentRect: CGRect
    var actionBackgroundColor: UIColor?
    
    init(frame: CGRect, action: SwipeAction, contentWidth: CGFloat) {
        contentRect = CGRect(x: 0, y: 0, width: contentWidth, height: frame.height)
        super.init(frame: frame)
        configureBackgroundColor(with: action)
    }
    
    func configureBackgroundColor(with action: SwipeAction) {
        // TODO
        let defaultColor = UIColor.green
        actionBackgroundColor = defaultColor
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        if let actionBackgroundColor = self.actionBackgroundColor,
            let context = UIGraphicsGetCurrentContext() {
            actionBackgroundColor.setFill()
            context.fill(rect)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
