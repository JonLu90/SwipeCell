//
//  SwipeController.swift
//  SwipeCell
//
//  Created by Jon Lu on 1/11/19.
//  Copyright © 2019 Jon Lu. All rights reserved.
//

import Foundation
import  UIKit

protocol SwipeControllerDelegate: class {
    func editActionForSwipeable(_ controller: SwipeController) -> SwipeAction?
    func willBeginEditingSwipeable(_ controller: SwipeController)
    
}

class SwipeController: NSObject {
    
    var swipeable: (UIView & Swipeable)?
    var actionContainerView: UIView?
    var tableView: UITableView?
    var delegate: SwipeControllerDelegate?
    var originalCenter: CGFloat = 0
    lazy var panGestureRecognizer: UIPanGestureRecognizer = {
        let gesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(gesture:)))
        return gesture
    }()
    
    init(swipeable: UIView & Swipeable, actionContainerView: UIView) {
        self.swipeable = swipeable
        self.actionContainerView = actionContainerView
        
        super.init()
        
        swipeable.addGestureRecognizer(panGestureRecognizer)
    }
    
    @objc private func handlePan(gesture: UIPanGestureRecognizer) {
        guard let target = actionContainerView, var swipeable = self.swipeable else { return }
        let velocity = gesture.velocity(in: target)
        if velocity.x < 0 { return }
        
        switch gesture.state {
        case .began:
            if let swipeable = tableView?.swipeCells.first(where: { $0.state == .dragging }),
                swipeable != self.swipeable { return }
            
            stopAnimatorIfNeeded()
            originalCenter = target.center.x
            
            if swipeable.state == .initial || swipeable.state == .animatingToInitial {
                //guard let action = delegate?.editActionForSwipeable(self) else { return }
                let action = SwipeAction()
                delegate?.willBeginEditingSwipeable(self)
                configureActionView(with: action)
            }
        case .changed:
            guard let actionView = swipeable.actionView, let actionContainerView = self.actionContainerView else  { return }
            
            let translation = gesture.translation(in: target).x

            print("translation : \(translation)")
            
            actionContainerView.center.x = translation
            
            swipeable.actionView?.visibleWidth = abs(actionContainerView.frame.minX)
            actionView.setExpanded()
        case .ended, .cancelled, .failed:
            return
        default: break
        }
        
        
    }
    
    private func configureActionView(with action: SwipeAction) {
        guard var swipeable = self.swipeable,
              let actionContainerView = self.actionContainerView,
              let tableView = self.tableView else { return }
        
        let actionView = SwipeActionView()
        actionView.backgroundColor = UIColor.blue
        actionView.translatesAutoresizingMaskIntoConstraints = false
        
        actionContainerView.addSubview(actionView)
        actionView.heightAnchor.constraint(equalTo: swipeable.heightAnchor).isActive = true
        actionView.widthAnchor.constraint(equalTo: swipeable.widthAnchor, multiplier: 2).isActive = true
        actionView.topAnchor.constraint(equalTo: swipeable.topAnchor).isActive = true
        actionView.rightAnchor.constraint(equalTo: actionContainerView.leftAnchor).isActive = true
        
        actionView.setNeedsUpdateConstraints()
        
        swipeable.actionView = actionView
        swipeable.state = .dragging
    }
    
    private func stopAnimatorIfNeeded() {}
}
