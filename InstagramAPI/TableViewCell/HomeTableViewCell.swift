//
//  HomeTableViewCell.swift
//  HomeTableViewCell
//
//  Created by 陳韋綸 on 2022/5/25.
//

import UIKit
import Nuke
import SkeletonView

protocol HomeTableViewCellDelegate: AnyObject {
    func tapCommnet(_ cell: HomeTableViewCell, indexPath: IndexPath?)
    func tapUser(_ cell: HomeTableViewCell, indexPath: IndexPath?)
    func tapLike(_ cell: HomeTableViewCell, indexPath: IndexPath?)
}

class HomeTableViewCell: UITableViewCell {

    static let identifier = "HomeTableViewCell"
    
    private let userImage = UIImageView().customModel(contentMode: .scaleAspectFill)
    private let username = UILabel().normal(text: "", ofSize: 14, weight: .regular, textColor: .black)
    private let wallImage = UIImageView().customModel(contentMode: .scaleAspectFill)
    private let postText = UILabel()
    private let tagsLabel = UILabel().normal(text: "", ofSize: 14, weight: .regular, textColor: .systemBlue)
    private let commentCountLabel = UILabel().normal(text: "", ofSize: 14, weight: .regular, textColor: .systemGray)
    private let postPublishTime = UILabel().normal(text: "", ofSize: 13, weight: .regular, textColor: .systemGray)
    private let likeButton = UIButton(type: .custom).normal(system: "heart", size: 24, tintColor: .black)
    private let commentButton = UIButton(type: .system).normal(system: "message", size: 18, tintColor: .black)
    private let shareButton = UIButton(type: .system).normal(system: "paperplane", size: 18, tintColor: .black)
    private let collectionButton = UIButton(type: .custom).normal(system: "bookmark", size: 24, tintColor: .black)
    private let likeCountLabel = UILabel().normal(text: "", ofSize: 16, weight: .bold, textColor: .black)
    private let taplikeView = UIImageView().customModel(contentMode: .scaleAspectFill)
    
    weak var delegate: HomeTableViewCellDelegate?
    var index: IndexPath?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        [self, contentView, userImage, username, wallImage, postText, tagsLabel, postPublishTime, commentCountLabel, likeButton, commentButton, shareButton,collectionButton, likeCountLabel, taplikeView].forEach({$0.isSkeletonable = true})
        setupLayout()
        setupLikeView()
        setupBinding()
        likeButton.setImage(UIImage(systemName: "heart.fill")?.applyingSymbolConfiguration(UIImage.SymbolConfiguration(pointSize: 24))?.withTintColor(.red, renderingMode: .alwaysOriginal), for: .selected)
        collectionButton.setImage(UIImage(systemName: "bookmark.fill")?.applyingSymbolConfiguration(UIImage.SymbolConfiguration(pointSize: 24))?.withTintColor(.black, renderingMode: .alwaysOriginal), for: .selected)
    }
    
    private func setupBinding() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapComment))
        commentCountLabel.addGestureRecognizer(tap)
        let tap1 = UITapGestureRecognizer(target: self, action: #selector(didTapComment))
        postText.addGestureRecognizer(tap1)
        let tapTwice = UITapGestureRecognizer(target: self, action: #selector(didTapTwice))
        tapTwice.numberOfTapsRequired = 2
        wallImage.addGestureRecognizer(tapTwice)
        
        let tap2 = UITapGestureRecognizer(target: self, action: #selector(didTapUser))
        userImage.addGestureRecognizer(tap2)
        let tap3 = UITapGestureRecognizer(target: self, action: #selector(didTapUser))
        username.addGestureRecognizer(tap3)
        
        likeButton.addTarget(self, action: #selector(didTapLike), for: .touchUpInside)
        commentButton.addTarget(self, action: #selector(didTapComment), for: .touchUpInside)
        collectionButton.addTarget(self, action: #selector(didTapCollection), for: .touchUpInside)
    }
    
    @objc private func didTapUser() {
        delegate?.tapUser(self, indexPath: index)
    }
    
    @objc private func didTapCollection() {
        collectionButton.isSelected = !collectionButton.isSelected
    }
    
    @objc private func didTapLike() {
        likeButton.isSelected = !likeButton.isSelected
        delegate?.tapLike(self, indexPath: index)
    }
    
    @objc private func didTapTwice() {
        delegate?.tapLike(self, indexPath: index)
        likeButton.isSelected = true
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.2) { [weak self] in
                self?.taplikeView.alpha = 1
                self?.taplikeView.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
            } completion: {  [weak self] done in
                if done {
                    UIView.animate(withDuration: 0.2) {
                        self?.taplikeView.transform = CGAffineTransform(scaleX: 1, y: 1)
                    } completion: { done in
                        if done {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                                self?.taplikeView.alpha = 0
                            }
                        }
                    }
                }
            }
        }
    }
    
    @objc private func didTapComment() {
        delegate?.tapCommnet(self, indexPath: index)
    }
    
    private func setupLikeView() {
        taplikeView.image = UIImage(systemName: "heart.fill")
        taplikeView.tintColor = .white
        taplikeView.backgroundColor = .clear
        taplikeView.alpha = 0
        contentView.addSubview(taplikeView)
        taplikeView.anchor(centerX: wallImage.centerXAnchor, centerY: wallImage.centerYAnchor, width: 100, height: 100)
    }
    
    private func setupLayout() {
        userImage.layer.cornerRadius = 20
        postText.sizeToFit()
        postText.numberOfLines = 0
        [commentCountLabel, postText, wallImage, username, userImage].forEach({$0.isUserInteractionEnabled = true})
        
        contentView.addSubview(userImage)
        contentView.addSubview(username)
        contentView.addSubview(wallImage)
        contentView.addSubview(postText)
        contentView.addSubview(tagsLabel)
        contentView.addSubview(commentCountLabel)
        contentView.addSubview(postPublishTime)
        contentView.addSubview(likeButton)
        contentView.addSubview(commentButton)
        contentView.addSubview(shareButton)
        contentView.addSubview(collectionButton)
        contentView.addSubview(likeCountLabel)
        // 1
        userImage.anchor(top: contentView.topAnchor, left: contentView.leftAnchor, width: 40, height: 40, topPadding: 10, leftPadding: 10)
        username.anchor(top: userImage.topAnchor, bottom: userImage.bottomAnchor, left: userImage.rightAnchor, right: contentView.rightAnchor, leftPadding: 10)
        wallImage.anchor(top: userImage.bottomAnchor, left: contentView.leftAnchor, right: contentView.rightAnchor, height: width, topPadding: 10)
        //2
        likeButton.anchor(top: wallImage.bottomAnchor, left: contentView.leftAnchor, width: 30, height: 30, topPadding: 10, leftPadding: 15)
        commentButton.anchor(top: likeButton.topAnchor, left: likeButton.rightAnchor, width: 30, height: 30, leftPadding: 10)
        shareButton.anchor(top: likeButton.topAnchor, left: commentButton.rightAnchor, width: 30, height: 30, leftPadding: 10)
        collectionButton.anchor(top: likeButton.topAnchor, right: contentView.rightAnchor, width: 30, height: 30, rightPadding: 15)
        //3
        likeCountLabel.anchor(top: likeButton.bottomAnchor, left: contentView.leftAnchor, height: 20, topPadding: 5, leftPadding: 15)
        postText.anchor(top: likeCountLabel.bottomAnchor, left: contentView.leftAnchor ,right: contentView.rightAnchor, topPadding: 5, leftPadding: 15, rightPadding: 15)
        tagsLabel.anchor(top: postText.bottomAnchor, left: postText.leftAnchor, right: postText.rightAnchor, topPadding: 5)
        commentCountLabel.anchor(top: tagsLabel.bottomAnchor, left: postText.leftAnchor, right: postText.rightAnchor, height: 20, topPadding: 5)
        postPublishTime.anchor(top: commentCountLabel.bottomAnchor, bottom: contentView.bottomAnchor, left: postText.leftAnchor, right: postText.rightAnchor, height: 20, topPadding: 5)
    }
    
    func configure(userImageUrl: String, firstName: String, lastName: String, wallImageUrl: String, postText: String, tags: [String]?, postID: String, postTime: String, likeCount: Int) {
        Nuke.loadImage(with: userImageUrl, into: userImage)
        Nuke.loadImage(with: wallImageUrl, into: wallImage)
        let usernames = firstName + lastName
        self.username.text = usernames
        self.likeCountLabel.text = "\(likeCount)個讚"
        let postTexts = " " + postText
        self.postText(username: usernames, postText: postTexts, usernameSize: 16, usernameColor: .black, postTextColor: .black)
        var tagsString = String()
        for x in tags! {
            tagsString += " #" + x
        }
        tagsLabel.text = tagsString
        
        let date = DateModels.stringToDate(postTime)
        let time = DateModels.dateInterval(videoPublishTime: date)
        postPublishTime.text = time
        CatchAPI.catchComment(postID: postID) { [weak self] result in
            switch result {
            case .success(let data):
                guard let self = self else { return }
                DispatchQueue.main.async {
                    let commentCount = data.total
                    if commentCount == 0 {
                        self.commentCountLabel.text = "目前沒有留言，來當第一個留言吧"
                    }
                    else if commentCount > 0 {
                        self.commentCountLabel.text = "查看全部\(commentCount)則留言"
                    }
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    func postText(username: String, postText: String, usernameSize: CGFloat, usernameColor: UIColor, postTextColor: UIColor) {
        let usernameCount = username.count
        let attributedTextTitle = NSMutableAttributedString(string: username)
        attributedTextTitle.addAttribute(.font, value: UIFont.systemFont(ofSize: usernameSize, weight: .bold), range: NSMakeRange(0, usernameCount))
        attributedTextTitle.addAttribute(.foregroundColor, value: usernameColor, range: NSMakeRange(0, usernameCount))
        
        let attributedPostTextCount = NSMutableAttributedString(string: postText)
        let postTextCount = postText.count
        attributedPostTextCount.addAttribute(.foregroundColor, value: postTextColor, range: NSMakeRange(0, postTextCount))
        attributedTextTitle.append(attributedPostTextCount)
        self.postText.attributedText = attributedTextTitle
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        likeButton.isSelected = false
        collectionButton.isSelected = false
        userImage.image = nil
        username.text = ""
        wallImage.image = nil
        postText.text = ""
        tagsLabel.text = ""
        commentCountLabel.text = ""
        postPublishTime.text = ""
        likeCountLabel.text = ""
    }
    
    
    required init?(coder: NSCoder) {
        fatalError()
    }
}
