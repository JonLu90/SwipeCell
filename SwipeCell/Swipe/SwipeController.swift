//
//  SwipeController.swift
//  SwipeCell
//
//  Created by Jon Lu on 1/11/19.
//  Copyright © 2019 Jon Lu. All rights reserved.
//

import Foundation
import UIKit

protocol SwipeControllerDelegate: class {
    func editActionForSwipeable(_ controller: SwipeController) -> SwipeAction?
    func willBeginEditingSwipeable(_ controller: SwipeController)
    func didEndEditingSwipeable(_ controller: SwipeController)
}

class SwipeController: NSObject {
    
    var swipeable: (UIView & Swipeable)?
    var actionContainerView: UIView?
    var tableView: UITableView?
    var delegate: SwipeControllerDelegate?
    var originalCenter: CGFloat = 0
    var animator: UIViewPropertyAnimator?
    var scrollRatio: CGFloat = 1.0
    let elasticScrollRatio: CGFloat = 0.3
    lazy var panGestureRecognizer: UIPanGestureRecognizer = {
        let gesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(gesture:)))
        gesture.delegate = self
        return gesture
    }()
    lazy var tapGestureRecognizer: UITapGestureRecognizer = {
        let gesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(gesture:)))
        return gesture
    }()
    
    init(swipeable: UIView & Swipeable, actionContainerView: UIView) {
        self.swipeable = swipeable
        self.actionContainerView = actionContainerView
        
        super.init()
        
        swipeable.addGestureRecognizer(panGestureRecognizer)
        swipeable.addGestureRecognizer(tapGestureRecognizer)
    }
    
    @objc private func handleTap(gesture: UITapGestureRecognizer) {
        hideActionView(animated: true)
    }
    
    @objc private func handlePan(gesture: UIPanGestureRecognizer) {
        guard let target = actionContainerView, var swipeable = self.swipeable else { return }
        let velocity = gesture.velocity(in: target)
        //if velocity.x < 0 { return } // TODO : optimize this
        
        switch gesture.state {
        case .began:
            if let swipeable = tableView?.swipeCells.first(where: { $0.state == .dragging }),
                swipeable != self.swipeable ?? nil { return }
            
            stopAnimatorIfNeeded()
            originalCenter = target.center.x
            
            if swipeable.state == .initial || swipeable.state == .animatingToInitial {
                //guard let action = delegate?.editActionForSwipeable(self) else { return }
                let action = SwipeAction()// for testing only, delete this and uncomment above
                delegate?.willBeginEditingSwipeable(self)
                configureActionView(with: action)
            }
        case .changed:
            guard let actionView = swipeable.actionView,
                let actionContainerView = self.actionContainerView else  { return }
            guard swipeable.state.isActive else { return }
            
            if swipeable.state == .animatingToInitial {
                let swipedCell = tableView?.swipeCells.first(where: { $0.state == .dragging || $0.state == .revealed })
                if let swipedCell = swipedCell, swipedCell != self.swipeable ?? nil { return }
            }
            let translation = gesture.translation(in: target).x
            
            // prevent user able to swipe towards left for too much distance
            if (translation + originalCenter - swipeable.bounds.midX) < 0 {
                target.center.x = gesture.elasticTranslation(in: target, withLimit: .zero, fromOriginalCenter: CGPoint(x: originalCenter, y: 0)).x
                swipeable.actionView?.visibleWidth = abs((swipeable as Swipeable).frame.minX)
                scrollRatio = elasticScrollRatio
                return
            }
            
            let targetOffset: CGFloat = actionView.buttonWidth // TODO expose this to a setter API
            let currentOffset = abs(translation + originalCenter - swipeable.bounds.midX)
            
            target.center.x = gesture.elasticTranslation(in: target, withLimit: CGSize(width: targetOffset, height: 0), fromOriginalCenter: CGPoint(x: originalCenter, y: 0), applyingRatio: 1.0).x
            
            swipeable.actionView?.visibleWidth = abs(actionContainerView.frame.minX)
            //actionView.isExpanded = actionView.visibleWidth/swipeable.bounds.width > 0.5
            
            actionView.setActionButtonExpansion(expanded: actionView.visibleWidth/swipeable.bounds.width > 0.5,
                                                feedback: false)
            
            
            
//            if actionView.isExpanded {
//                print("actionView.isExpanded : \(actionView.isExpanded)")
//                actionView.setActionButtonExpansion(expanded: true, feedback: false)
//            }
//            actionView.setActionButtonExpansion(expanded: actionView.visibleWidth/swipeable.bounds.width > 0.5, feedback: false)
            
            
            
            swipeable.actionView?.expandIfNeeded() // for the button expand animation if drag past center
        case .ended, .cancelled, .failed:
            guard let actionView = swipeable.actionView,
                let actionContainerView = self.actionContainerView else { return }
            if swipeable.state.isActive == false && swipeable.bounds.midX == target.center.x { return }
            
            swipeable.state = velocity.x < 0 && !actionView.isExpanded ? .initial : .revealed
            
            if actionView.isExpanded {
                // fire swipe action
                print("Fill animation, fire action")
            }
            else {}
            
            
            
            
            
            let targetOffset: CGFloat = targetCenter(active: swipeable.state.isActive)
            let distance = targetOffset - actionContainerView.center.x
            let normalizedVelocity = velocity.x * scrollRatio / distance
            
            animate(toOffset: targetOffset, withInitialVelocity: normalizedVelocity, completion: nil)
            
            actionView.setActionButtonExpansion(expanded: actionView.visibleWidth/swipeable.bounds.width > 0.5, feedback: false)
            
            if !swipeable.state.isActive {
                delegate?.didEndEditingSwipeable(self)
            }
        default: break
        }
        
        
    }
    
    private func handleTablePan(gesture: UIPanGestureRecognizer) {
        if gesture.state == .began {
            hideActionView(animated: true)
        }
    }
    
    private func targetCenter(active: Bool) -> CGFloat {
        guard let swipeable = self.swipeable else { return 0 }
        guard let actionView = swipeable.actionView,
            active == true else { return swipeable.bounds.midX }
        
        return swipeable.bounds.midX + actionView.buttonWidth
    }
    
    private func configureActionView(with action: SwipeAction) {
        guard var swipeable = self.swipeable,
              let actionContainerView = self.actionContainerView,
              let tableView = self.tableView else { return }
        
        swipeable.actionView?.removeFromSuperview()
        swipeable.actionView = nil
        
        let actionView = SwipeActionView(action: action, maxSize: swipeable.bounds.size)  // TODO: configure actionView
        actionView.backgroundColor = UIColor.blue
        actionView.translatesAutoresizingMaskIntoConstraints = false
        actionView.delegate = self
        // those configure above should be inside init() func depends on action
        actionContainerView.addSubview(actionView)
        
        actionContainerView.isUserInteractionEnabled = true
        
        actionView.heightAnchor.constraint(equalTo: swipeable.heightAnchor).isActive = true
        actionView.widthAnchor.constraint(equalTo: swipeable.widthAnchor, multiplier: 2).isActive = true
        actionView.topAnchor.constraint(equalTo: swipeable.topAnchor).isActive = true
        actionView.rightAnchor.constraint(equalTo: actionContainerView.leftAnchor).isActive = true
        
        actionView.setNeedsUpdateConstraints()
        
        swipeable.actionView = actionView
        swipeable.state = .dragging
    }
    
    private func stopAnimatorIfNeeded() {
        guard let animator = animator else { return }
        if animator.isRunning {
            animator.stopAnimation(true)
        }
    }
    
    public func reset() {
        swipeable?.state = .initial
        swipeable?.actionView?.removeFromSuperview()
        swipeable?.actionView = nil
    }
    
    func hideActionView(animated: Bool, completion: ((Bool)->Void)? = nil) {
        guard var swipeable = self.swipeable,
            let actionContainerView = self.actionContainerView else { return }
        guard swipeable.state == .revealed else { return }
        guard let actionView = swipeable.actionView else { return }
        
        swipeable.state = .animatingToInitial
        let targetCenter = self.targetCenter(active: false)
        
        if animated {
            animate(toOffset: targetCenter) { (animatingPosition) in
                if animatingPosition == .end {
                    self.reset()
                }
            }
        } else {}
        delegate?.didEndEditingSwipeable(self)
    }
    
    @available(iOS 10.0, *)
    private func animate(duration: Double = 0.5,
                         toOffset offset: CGFloat,
                         withInitialVelocity velocity: CGFloat = 0,
                         completion: ((UIViewAnimatingPosition)->Void)? = nil)
    {
        stopAnimatorIfNeeded()
        swipeable?.layoutIfNeeded()
        
        let animator: UIViewPropertyAnimator = {
            if velocity != 0 {
                let velocity = CGVector(dx: velocity, dy: velocity)
                let parameters = UISpringTimingParameters(mass: 1.0, stiffness: 100, damping: 18, initialVelocity: velocity)
                return UIViewPropertyAnimator(duration: duration, timingParameters: parameters)
            }
            else {
                return UIViewPropertyAnimator(duration: duration, dampingRatio: 1.0, animations: nil)
            }
        }()
        
        animator.addAnimations {
            guard let swipeable = self.swipeable,
                  let actionContainerView = self.actionContainerView else { return }
            
            actionContainerView.center = CGPoint(x: offset, y: actionContainerView.center.y)
            swipeable.actionView?.visibleWidth = abs(actionContainerView.frame.minX)
            swipeable.layoutIfNeeded()
        }
        
        if let completion = completion {
            animator.addCompletion(completion)
        }
        self.animator = animator
        
        animator.startAnimation()
    }
}

//extension SwipeController: UIGestureRecognizerDelegate {
//    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
//        if gestureRecognizer == panGestureRecognizer {
//            let gestureRecognizer = gestureRecognizer as! UIPanGestureRecognizer
//            let view = gestureRecognizer.view
//            let translation = gestureRecognizer.translation(in: view)
//            return abs(translation.y) <= abs(translation.x)  // swipecell only works if swipe left/right
//        }
//
//        return true
//    }
//}

extension SwipeController: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer == tapGestureRecognizer {
//            if UIAccessibility.isVoiceOverRunning {
//                tableView?.hideSwipeCells()
//            }
            
            let swipedCell = tableView?.swipeCells.first(where: {
                $0.state.isActive ||
                    $0.panGestureRecognizer.state == .began ||
                    $0.panGestureRecognizer.state == .changed ||
                    $0.panGestureRecognizer.state == .ended
            })
            return swipedCell == nil ? false : true
        }
        
        if gestureRecognizer == panGestureRecognizer,
            let view = gestureRecognizer.view,
            let gestureRecognizer = gestureRecognizer as? UIPanGestureRecognizer {
            let translation = gestureRecognizer.translation(in: view)
            return abs(translation.y) <= abs(translation.x)
        }
        
        return true
    }
}

extension SwipeController: SwipeActionViewDelegate {
    func swipeActionView(_ actionView: SwipeActionView, didSelect action: SwipeAction) {
        
    }
}

extension UIPanGestureRecognizer {
    func elasticTranslation(in view: UIView?,
                            withLimit limit: CGSize,
                            fromOriginalCenter center: CGPoint,
                            applyingRatio ratio: CGFloat = 0.20) -> CGPoint
    {
        let translation = self.translation(in: view)
        guard let sourceView = self.view else { return translation }
        
        let updatedCenter = CGPoint(x: center.x + translation.x, y: center.y + translation.y)
        let distanceFromCenter = CGSize(width: abs(updatedCenter.x - sourceView.bounds.midX), height: abs(updatedCenter.y - sourceView.bounds.midY))
        let inverseRatio = 1.0 - ratio
        let scale: (x: CGFloat, y: CGFloat) = (updatedCenter.x < sourceView.bounds.midX ? -1 : 1, updatedCenter.y < sourceView.bounds.midY ? -1 : 1)
        let x = updatedCenter.x - (distanceFromCenter.width > limit.width ? inverseRatio * (distanceFromCenter.width - limit.width) * scale.x : 0)
        let y = updatedCenter.y - (distanceFromCenter.height > limit.height ? inverseRatio * (distanceFromCenter.height - limit.height) * scale.y : 0)
        
        return CGPoint(x: x, y: y)
    }
}
