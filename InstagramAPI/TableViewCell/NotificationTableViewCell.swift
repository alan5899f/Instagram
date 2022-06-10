//
//  NotificationTableViewCell.swift
//  NotificationTableViewCell
//
//  Created by 陳韋綸 on 2022/6/3.
//

import UIKit
import Nuke

class NotificationTableViewCell: UITableViewCell {

    static let identifier = "NotificationTableViewCell"
    
    private let userImage = UIImageView().customModel(contentMode: .scaleAspectFill)
    private let userText = UILabel().normal(text: "", ofSize: 16, weight: .regular, textColor: .black)
    private let postImage = UIImageView().customModel(contentMode: .scaleAspectFill)
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupLayout()
    }
    
    private func setupLayout() {
        userImage.layer.cornerRadius = 25
        userText.numberOfLines = 3
        
        contentView.addSubview(userImage)
        contentView.addSubview(userText)
        contentView.addSubview(postImage)
        
        userImage.anchor(top: contentView.topAnchor, bottom: contentView.bottomAnchor, left: contentView.leftAnchor, width: 50, height: 50, topPadding: 10, bottomPadding: 20, leftPadding: 20)
        postImage.anchor(top: userImage.topAnchor, right: contentView.rightAnchor, width: 50, height: 50, rightPadding: 20)
        userText.anchor(left: userImage.rightAnchor, right: postImage.leftAnchor, centerY: userImage.centerYAnchor, leftPadding: 10, rightPadding: 10)
    }
    
    func configure(userImageUrl: String, text: String, postImageUrl: String, username: String) {
        Nuke.loadImage(with: userImageUrl, into: userImage)
        Nuke.loadImage(with: postImageUrl, into: postImage)
        let commented = text.replacingOccurrences(of: "\n", with: "")
        let comment = "在您的貼文留言:「\(commented)」。"
        notificationText(username: username, comment: comment)
    }
    
    func notificationText(username: String, comment: String) {
        let usernameCount = username.count
        let attributedTextUsername = NSMutableAttributedString(string: username)
        attributedTextUsername.addAttribute(.font, value: UIFont.systemFont(ofSize: 16, weight: .bold), range: NSMakeRange(0, usernameCount))
        let commentCount = comment.count
        let attributerTextComment = NSMutableAttributedString(string: comment)
        attributerTextComment.addAttribute(.font, value: UIFont.systemFont(ofSize: 16, weight: .regular), range: NSMakeRange(0, commentCount))
        attributedTextUsername.append(attributerTextComment)
        userText.attributedText = attributedTextUsername
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
}
