//
//  HomeCollectionViewCell.swift
//  HomeCollectionViewCell
//
//  Created by 陳韋綸 on 2022/5/25.
//

import UIKit
import Nuke
import SkeletonView

protocol HomeSelfCollectionViewCellDelegate: AnyObject {
    func didTapAddStories(_ cell: HomeSelfCollectionViewCell)
}

class HomeSelfCollectionViewCell: UICollectionViewCell {
    
    static let identifier = "HomeSelfCollectionViewCell"
    
    private let shape = CAShapeLayer()
    private let gradient = CAGradientLayer()
    private let animation = CABasicAnimation(keyPath: "transform.rotation")
    private let storiesImage = UIImageView().customModel(contentMode: .scaleAspectFill)
    private let storiesAddIconImage = UIButton(type: .custom)
    
    private let username = UILabel().normal(text: "", ofSize: 14, weight: .regular, textColor: .black)
    
    weak var delegate: HomeSelfCollectionViewCellDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        [contentView].forEach({$0.isSkeletonable = true})
        setupLayout()
        setupBinding()
    }
    
    private func setupBinding() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapImage))
        storiesImage.addGestureRecognizer(tap)
        storiesAddIconImage.addTarget(self, action: #selector(didTapImage), for: .touchUpInside)
    }
    
    @objc private func didTapImage() {
        delegate?.didTapAddStories(self)
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
        contentView.addSubview(storiesAddIconImage)
        contentView.addSubview(username)
        
        storiesImage.layer.cornerRadius = (width-6)/2
        storiesImage.layer.borderWidth = 3
        storiesImage.layer.borderColor = UIColor.white.cgColor
        storiesAddIconImage.layer.borderColor = UIColor.white.cgColor
        storiesAddIconImage.layer.borderWidth = 4
        storiesAddIconImage.layer.cornerRadius = 15
        storiesAddIconImage.backgroundColor = .systemBlue
        storiesAddIconImage.setImage(UIImage(systemName: "plus")?.applyingSymbolConfiguration(UIImage.SymbolConfiguration(pointSize: 13, weight: .bold)), for: .normal)
        storiesAddIconImage.tintColor = .white
        
        storiesImage.anchor(top: contentView.topAnchor, bottom: contentView.bottomAnchor, left: contentView.leftAnchor, right: contentView.rightAnchor, topPadding: 3, bottomPadding: 3, leftPadding: 3, rightPadding: 3)
        storiesAddIconImage.anchor(bottom: storiesImage.bottomAnchor, right: storiesImage.rightAnchor, width: 30, height: 30)
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
    
    func configure(userImageUrl: String) {
        Nuke.loadImage(with: userImageUrl, into: storiesImage)
        username.text = "新增限時動態"
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        username.text = nil
        storiesImage.image = nil
        gradient.colors = [UIColor.systemPurple.cgColor, UIColor.red.cgColor, UIColor.orange.cgColor, UIColor.yellow.cgColor]
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
}
