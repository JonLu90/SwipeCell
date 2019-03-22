//
//  SwipeAnimator.swift
//  SwipeCell
//
//  Created by Jon Lu on 3/11/19.
//  Copyright © 2019 Jon Lu. All rights reserved.
//

import UIKit

protocol SwipeAnimator {
    var isRunning: Bool { get }
    func addAnimations(_ animation: @escaping () -> Void)
    func addCompletion(completion: @escaping (Bool) -> Void)
    func startAnimation()
    func startAnimation(afterDelay delay: TimeInterval)
    func stopAnimation(_ withoutFinishing: Bool)
}

extension UIViewPropertyAnimator: SwipeAnimator {
    func addCompletion(completion: @escaping (Bool) -> Void) {
        addCompletion { (position) in
            completion(position == .end)
        }
    }
}
