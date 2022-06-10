//
//  UserProfileHeaderCollectionReusableView.swift
//  UserProfileHeaderCollectionReusableView
//
//  Created by 陳韋綸 on 2022/5/25.
//

import Nuke
import UIKit
import SkeletonView

protocol UserProfileHeaderCollectionReusableViewDelegate: AnyObject {
    func didTapEditProfile()
}

class UserProfileHeaderCollectionReusableView: UICollectionReusableView {
        
    static let identifier = "UserProfileHeaderCollectionReusableView"
    
    private let userImage = UIImageView().customModel(contentMode: .scaleAspectFill)
    private let username = UILabel().normal(text: "", ofSize: 16, weight: .bold, textColor: .black)
    private let postsCount = UILabel().normal(text: "", ofSize: 18, weight: .bold, textColor: .black)
    private let followerCount = UILabel().normal(text: "", ofSize: 18, weight: .bold, textColor: .black)
    private let followingCount = UILabel().normal(text: "", ofSize: 18, weight: .bold, textColor: .black)
    private let userEmail = UILabel().normal(text: "", ofSize: 16, weight: .regular, textColor: .black)
    private let userPhoneNumber = UILabel().normal(text: "", ofSize: 16, weight: .regular, textColor: .black)
    private let userBirth = UILabel().normal(text: "", ofSize: 16, weight: .regular, textColor: .black)
    private let userLocal = UILabel().normal(text: "", ofSize: 16, weight: .regular, textColor: .black)
    private let editButton = UIButton(type: .system).normal(title: "編輯個人檔案", titleColor: .black, ofSize: 16, weight: .bold)
    
    weak var delegate: UserProfileHeaderCollectionReusableViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
    }
    
    @objc private func didTapButton() {
        delegate?.didTapEditProfile()
    }
    
    private func setupBinding(userName: String) {
        editButton.addTarget(self, action: #selector(didTapButton), for: .touchUpInside)
        guard let username = UserDefaults.standard.string(forKey: "username") else {
            return
        }
        if username == userName {
            editButton.isHidden = false
        }
        else {
            editButton.isHidden = true
        }
    }

    private func setupLayout() {
        editButton.layer.borderWidth = 1
        editButton.layer.borderColor = UIColor.systemGray3.cgColor
        editButton.layer.cornerRadius = 10
        userImage.layer.cornerRadius = 50
        [postsCount, followerCount, followingCount].forEach({$0.numberOfLines = 2})
        [postsCount, followerCount, followingCount].forEach({$0.textAlignment = .center})
        userLocal.numberOfLines = 0
        
        addSubview(userImage)
        addSubview(postsCount)
        addSubview(followerCount)
        addSubview(followingCount)
        addSubview(editButton)
        
        userImage.anchor(top: topAnchor, left: leftAnchor, width: 100, height: 100, topPadding: 10, leftPadding: 15)
        followingCount.anchor(right: rightAnchor, centerY: userImage.centerYAnchor, rightPadding: 40)
        followerCount.anchor(right: followingCount.leftAnchor, centerY: userImage.centerYAnchor, rightPadding: 40)
        postsCount.anchor(right: followerCount.leftAnchor, centerY: userImage.centerYAnchor, rightPadding: 40)
        
        let Vstack = UIStackView(arrangedSubviews: [username, userEmail, userPhoneNumber, userBirth, userLocal, editButton])
        addSubview(Vstack)
        Vstack.axis = .vertical
        Vstack.spacing = 5
        Vstack.distribution = .equalSpacing
        Vstack.anchor(top: userImage.bottomAnchor, left: leftAnchor, right: rightAnchor, topPadding: 10, leftPadding: 15, rightPadding: 15)
        [username, userImage, userEmail, userPhoneNumber, userBirth, userLocal, followerCount, followingCount, postsCount, Vstack].forEach({$0.isSkeletonable = true})
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()

    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    func configure(username: String, userImageUrl: String, postsCount: Int, userEmail: String, userPhoneNumber: String, userBirth: String, userLocal: UserStructLocation) {
        Nuke.loadImage(with: userImageUrl, into: userImage)
        self.username.text = username
        self.followerCount.text = "2.7k\n粉絲"
        self.followingCount.text = "283\n追蹤中"
        self.postsCount.text = "\(postsCount)\n貼文"
        self.userEmail.text = "✉️Email: " + userEmail
        self.userPhoneNumber.text = "📱Phone: " + userPhoneNumber
        self.userLocal.text = "🏝Local: " + userLocal.country + " " + userLocal.city + " " + userLocal.street
        
        let catch10 = userBirth.index(userBirth.startIndex, offsetBy: 10)
        self.userBirth.text = "🎂Birth: " + userBirth.prefix(upTo: catch10)
        setupBinding(userName: username)
        
    }
}
