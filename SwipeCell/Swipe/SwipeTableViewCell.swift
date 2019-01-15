//
//  SwipeTableViewCell.swift
//  SwipeCell
//
//  Created by Jon Lu on 1/14/19.
//  Copyright © 2019 Jon Lu. All rights reserved.
//

import Foundation
import UIKit

protocol SwipeTableViewCellDelegate: class {
    func tableView(_ tableView: UITableView, editActionForRowAt indexPath: IndexPath) -> SwipeAction
    func tableView(_ tableView: UITableView, willBeginEditingRowAt indexPath: IndexPath)
    func tableView(_ tableView: UITableView, didEndEditingRowAt indexPath: IndexPath)
}

class SwipeTableViewCell: UITableViewCell {
    
    var delegate: SwipeTableViewCellDelegate?
    var state = SwipeCellState.initial
    var actionView: SwipeActionView?
    var swipeController: SwipeController!
    var tableView: UITableView?
    var indexPath: IndexPath? {
        return tableView?.indexPath(for: self)
    }
    var panGestureRecognizer: UIGestureRecognizer {
        
        return swipeController.panGestureRecognizer
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        swipeController = SwipeController(swipeable: self, actionContainerView: self)
        //swipeController.delegate = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        
        var view: UIView = self
        while let superview = view.superview {
            view = superview
            if let tableView = view as? UITableView {
                self.tableView = tableView
                swipeController.tableView = tableView
                
                // handle table pan
            }
        }
    }
    
    private func reset() {
        swipeController.reset()
        clipsToBounds = false
    }
}
