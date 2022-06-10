//
//  LottieAnimation.swift
//  LottieAnimation
//
//  Created by 陳韋綸 on 2022/6/4.
//

import Foundation
import UIKit
import Lottie

class LottieAnimation: UIView {
    
    let animationView = AnimationView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupAnimation()
    }
    
    private func setupAnimation() {
        backgroundColor = .clear
        animationView.animation = Animation.named("anime")
        animationView.frame = bounds
        animationView.animationSpeed = 2.5
        animationView.contentMode = .scaleAspectFill
        animationView.loopMode = .loop
        animationView.play()
        addSubview(animationView)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
}
