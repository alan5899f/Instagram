//
//  UIButton-extension.swift
//  UIButton-extension
//
//  Created by 陳韋綸 on 2022/5/25.
//

import UIKit

extension UIButton {
    
    func normal(system: String, size: CGFloat, tintColor: UIColor) -> UIButton {
        setImage(UIImage(systemName: system)?.applyingSymbolConfiguration(UIImage.SymbolConfiguration(pointSize: size))?.withTintColor(tintColor, renderingMode: .alwaysOriginal), for: .normal)
        layer.masksToBounds = true
        return self
    }
    
    func normal(title: String, titleColor: UIColor, ofSize: CGFloat, weight: UIFont.Weight) -> UIButton {
        setTitle(title, for: .normal)
        setTitleColor(titleColor, for: .normal)
        titleLabel?.font = .systemFont(ofSize: ofSize, weight: weight)
        layer.masksToBounds = true
        return self
    }
}
