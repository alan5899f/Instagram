//
//  SignInViewController.swift
//  SignInViewController
//
//  Created by 陳韋綸 on 2022/5/30.
//

import UIKit
import PKHUD

class SignInViewController: UIViewController {
    
    private let logoImage = UIImageView().customModel(contentMode: .scaleAspectFill)
    private let gradient  = CAGradientLayer()
    private let emailTextField = UITextField().normal(placeholder: "email", backgroundColor: .systemGray5, textColor: .black, ofSize: 16)
    private let phoneNumberTextField = UITextField().normal(placeholder: "phoneNumber", backgroundColor: .systemGray5, textColor: .black, ofSize: 16)
    private let signInButton = UIButton(type: .system).normal(title: "登入", titleColor: .white, ofSize: 20, weight: .heavy)
    private let signUpButton = UIButton(type: .system).normal(title: "還沒有帳號嗎?快來點我註冊", titleColor: .systemBlue, ofSize: 16, weight: .regular)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupLayout()
        setupBinding()
    }
    
    private func setupBinding() {
        signInButton.addTarget(self, action: #selector(didTapSignIn), for: .touchUpInside)
        signUpButton.addTarget(self, action: #selector(didTapSignUp), for: .touchUpInside)
    }
    
    @objc private func didTapSignUp() {
        let vc = SignUpViewController()
        PresentView.presentView(view: view, subtype: .fromRight)
        vc.modalPresentationStyle = .overFullScreen
        present(vc, animated: false, completion: nil)
    }
    
    @objc private func didTapSignIn() {
        guard let text = emailTextField.text,
        let phone = phoneNumberTextField.text else {
            return
        }
        HUD.show(.customView(view: LottieAnimation(frame: CGRect(x: 0, y: 0, width: view.width/3, height: view.width/3))), onView: view)
        AuthManager.authSignIn(userEmail: text, phoneNumber: phone) { [weak self] success in
            DispatchQueue.main.async {
                if success {
                    HUD.hide()
                    self?.view.window?.rootViewController = TabBarController()
                }
                else {
                    HUD.hide()
                    print("none")
                }
            }
        }
    }
    
    private func setupLayout() {
        gradient.colors = [#colorLiteral(red: 1, green: 0.01592320949, blue: 0.2254638672, alpha: 1).cgColor, #colorLiteral(red: 0.9948360324, green: 0, blue: 0.4879615307, alpha: 1).cgColor, #colorLiteral(red: 0.953856051, green: 0, blue: 0.7618673444, alpha: 1).cgColor]
        gradient.startPoint = CGPoint(x: 0, y: 0)
        gradient.endPoint = CGPoint(x: 1, y: 0)
        logoImage.image = UIImage(named: "IGICON")
        signInButton.layer.cornerRadius = 10
        signInButton.backgroundColor = .systemBlue
        
        view.layer.addSublayer(gradient)
        view.addSubview(logoImage)
        view.addSubview(emailTextField)
        view.addSubview(phoneNumberTextField)
        view.addSubview(signInButton)
        view.addSubview(signUpButton)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradient.frame = CGRect(x: 0, y: view.top, width: view.width, height: 300)
        logoImage.frame.size = CGSize(width: 100, height: 100)
        logoImage.center = CGPoint(x: gradient.frame.midX, y: gradient.frame.midY)
        let logoImageBottom = gradient.frame.maxY
        emailTextField.frame = CGRect(x: 50, y: logoImageBottom + 50, width: view.width - 100, height: 50)
        phoneNumberTextField.frame = CGRect(x: 50, y: emailTextField.bottom + 20, width: view.width - 100, height: 50)
        signInButton.frame = CGRect(x: 50, y: phoneNumberTextField.bottom + 50, width: view.width - 100, height: 50)
        signUpButton.frame = CGRect(x: 50, y: signInButton.bottom + 50, width: view.width - 100, height: 50)
    }
}
