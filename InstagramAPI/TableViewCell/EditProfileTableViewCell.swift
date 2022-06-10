//
//  EditProfileTableViewCell.swift
//  EditProfileTableViewCell
//
//  Created by 陳韋綸 on 2022/5/31.
//

import UIKit

protocol EditProfileTableViewCellDelegate: AnyObject {
    func updateHeightOfRow(_ cell: EditProfileTableViewCell, _ textView: UITextView, index: IndexPath?)
}

class EditProfileTableViewCell: UITableViewCell {

    static let identifier = "EditProfileTableViewCell"
    
    private let titleLabel = UILabel().normal(text: "", ofSize: 16, weight: .semibold, textColor: .black)
    dynamic public lazy var textField: UITextView = {
        let textView = UITextView()
        textView.sizeToFit()
        textView.textColor = .black
        textView.isScrollEnabled = false
        textView.font = .systemFont(ofSize: 20)
        textView.layer.masksToBounds = true
        textView.delegate = self
        return textView
    }()
    
    weak var delegate: EditProfileTableViewCellDelegate?
    var index: IndexPath?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupLayout()
    }
    
    private func setupLayout() {
        contentView.addSubview(titleLabel)
        contentView.addSubview(textField)
        titleLabel.anchor(top: contentView.topAnchor, left: contentView.leftAnchor, height: 40, leftPadding: 10)
        textField.anchor(top: titleLabel.topAnchor, bottom: contentView.bottomAnchor, left: titleLabel.rightAnchor, right: contentView.rightAnchor, leftPadding: 10, rightPadding: 10)
    }
    
    func configure(titleLabel: String, userData: UserInfoStruct) {
        self.titleLabel.text = titleLabel
        if index?.row == 0 {
            textField.text = userData.firstName
            UserDefaults.standard.setValue(userData.firstName, forKey: "firstName")
        }
        else if index?.row == 1 {
            textField.text = userData.lastName
            UserDefaults.standard.setValue(userData.lastName, forKey: "lastName")
        }
        else if index?.row == 2 {
            textField.text = userData.phone
            UserDefaults.standard.setValue(userData.phone, forKey: "phone")
        }
        else if index?.row == 3 {
            let text = userData.dateOfBirth
            guard text.count >= 10 else { return }
            let catchString = text.index(text.startIndex, offsetBy: 10)
            let dateOfBirthText = String(text.prefix(upTo: catchString))
            textField.text = dateOfBirthText
            UserDefaults.standard.setValue(dateOfBirthText, forKey: "dateOfBirth")
        }
        else if index?.row == 4 {
            textField.text = userData.location.country
            UserDefaults.standard.setValue(userData.location.country, forKey: "country")
        }
        else if index?.row == 5 {
            textField.text = userData.location.city
            UserDefaults.standard.setValue(userData.location.city, forKey: "city")
        }
        else if index?.row == 6 {
            textField.text = userData.location.street
            UserDefaults.standard.setValue(userData.location.street, forKey: "street")
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
}

extension EditProfileTableViewCell: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        if let deletate = delegate {
            deletate.updateHeightOfRow(self, textView, index: index)
        }
    }
}

