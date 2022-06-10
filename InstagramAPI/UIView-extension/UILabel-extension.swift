//
//  UILabel-extension.swift
//  UILabel-extension
//
//  Created by 陳韋綸 on 2022/5/25.
//

import Foundation
import UIKit

extension UILabel {
    
    func normal(text: String, ofSize: CGFloat, weight: UIFont.Weight, textColor: UIColor) -> UILabel {
        font = UIFont.systemFont(ofSize: ofSize, weight: weight)
        sizeToFit()
        self.textColor = textColor
        self.text = text
        return self
    }
    
}
