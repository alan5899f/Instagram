//
//  UIImage-extension.swift
//  UIImage-extension
//
//  Created by 陳韋綸 on 2022/5/25.
//

import Foundation
import UIKit

extension UIImageView {
    
    func customModel(contentMode: UIView.ContentMode) -> UIImageView {
        self.contentMode = contentMode
        layer.masksToBounds = true
        return self
    }
}
