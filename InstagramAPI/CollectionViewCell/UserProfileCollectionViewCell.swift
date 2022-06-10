//
//  UserProfileCollectionViewCell.swift
//  UserProfileCollectionViewCell
//
//  Created by 陳韋綸 on 2022/5/26.
//

import Nuke
import UIKit
import SkeletonView

class UserProfileCollectionViewCell: UICollectionViewCell {
    
    static let identifier = "UserProfileCollectionViewCell"
    private let postImage = UIImageView().customModel(contentMode: .scaleAspectFill)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        isSkeletonable = true
        contentView.addSubview(postImage)
        contentView.layer.masksToBounds = true
    }
    
    func configure(postImageUrl: String) {
        Nuke.loadImage(with: postImageUrl, into: postImage)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        postImage.frame = contentView.bounds

    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        postImage.image = nil
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
}
