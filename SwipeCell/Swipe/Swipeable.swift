//
//  Swipeable.swift
//  SwipeCell
//
//  Created by Jon Lu on 1/11/19.
//  Copyright © 2019 Jon Lu. All rights reserved.
//

import UIKit

protocol Swipeable {
    var state: SwipeCellState { get set }
    var actionView: SwipeActionView? { get set }
    //var frame: CGRect { get }
    //var indexPath: IndexPath? { get }
    var panGestureRecognizer: UIGestureRecognizer { get }
}

extension SwipeTableViewCell: Swipeable {}

enum SwipeCellState: Int {
    case initial = 0
    case expanded
    case dragging
    case animatingToInitial
    var isActive: Bool { return self != .initial }
}
