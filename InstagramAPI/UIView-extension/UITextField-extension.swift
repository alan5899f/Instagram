//
//  UITextField-extension.swift
//  UITextField-extension
//
//  Created by 陳韋綸 on 2022/5/30.
//

import Foundation
import UIKit

extension UITextField {
    
    func normal(placeholder: String, backgroundColor: UIColor, textColor: UIColor, ofSize: CGFloat) -> UITextField {
        leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: height))
        leftViewMode = .always
        autocapitalizationType = .none
        autocorrectionType = .no
        self.placeholder = placeholder
        self.backgroundColor = backgroundColor
        self.textColor = textColor
        self.font = .systemFont(ofSize: ofSize)
        self.layer.cornerRadius = 10
        self.layer.masksToBounds = true
        return self
    }
}
