//
//  StoriesViewController.swift
//  StoriesViewController
//
//  Created by 陳韋綸 on 2022/5/26.
//

import UIKit
import Nuke

class StoriesViewController: UIViewController {
    
    private let sliderProgressBackground = UIView()
    private let sliderProgress = UIView()
    private let userImage = UIImageView().customModel(contentMode: .scaleAspectFill)
    private let username = UILabel().normal(text: "", ofSize: 16, weight: .semibold, textColor: .white)
    private let storiesImage = UIImageView().customModel(contentMode: .scaleAspectFit)
    private let storiesText = UILabel().normal(text: "", ofSize: 30, weight: .regular, textColor: .white)
    private var userPost: PostsStruct
    private var timer: Timer?
    private var time: CGFloat = 0
    
    init(userPost: PostsStruct) {
        self.userPost = userPost
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLayout()
        setupBinding()
    }
    
    private func setupBinding() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapImage))
        storiesImage.addGestureRecognizer(tap)
        let tap1 = UITapGestureRecognizer(target: self, action: #selector(didTapUserProfile))
        userImage.addGestureRecognizer(tap1)
        let tap2 = UITapGestureRecognizer(target: self, action: #selector(didTapUserProfile))
        username.addGestureRecognizer(tap2)
        
        let model = userPost.data[0]
        Nuke.loadImage(with: model.image, into: storiesImage)
        Nuke.loadImage(with: model.owner.picture, into: userImage)
        username.text = model.owner.firstName + model.owner.lastName
        storiesText.text = model.text + "👏👏👏👏👏"
        timeVoid()
    }
    
    private func timeVoid() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.001, repeats: true, block: { [weak self] x in
            UIView.animate(withDuration: 0.001) {
                DispatchQueue.main.async {
                    self?.time += 100*(x.timeInterval)
                    self?.sliderProgress.frame.size = CGSize(width: self?.time ?? 0, height: 2)
                    guard self?.time ?? 0 < self?.view.width ?? 0 else {
                        self?.timer?.invalidate()
                        self?.dismiss(animated: false, completion: nil)
                        return
                    }
                }
            }
        })
    }

    private func setupLayout() {
        [storiesImage, userImage, username].forEach({$0.isUserInteractionEnabled = true})
        userImage.layer.cornerRadius = 20
        storiesText.numberOfLines = 0
        storiesText.textAlignment = .center
        storiesText.backgroundColor = .red
        sliderProgress.backgroundColor = .white
        sliderProgressBackground.backgroundColor = .systemGray
        
        view.addSubview(storiesImage)
        view.addSubview(userImage)
        view.addSubview(username)
        view.addSubview(storiesText)
        view.addSubview(sliderProgressBackground)
        view.addSubview(sliderProgress)
        
        storiesImage.frame = view.bounds
        
        sliderProgress.frame = CGRect(x: 0, y: 50, width: 0, height: 2)
        sliderProgressBackground.frame = CGRect(x: 0, y: 50, width: view.width, height: 2)
        userImage.anchor(top: sliderProgressBackground.bottomAnchor, left: view.leftAnchor, width: 40, height: 40, topPadding: 10, leftPadding: 20)
        username.anchor(top: userImage.topAnchor, bottom: userImage.bottomAnchor, left: userImage.rightAnchor, leftPadding: 10)
        storiesText.anchor(bottom: view.safeAreaLayoutGuide.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, centerX: view.centerXAnchor, bottomPadding: 50, leftPadding: 20, rightPadding: 20)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        storiesText.layer.cornerRadius = 20
        storiesText.layer.masksToBounds = true
    }
    
    @objc private func didTapUserProfile() {
        
        let userID = userPost.data[0].owner.id
        CatchAPI.catchUserInfo(userID: userID) { [weak self] result in
            switch result {
            case .success(let data):
                DispatchQueue.main.async {
                    PresentView.presentView(view: self?.view ?? UIView(), subtype: .fromRight)
                    let vc = UserProfileViewController(userData: data)
                    vc.modalPresentationStyle = .overFullScreen
                    vc.delegate = self
                    self?.present(vc, animated: false, completion: nil)
                    self?.timer?.invalidate()
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    @objc private func didTapImage() {
        timer?.invalidate()
        timer = nil
        dismiss(animated: false)
    }
}

extension StoriesViewController: UserProfileViewControllerDelegate {
    func didPosts(indexRow: Int) {
        
    }
    
    func didStories() {
        timeVoid()
    }
}
