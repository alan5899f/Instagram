//
//  PresentView.swift
//  PresentView
//
//  Created by 陳韋綸 on 2022/5/26.
//

import Foundation
import UIKit

class PresentView {
    
    static func presentView(view: UIView, subtype: CATransitionSubtype) {
        let transision = CATransition()
        transision.duration = 0.5
        transision.type = CATransitionType.push
        transision.subtype = subtype
        transision.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        view.window?.layer.add(transision, forKey: kCATransition)
    }
}
