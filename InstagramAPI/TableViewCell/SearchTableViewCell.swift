//
//  SearchTableViewCell.swift
//  SearchTableViewCell
//
//  Created by 陳韋綸 on 2022/6/2.
//

import UIKit
import Nuke

class SearchTableViewCell: UITableViewCell {

    static let identifier = "SearchTableViewCell"
    
    private let userImage = UIImageView().customModel(contentMode: .scaleAspectFill)
    private let userEmail = UILabel().normal(text: "                         ", ofSize: 16, weight: .semibold, textColor: .black)
    private let username = UILabel().normal(text: "                   ", ofSize: 16, weight: .regular, textColor: .systemGray)
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        [username, userEmail, userImage].forEach({$0.backgroundColor = .systemGray5})
        setupLayout()
    }
    
    private func setupLayout() {
        userImage.layer.cornerRadius = 30
        
        contentView.addSubview(userImage)
        contentView.addSubview(userEmail)
        contentView.addSubview(username)
        
        userImage.anchor(top: contentView.topAnchor, bottom: contentView.bottomAnchor, left: contentView.leftAnchor, width: 60, height: 60, topPadding: 5, bottomPadding: 5, leftPadding: 20)
        userEmail.anchor(bottom: userImage.centerYAnchor, left: userImage.rightAnchor, bottomPadding: 1, leftPadding: 20)
        username.anchor(top: userImage.centerYAnchor, left: userEmail.leftAnchor, topPadding: 1)
    }
    
    func configure(userInfo: UserInfoStruct) {
        [username, userEmail, userImage].forEach({$0.backgroundColor = .clear})
        Nuke.loadImage(with: userInfo.picture, into: userImage)
        userEmail.text = userInfo.email
        username.text = userInfo.firstName + userInfo.lastName
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        userImage.image = nil
        userEmail.text = "                           "
        username.text = "                     "
        [username, userEmail, userImage].forEach({$0.backgroundColor = .systemGray5})
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
}
