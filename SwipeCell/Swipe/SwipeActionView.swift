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

class RevealTransisionLayout: SwipeTransitionLayout {
    func container(view: UIView, didChangeVisibleWidthWithContext context: ActionViewLayoutContext) {
        let width = context.minimumButtonWidth
        view.bounds.origin.x = (width - context.visibleWidth) * (-1)
    }
    func visibleWidthForView(with context: ActionViewLayoutContext) -> CGFloat {
        // TODO: verify
        return max(0, min(context.minimumButtonWidth, context.visibleWidth))
    }
    func layout(view: UIView, with context: ActionViewLayoutContext) {
        view.frame.origin.x = 0
    }
}

class SwipeActionView: UIView {
    var actionButton: SwipeActionButton
    var minimumButtonWidth: CGFloat = 0
    //    TODO: SwipeAnimator
    var expansionAnimator: SwipeAnimator?
    //    TODO: feebackGenerator: SwipeFeedback
    //    TODO: consider safeAreaMargin
    private(set) var isExpanded: Bool = false  // set true if cell is dragged past center
    var delegate: SwipeActionViewDelegate?
    var buttonWidth: CGFloat = 120
    let transitionLayout: SwipeTransitionLayout
    var layoutContext: ActionViewLayoutContext
    var expansionDelegate: SwipeExpanding?
    var visibleWidth: CGFloat = 0 {
        didSet {
            visibleWidth = max(0, visibleWidth)
            let preLayoutVisibleWidth = transitionLayout.visibleWidthForView(with: layoutContext)
            layoutContext = ActionViewLayoutContext.newContext(for: self)
            transitionLayout.container(view: self, didChangeVisibleWidthWithContext: layoutContext)
            
            setNeedsLayout()
            layoutIfNeeded()
            // TODO :
    //        notifyVisibleWidthChanged(oldWidth: preLayoutVisibleWidth, newWidth: transitionLayout.visibleWidthForView(with: layoutContext))
        }
    }
    // TODO :
    // depends on expanding
    var contentSize: CGSize {
        return CGSize(width: visibleWidth, height: bounds.height)
    }
    private(set) var expanded: Bool = false
    private(set) var buttonShouldMoveWithCell: Bool = false
    
    // TODO: var expandableAction: SwipeAction
    
    init(action: SwipeAction,
         maxSize: CGSize) {
        actionButton = SwipeActionButton(action: action)
        actionButton.backgroundColor = .red
        actionButton.contentEdgeInsets = .zero
        actionButton.isUserInteractionEnabled = true
        actionButton.setTitle("Track me !", for: .normal)
        
        transitionLayout = RevealTransisionLayout()
        layoutContext = ActionViewLayoutContext()
        
        super.init(frame: .zero)
        clipsToBounds = true
        translatesAutoresizingMaskIntoConstraints = false
        
//        actionButton.addTarget(self, action: #selector(actionButtonTapped(button:)), for: .touchUpInside)
        
        
        
        let frame = CGRect(origin: .zero, size: CGSize(width: bounds.width, height: bounds.height))
        
        minimumButtonWidth = 120
        
        let buttonWrapperView = SwipeActionButtonWrapperView(frame: frame, action: action, contentWidth: minimumButtonWidth)
        addSubview(buttonWrapperView)
        buttonWrapperView.addSubview(actionButton)
        
        buttonWrapperView.isUserInteractionEnabled = true
        self.isUserInteractionEnabled = true
        
        buttonWrapperView.translatesAutoresizingMaskIntoConstraints = false
        buttonWrapperView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        buttonWrapperView.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        buttonWrapperView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        buttonWrapperView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        actionButton.frame = buttonWrapperView.contentRect
        actionButton.autoresizingMask = [.flexibleLeftMargin, .flexibleHeight]
        
        actionButton.addTarget(self, action: #selector(tapButton(sender:)), for: .touchUpInside)
        
        
    }
    
    deinit {
        // for debug
        print("view is gone !")
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        let backgroundColor = UIColor.blue
        let context = UIGraphicsGetCurrentContext()
        backgroundColor.setFill()
        context?.fill(rect)
        
        // jondebug
        print("button frame : \(actionButton.frame)")
        
    }
    // for actionButton spring animation if swiped past half of the cell
    func expandIfNeeded(feedback enabled: Bool = true) {}
    
    @objc func tapButton(sender: UIButton) {
        print("fire ! button tapped!")
    }
    
    @objc func actionButtonTapped(button: SwipeActionButton) {
        // delegate?.swipeActionView(self, didSelect: swipeAction)
        print("button tapped !")
    }
    
    func notifyVisibleWidthChanged(oldWidth: CGFloat, newWidth: CGFloat) {}

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setActionButtonExpansion(expanded: Bool, feedback: Bool = false) {
//        guard self.expanded != expanded else { return }
//
//        self.expanded = true
        if expanded {
            isExpanded = true
        }
        //isExpanded = expanded
        buttonShouldMoveWithCell = true
        // TODO: Feedback
        
        if expansionAnimator?.isRunning == true {
            expansionAnimator?.stopAnimation(true)
        }
        // ios 10 only
        expansionAnimator = UIViewPropertyAnimator(duration: 0.1, dampingRatio: 1.0)
        
        expansionAnimator?.addAnimations {
            self.actionButton.center.x = self.bounds.maxX - 60
            self.setNeedsLayout()
            self.layoutIfNeeded()
        }
        if isExpanded {
            print("expansion triggered !")
            expansionAnimator?.startAnimation() }
        print("self.expanded : \(self.expanded)")
        
        triggerExpansion(expanded)
    }
    
    func triggerExpansion(_ expanded: Bool) {
        expansionDelegate?.actionButton(actionButton, didChange: expanded)
    }
}

class SwipeActionButtonWrapperView: UIView {
    let contentRect: CGRect
    var actionBackgroundColor: UIColor?
    
    init(frame: CGRect, action: SwipeAction, contentWidth: CGFloat) {
        contentRect = CGRect(x: frame.width - contentWidth, y: 0, width: contentWidth, height: frame.height)
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
