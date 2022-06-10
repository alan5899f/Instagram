//
//  HProgressBar.swift
//  HProgressBar
//
//  Created by 陳韋綸 on 2022/5/27.
//

import UIKit

class HProgressBar: UIView {
    
    var color: UIColor = .white {
        didSet { setNeedsDisplay() }
    }

    var progress: CGFloat = 0 {
        didSet { setNeedsDisplay() }
    }

    private let progressLayer = CALayer()
    private let backgroundMask = CAShapeLayer()
    public let image = CALayer()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayers()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupLayers()
    }

    private func setupLayers() {
        backgroundColor = .systemGray
        layer.addSublayer(progressLayer)
        image.masksToBounds = true
        image.contentsGravity = .resizeAspectFill
    }

    override func draw(_ rect: CGRect) {
        backgroundMask.path = UIBezierPath(roundedRect: rect, cornerRadius: rect.height * 0.25).cgPath
        layer.mask = backgroundMask

        let progressRect = CGRect(origin: .zero, size: CGSize(width: rect.width * progress, height: rect.height))
        layer.cornerRadius = rect.height/2
        layer.masksToBounds = true
        progressLayer.frame = progressRect
        progressLayer.backgroundColor = color.cgColor
        let imageHeight = rect.height+50
        image.frame.size = CGSize(width: imageHeight, height: imageHeight)
        image.frame.origin = CGPoint(x: left+progressRect.width-imageHeight/2, y: top-35)
    }
}
