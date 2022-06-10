//
//  HomeCollectionViewCell.swift
//  HomeCollectionViewCell
//
//  Created by 陳韋綸 on 2022/5/25.
//

import UIKit
import Nuke
import SkeletonView

protocol HomeCollectionViewCellDelegate: AnyObject {
    func didTapStories(_ cell: HomeCollectionViewCell, indexPath: IndexPath?)
}

class HomeCollectionViewCell: UICollectionViewCell {
    
    static let identifier = "HomeCollectionViewCell"
    
    private let shape = CAShapeLayer()
    private let gradient = CAGradientLayer()
    private let animation = CABasicAnimation(keyPath: "transform.rotation")
    private let storiesImage = UIImageView().customModel(contentMode: .scaleAspectFill)
    private let username = UILabel().normal(text: "", ofSize: 14, weight: .regular, textColor: .black)
    
    var indexPath: IndexPath?
    weak var delegate: HomeCollectionViewCellDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        shape.isHidden = true
        [contentView].forEach({$0.isSkeletonable = true})
        gradientLayout()
        setupLayout()
        setupBinding()
    }
    
    private func setupBinding() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapImage))
        storiesImage.addGestureRecognizer(tap)
    }
    
    @objc private func didTapImage() {
        delegate?.didTapStories(self, indexPath: indexPath)
    }
    
    public func startStoriesed() {
        animation.fromValue = 0
        animation.toValue = Float.pi * 2
        animation.duration = 1
        animation.repeatCount = MAXFLOAT
        shape.add(animation, forKey: "urSoBasic2")
    }
    
    public func endStoriesed() {
        animation.isRemovedOnCompletion = true
        gradient.colors = [UIColor.white.cgColor, UIColor.white.cgColor]
        gradient.borderWidth = 1
        gradient.borderColor = UIColor.systemGray2.cgColor
    }
    
    private func setupLayout() {
        storiesImage.isUserInteractionEnabled = true
        username.textAlignment = .center
        
        contentView.addSubview(storiesImage)
        contentView.addSubview(username)
        storiesImage.layer.cornerRadius = (width-6)/2
        storiesImage.layer.borderWidth = 3
        storiesImage.layer.borderColor = UIColor.white.cgColor
        storiesImage.anchor(top: contentView.topAnchor, bottom: contentView.bottomAnchor, left: contentView.leftAnchor, right: contentView.rightAnchor, topPadding: 3, bottomPadding: 3, leftPadding: 3, rightPadding: 3)
        username.anchor(top: storiesImage.bottomAnchor, left: leftAnchor, right: rightAnchor, height: 30)
    }
    
    private func gradientLayout() {
        gradient.colors = [UIColor.systemPurple.cgColor ,UIColor.red.cgColor, UIColor.orange.cgColor, UIColor.yellow.cgColor]
        gradient.startPoint = CGPoint(x: 1, y: 0)
        gradient.endPoint = CGPoint(x: 0, y: 1)
        gradient.cornerRadius = width/2
        contentView.layer.addSublayer(shape)
        let circlePath = UIBezierPath(arcCenter: contentView.center, radius: 20, startAngle: 0, endAngle: .pi*2, clockwise: true)
        shape.path = circlePath.cgPath
        shape.addSublayer(gradient)
        shape.frame = contentView.bounds
        gradient.frame = shape.bounds
    }
    
    func configure(userImageUrl: String, username: String) {
        Nuke.loadImage(with: userImageUrl, into: storiesImage)
        self.username.text = username
        shape.isHidden = false
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        username.text = nil
        storiesImage.image = nil
        gradient.colors = [UIColor.systemPurple.cgColor, UIColor.red.cgColor, UIColor.orange.cgColor, UIColor.yellow.cgColor]
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
}
