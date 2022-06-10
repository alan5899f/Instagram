//
//  OnlyPostViewController.swift
//  OnlyPostViewController
//
//  Created by 陳韋綸 on 2022/6/5.
//

import UIKit
import PKHUD
import Nuke

class OnlyPostViewController: UIViewController {
    
    private let backButton = UIButton(type: .system).normal(system: "chevron.left", size: 20, tintColor: .black)
    private let postLabel = UILabel().normal(text: "文章投稿", ofSize: 20, weight: .bold, textColor: .black)
    
    private let views = UIView()
    private var postData: PostsStructData
    private var commentData: CommentStruct
    private var userImageUrl: String

    init(postData: PostsStructData, commentData: CommentStruct, userImageUrl: String) {
        self.postData = postData
        self.commentData = commentData
        self.userImageUrl = userImageUrl
        super.init(nibName: nil, bundle: nil)
    }
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(OnlyPostTableViewCell.self, forCellReuseIdentifier: OnlyPostTableViewCell.identifier)
        tableView.register(OnlyPostCommentTableViewCell.self, forCellReuseIdentifier: OnlyPostCommentTableViewCell.identifier)
        tableView.separatorStyle = .none
        return tableView
    }()
    
    private let keyboardView = KeyBoardModels()
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupLayout()
        setupBinding()
        keyBoardNotification() 
        swipe()
    }
    
    private func setupReload() {
        CatchAPI.catchComment(postID: postData.id) { [weak self] result in
            switch result {
            case .success(let data):
                DispatchQueue.main.async {
                    self?.commentData = data
                    self?.tableView.reloadData()
                }
            case .failure(let error):
                print(error)
            }
        }
    }
    
    private func setupBinding() {
        backButton.addTarget(self, action: #selector(didTapBack), for: .touchUpInside)
    }
    
    private func setupLayout() {
        backButton.tintColor = .black
        postLabel.textAlignment = .center
        views.backgroundColor = .white
        keyboardView.delegate = self
        Nuke.loadImage(with: userImageUrl, into: keyboardView.userImage)
        
        view.addSubview(tableView)
        view.addSubview(views)
        view.addSubview(backButton)
        view.addSubview(postLabel)
        view.addSubview(keyboardView)
        
        backButton.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, width: 40, height: 40, leftPadding: 10)
        postLabel.anchor(top: backButton.topAnchor, bottom: backButton.bottomAnchor, centerX: views.centerXAnchor)
        views.anchor(top: view.topAnchor, bottom: backButton.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, bottomPadding: -10)
        keyboardView.anchor(bottom: view.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor)
        tableView.anchor(top: views.bottomAnchor, bottom: keyboardView.topAnchor, left: views.leftAnchor, right: view.rightAnchor)
    }
    
    private func keyBoardNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(didKeyboardShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didKeyboardHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc private func didKeyboardShow(info: Notification) {
        let keyboard = info.userInfo
        let keyboardInfo = (keyboard?[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue.size
        keyboardView.transform = CGAffineTransform(translationX: 0, y: -keyboardInfo.height)
        tableView.transform = CGAffineTransform(translationX: 0, y: -keyboardInfo.height)
        tableView.scrollToRow(at: IndexPath(row: 0, section: 1), at: .bottom, animated: true)
    }
    
    @objc private func didKeyboardHide(info: Notification) {
        keyboardView.transform = .identity
        keyboardView.layoutIfNeeded()
        tableView.transform = .identity
        tableView.layoutSubviews()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        views.layer.addBoard(edge: .bottom, color: .systemGray3, thickness: 0.5)
        keyboardView.layer.addBoard(edge: .top, color: .systemGray3, thickness: 0.5)
    }
    
    @objc private func didTapBack() {
        PresentView.presentView(view: view, subtype: .fromLeft)
        dismiss(animated: false, completion: nil)
    }
}

extension OnlyPostViewController {
    
    private func swipe() {
        let swipe = UIPanGestureRecognizer(target: self, action: #selector(didSwipe))
        view.addGestureRecognizer(swipe)
    }
    
    @objc private func didSwipe(_ gresture: UIPanGestureRecognizer) {
        let point = gresture.translation(in: view)
        if gresture.state == .changed {
            changed(point: point)
        }
        if gresture.state == .ended {
            ended(point: point)
        }
    }
    
    func changed(point: CGPoint) {
        guard point.x > 0 else { return }
        navigationController?.navigationBar.transform = CGAffineTransform(translationX: point.x, y: 0)
        view.transform = CGAffineTransform(translationX: point.x, y: 0)
    }
    
    func ended(point: CGPoint) {
        if point.x > view.width/2 {
            UIView.animate(withDuration: 0.1) { [weak self] in
                self?.navigationController?.navigationBar.transform = CGAffineTransform(translationX: self?.view.width ?? 0, y: 0)
                self?.view.transform = CGAffineTransform(translationX: self?.view.width ?? 0, y: 0)
            } completion: { done in
                if done {
                    self.dismiss(animated: false, completion: nil)
                }
            }
        }
        else {
            UIView.animate(withDuration: 0.1) { [weak self] in
                self?.navigationController?.navigationBar.transform = CGAffineTransform(translationX: 0, y: 0)
                self?.view.transform = CGAffineTransform(translationX: 0, y: 0)
            } completion: { done in
                if done {
                    self.navigationController?.navigationBar.transform = .identity
                    self.navigationController?.navigationBar.layoutIfNeeded()
                    self.view.transform = .identity
                    self.view.layoutIfNeeded()
                }
            }
        }
    }
}

extension OnlyPostViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        }
        else if section == 1 {
            return commentData.data?.count ?? 0
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let userImageUrl = postData.owner.picture
        let firstName = postData.owner.firstName
        let lastName = postData.owner.lastName
        let postText = postData.text
        let wallImageUrl = postData.image
        let tags = postData.tags
        let postID = postData.id
        let postTime = postData.publishDate
        let likeCount = postData.likes
        if indexPath.section == 0 {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: OnlyPostTableViewCell.identifier, for: indexPath) as? OnlyPostTableViewCell else {
                return UITableViewCell()
            }
            cell.selectionStyle = .none
            cell.configure(userImageUrl: userImageUrl, firstName: firstName, lastName: lastName, wallImageUrl: wallImageUrl, postText: postText, tags: tags, postID: postID, postTime: postTime, likeCount: likeCount)
            cell.delegate = self
            return cell
        }
        else if indexPath.section == 1 {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: OnlyPostCommentTableViewCell.identifier, for: indexPath) as? OnlyPostCommentTableViewCell else {
                return UITableViewCell()
            }
            guard let comment = commentData.data else {
                return cell
            }
            let model = comment[indexPath.row]
            let userImageUrl = model.owner.picture
            let firstName = model.owner.firstName
            let lastName = model.owner.lastName
            let commentText = model.message
            let commentPublishTime = model.publishDate
            cell.configure(userImageUrl: userImageUrl, firstName: firstName, lastName: lastName, commentText: commentText, commentPublishTime: commentPublishTime)
            cell.selectionStyle = .none
            return cell
        }
        return UITableViewCell()
    }
}

extension OnlyPostViewController: OnlyPostTableViewCellDelegate {
    
    func tapCommnet() {
        keyboardView.textField.becomeFirstResponder()
    }
    
    func tapUser() {
        HUD.show(.customView(view: LottieAnimation(frame: CGRect(x: 0, y: 0, width: view.width/3, height: view.width/3))), onView: view)
        let userID = postData.owner.id
        CatchAPI.catchUserInfo(userID: userID) { [weak self] result in
            switch result {
            case .success(let data):
                DispatchQueue.main.async {
                    HUD.hide()
                    PresentView.presentView(view: self!.view, subtype: .fromRight)
                    let vc = UserProfileViewController(userData: data)
                    vc.modalPresentationStyle = .overFullScreen
                    self?.present(vc, animated: false, completion: nil)
                }
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func tapLike() {
        let postID = postData.id
        let postLike = postData.likes
        PostAPI.uploadUserPost(postID: postID, likes: postLike)
    }
}

extension OnlyPostViewController: KeyBoardModelsDelegate {
    
    func sendToMessage(_ text: String?) {
        guard let text = text,
              !text.isEmpty else {
            let alert = UIAlertController(title: "錯誤", message: "輸入欄不得為空", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "確定", style: .cancel, handler: nil))
            present(alert, animated: true, completion: nil)
            return
        }
        PostAPI.createPostComment(postID: postData.id, message: text) { [weak self] success in
            if success {
                self?.setupReload()
                DispatchQueue.main.async {
                    self?.keyboardView.textField.text = nil
                }
            }
            else {
                let alert = UIAlertController(title: "錯誤", message: "請再試一次", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "確定", style: .cancel, handler: nil))
                self?.present(alert, animated: true, completion: nil)
            }
        }
    }
}
