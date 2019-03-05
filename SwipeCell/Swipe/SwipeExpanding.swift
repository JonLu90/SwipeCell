//
//  SwipeExpanding.swift
//  SwipeCell
//
//  Created by Jon Lu on 3/4/19.
//  Copyright © 2019 Jon Lu. All rights reserved.
//

import UIKit

public protocol SwipeExpanding {
    func animationTimingParameters(button: UIButton, expanding: Bool) -> SwipeExpansionAnimationTimingParameters
    func actionButton(_ button: UIButton, didChange expanding: Bool)
}

public struct SwipeExpansionAnimationTimingParameters {
    public static var `default`: SwipeExpansionAnimationTimingParameters {
        return SwipeExpansionAnimationTimingParameters()
    }
    public var duration: Double
    public var delay: Double
    
    public init(duration: Double = 0.6, delay: Double = 0) {
        self.duration = duration
        self.delay = delay
    }
}

// TODO: ScaleAndAlphaExpansion
