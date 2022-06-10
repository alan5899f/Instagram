//
//  SignUpViewController.swift
//  SignUpViewController
//
//  Created by 陳韋綸 on 2022/6/4.
//

import UIKit
import PKHUD

class SignUpViewController: UIViewController {
    
    private let backButton = UIButton(type: .system).normal(system: "chevron.left", size: 16, tintColor: .black)
    private let userImage = UIImageView().customModel(contentMode: .scaleAspectFill)
    private let emailTextField = UITextField().normal(placeholder: "Email", backgroundColor: .systemGray5, textColor: .black, ofSize: 16)
    private let phoneNumberTextField = UITextField().normal(placeholder: "PhoneNumber", backgroundColor: .systemGray5, textColor: .black, ofSize: 16)
    private let firstNameTextField = UITextField().normal(placeholder: "FirstName", backgroundColor: .systemGray5, textColor: .black, ofSize: 16)
    private let lastNameTextField = UITextField().normal(placeholder: "LastName", backgroundColor: .systemGray5, textColor: .black, ofSize: 16)
    private let birthDayTextField = UITextField().normal(placeholder: "BirthDay", backgroundColor: .systemGray5, textColor: .black, ofSize: 16)
    private let countryTextField = UITextField().normal(placeholder: "country", backgroundColor: .systemGray5, textColor: .black, ofSize: 16)
    private let cityTextField = UITextField().normal(placeholder: "city", backgroundColor: .systemGray5, textColor: .black, ofSize: 16)
    private let streetTextField = UITextField().normal(placeholder: "street", backgroundColor: .systemGray5, textColor: .black, ofSize: 16)
    private let genderLabel = UITextField().normal(placeholder: "", backgroundColor: .systemGray5, textColor: .black, ofSize: 16)
    private let pickerView = UIPickerView()
    private let signUpButton = UIButton(type: .system).normal(title: "註冊", titleColor: .white, ofSize: 20, weight: .heavy)
    
    private let gender = ["男","女","其他"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupLayout()
        setupBinding()
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    private func setupBinding() {
        signUpButton.addTarget(self, action: #selector(didTapSignUp), for: .touchUpInside)
        backButton.addTarget(self, action: #selector(didTapBack), for: .touchUpInside)
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapUserImage))
        userImage.addGestureRecognizer(tap)
    }
    
    @objc private func didTapGender() {
        
    }
    
    @objc private func didTapBack() {
        PresentView.presentView(view: view, subtype: .fromLeft)
        dismiss(animated: false, completion: nil)
    }
    
    @objc private func didTapUserImage() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        present(picker, animated: true, completion: nil)
    }
    
    @objc private func didTapSignUp() {
        guard let image = userImage.image,
              image != UIImage(named: "noImage") else {
                  let alert = UIAlertController(title: "錯誤", message: "請選擇一張照片", preferredStyle: .alert)
                  alert.addAction(UIAlertAction(title: "確定", style: .cancel, handler: nil))
                  present(alert, animated: true, completion: nil)
                  return
              }
        guard let email = emailTextField.text,
              let phone = phoneNumberTextField.text,
              let first = firstNameTextField.text,
              let last = lastNameTextField.text,
              let birth = birthDayTextField.text,
              let county = countryTextField.text,
              let city = cityTextField.text,
              let street = streetTextField.text,
              !email.isEmpty,
              !phone.isEmpty,
              !first.isEmpty,
              !last.isEmpty,
              !birth.isEmpty,
              !county.isEmpty,
              !city.isEmpty,
              !street.isEmpty else {
                  let alert = UIAlertController(title: "錯誤", message: "欄位不得為空", preferredStyle: .alert)
                  alert.addAction(UIAlertAction(title: "確定", style: .cancel, handler: nil))
                  present(alert, animated: true, completion: nil)
                  return
              }
        guard let genders = genderLabel.text,
              !genders.isEmpty,
              genders == "男" || genders == "女" || genders == "其他" else {
                  let alert = UIAlertController(title: "錯誤", message: "性別有誤，請再重新操作一次", preferredStyle: .alert)
                  alert.addAction(UIAlertAction(title: "確定", style: .cancel, handler: nil))
                  present(alert, animated: true, completion: nil)
                  return
              }
        let gender = genderData(genders: genders)
        HUD.show(.customView(view: LottieAnimation(frame: CGRect(x: 0, y: 0, width: view.width/3, height: view.width/3))), onView: view)
        CatchImgurAPI.uploadImage(image: image) { [weak self] urlString in
                PostAPI.createUserInfo(email: email, firstName: first, lastName: last, gender: gender, phone: phone, picture: urlString, dateOfBirth: birth, street: street, city: city, state: nil, country: county, timezone: nil) { success in
                    DispatchQueue.main.async {
                        if success {
                            HUD.hide()
                            PresentView.presentView(view: self?.view ?? UIView(), subtype: .fromLeft)
                            self?.dismiss(animated: false)
                        }
                        else {
                            let alert = UIAlertController(title: "錯誤", message: "不明原因", preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "確定", style: .cancel, handler: nil))
                            self?.present(alert, animated: true, completion: nil)
                        }
                    }
            }
        }
    }
    
    private func genderData(genders: String) -> String {
        if genders == "男" {
            return "male"
        }
        if genders == "女" {
            return "female"
        }
        if genders == "其他" {
            return "other"
        }
        return ""
    }
    
    private func setupLayout() {
        
        pickerView.delegate = self
        pickerView.dataSource = self
        signUpButton.layer.cornerRadius = 10
        signUpButton.backgroundColor = .systemBlue
        userImage.layer.cornerRadius = view.width/3/2
        userImage.layer.borderColor = UIColor.systemGray3.cgColor
        userImage.layer.borderWidth = 1
        userImage.isUserInteractionEnabled = true
        userImage.image = UIImage(named: "noImage")
        genderLabel.layer.cornerRadius = 25
        genderLabel.backgroundColor = UIColor.systemGray5
        genderLabel.layer.masksToBounds = true
        genderLabel.isUserInteractionEnabled = true
        genderLabel.textAlignment = .center
        genderLabel.text = "男"
        genderLabel.leftViewMode = .never
        genderLabel.inputView = pickerView
        
        view.addSubview(backButton)
        view.addSubview(userImage)
        view.addSubview(emailTextField)
        view.addSubview(phoneNumberTextField)
        view.addSubview(firstNameTextField)
        view.addSubview(lastNameTextField)
        view.addSubview(birthDayTextField)
        view.addSubview(genderLabel)
        view.addSubview(countryTextField)
        view.addSubview(cityTextField)
        view.addSubview(streetTextField)
        view.addSubview(signUpButton)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        backButton.frame = CGRect(x: 20, y: view.safeAreaInsets.top, width: 40, height: 40)
        userImage.frame = CGRect(x: view.width/3, y: view.safeAreaInsets.top + 50, width: view.width/3, height: view.width/3)
        emailTextField.frame = CGRect(x: 50, y: userImage.bottom + 50, width: view.width - 100, height: 50)
        phoneNumberTextField.frame = CGRect(x: 50, y: emailTextField.bottom + 20, width: view.width - 100, height: 50)
        firstNameTextField.frame = CGRect(x: 50, y: phoneNumberTextField.bottom + 20, width: view.width/2-50-10, height: 50)
        lastNameTextField.frame = CGRect(x: firstNameTextField.right + 20, y: firstNameTextField.top, width: view.width/2-50-10, height: 50)
        birthDayTextField.frame = CGRect(x: 50, y: lastNameTextField.bottom + 20, width: view.width - 100 - 70, height: 50)
        genderLabel.frame = CGRect(x: birthDayTextField.right + 20, y: birthDayTextField.top, width: 50, height: 50)
        let Width = ((view.width - 100)/3) - 2
        countryTextField.frame = CGRect(x: 50, y: birthDayTextField.bottom + 20, width: Width-20, height: 50)
        cityTextField.frame = CGRect(x: countryTextField.right+3, y: countryTextField.top, width: Width-20, height: 50)
        streetTextField.frame = CGRect(x: cityTextField.right+3, y: countryTextField.top, width: Width+40, height: 50)
        signUpButton.frame = CGRect(x: 50, y: countryTextField.bottom + 50, width: view.width - 100, height: 50)
    }
}

extension SignUpViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.editedImage] as? UIImage else {
            return
        }
        userImage.image = image
        dismiss(animated: true, completion: nil)
    }
}

extension SignUpViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return gender.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return gender[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if row == 0 {
            genderLabel.text = "男"
        }
        if row == 1 {
            genderLabel.text = "女"
        }
        if row == 2 {
            genderLabel.text = "其他"
        }
    }
}
