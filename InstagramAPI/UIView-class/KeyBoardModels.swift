//
//  KeyBoardModels.swift
//  KeyBoardModels
//
//  Created by 陳韋綸 on 2022/6/1.
//

import Foundation
import UIKit

protocol KeyBoardModelsDelegate: AnyObject {
    func sendToMessage(_ text: String?)
}

class KeyBoardModels: UIView {
    
    public let userImage = UIImageView().customModel(contentMode: .scaleAspectFill)
    public lazy var textField: UITextView = {
        let textView = UITextView()
        textView.sizeToFit()
        textView.textColor = .black
        textView.isScrollEnabled = false
        textView.font = .systemFont(ofSize: 16)
        textView.layer.masksToBounds = true
        textView.layer.borderWidth = 1
        textView.layer.borderColor = UIColor.systemGray3.cgColor
        textView.layer.cornerRadius = 10
        return textView
    }()
    private let sendButton = UIButton(type: .system).normal(title: "送出", titleColor: .systemBlue, ofSize: 16, weight: .semibold)
    weak var delegate: KeyBoardModelsDelegate?
    
    init() {
        super.init(frame: .zero)
        backgroundColor = .white
        setupLayout()
        setupBinding()
    }
    
    private func setupBinding() {
        sendButton.addTarget(self, action: #selector(didTapSend), for: .touchUpInside)
   }
    
    @objc private func didTapSend() {
        delegate?.sendToMessage(textField.text)
    }
    
    private func setupLayout() {
        sendButton.isUserInteractionEnabled = true
        userImage.layer.cornerRadius = 25
        userImage.backgroundColor = .systemGray3
        
        addSubview(userImage)
        addSubview(textField)
        addSubview(sendButton)
        
        textField.anchor(top: topAnchor, bottom: bottomAnchor, left: userImage.rightAnchor, right: sendButton.leftAnchor, topPadding: 20, bottomPadding: 40, leftPadding: 10, rightPadding: 10)
        userImage.anchor(bottom: textField.bottomAnchor, left: leftAnchor, width: 50, height: 50, leftPadding: 10)
        sendButton.anchor(bottom: textField.bottomAnchor, right: rightAnchor, width: 50, height: 50, rightPadding: 10)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
}

