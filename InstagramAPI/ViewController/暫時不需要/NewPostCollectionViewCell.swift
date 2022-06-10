//
//  NewPostCollectionViewCell.swift
//  NewPostCollectionViewCell
//
//  Created by 陳韋綸 on 2022/6/7.
//

import UIKit

class NewPostCollectionViewCell: UICollectionViewCell {
    
    static let identifier = "NewPostCollectionViewCell"
    
    public var image = UIImageView().customModel(contentMode: .scaleAspectFill)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(image)
        image.frame = contentView.bounds
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
}
