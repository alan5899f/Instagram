//
//  CommnetTableView.swift
//  CommnetTableView
//
//  Created by 陳韋綸 on 2022/5/25.
//

import Nuke
import UIKit

class CommentOtherTableViewCell: UITableViewCell {
    
    static let identifier = "CommentOtherTableViewCell"
    
    private let userImage = UIImageView().customModel(contentMode: .scaleAspectFill)
    private let commentText = UILabel().normal(text: "", ofSize: 14, weight: .regular, textColor: .black)
    private let commentPublishTime = UILabel().normal(text: "", ofSize: 14, weight: .regular, textColor: .systemGray)
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        userImage.layer.cornerRadius = 20
        commentText.numberOfLines = 0
        
        contentView.addSubview(userImage)
        contentView.addSubview(commentText)
        contentView.addSubview(commentPublishTime)
        
        userImage.anchor(top: contentView.topAnchor, left: contentView.leftAnchor, width: 40, height: 40, topPadding: 20, leftPadding: 10)
        commentText.anchor(top: userImage.topAnchor, left: userImage.rightAnchor, right: contentView.rightAnchor, leftPadding: 10, rightPadding: 10)
        commentPublishTime.anchor(top: commentText.bottomAnchor, bottom: contentView.bottomAnchor, left: commentText.leftAnchor, right: commentText.rightAnchor, bottomPadding: 20)
    }
    
    func configure(userImageUrl: String, firstName: String, lastName: String, commentText: String, commentPublishTime: String) {
        let username = firstName + lastName
        Nuke.loadImage(with: userImageUrl, into: userImage)
        let date = DateModels.stringToDate(commentPublishTime)
        let time = DateModels.dateInterval(videoPublishTime: date)
        self.commentPublishTime.text = time
        let commentTexts = " " + commentText
        self.commentText(username: username, commentText: commentTexts, usernameSize: 15, usernameColor: .black, postTextColor: .black)
    }
    
    func commentText(username: String, commentText: String, usernameSize: CGFloat, usernameColor: UIColor, postTextColor: UIColor) {
        let usernameCount = username.count
        let attributedTextTitle = NSMutableAttributedString(string: username)
        attributedTextTitle.addAttribute(.font, value: UIFont.systemFont(ofSize: usernameSize, weight: .bold), range: NSMakeRange(0, usernameCount))
        attributedTextTitle.addAttribute(.foregroundColor, value: usernameColor, range: NSMakeRange(0, usernameCount))
        
        let attributedPostTextCount = NSMutableAttributedString(string: commentText)
        let postTextCount = commentText.count
        attributedPostTextCount.addAttribute(.foregroundColor, value: postTextColor, range: NSMakeRange(0, postTextCount))
        attributedTextTitle.append(attributedPostTextCount)
        self.commentText.attributedText = attributedTextTitle
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        userImage.image = nil
        commentText.text = nil
        commentPublishTime.text = nil
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
}
