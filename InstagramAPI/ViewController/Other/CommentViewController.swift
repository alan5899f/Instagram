//
//  CommentViewController.swift
//  CommentViewController
//
//  Created by 陳韋綸 on 2022/5/25.
//

import UIKit
import Nuke

class CommentViewController: UIViewController {

    private let backButton = UIButton(type: .system).normal(system: "chevron.left", size: 20, tintColor: .black)
    private let commentLabel = UILabel().normal(text: "留言", ofSize: 20, weight: .bold, textColor: .black)
    private let shareButton = UIButton(type: .system).normal(system: "paperplane", size: 20, tintColor: .black)
    
    private let views = UIView()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(CommentOtherTableViewCell.self, forCellReuseIdentifier: CommentOtherTableViewCell.identifier)
        tableView.register(CommentSelfTableViewCell.self, forCellReuseIdentifier: CommentSelfTableViewCell.identifier)
        tableView.separatorStyle = .none
        return tableView
    }()
    private let keyboardView = KeyBoardModels()
    
    private var postData: PostsStructData
    private var commentData: CommentStruct
    private var selfUserImageUrl: String
    
    init(postData: PostsStructData, commentData: CommentStruct, selfUserImageUrl: String) {
        self.postData = postData
        self.selfUserImageUrl = selfUserImageUrl
        self.commentData = commentData
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        self.tabBarController?.tabBar.isHidden = true
        swipe()
        setupLayout()
        setupBinding()
        keyBoardNotification()
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
        Nuke.loadImage(with: selfUserImageUrl, into: keyboardView.userImage)
        backButton.addTarget(self, action: #selector(didTapBack), for: .touchUpInside)
        shareButton.addTarget(self, action: #selector(didTapShare), for: .touchUpInside)
    }
    
    @objc private func didTapBack() {
        PresentView.presentView(view: view, subtype: .fromLeft)
        dismiss(animated: false, completion: nil)
    }
    
    @objc private func didTapShare() {

    }
    
    private func keyBoardNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(showkeyboard), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(hidekeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc private func showkeyboard(note: Notification) {
        let userInfo = note.userInfo
        let keyboard = (userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue.size
        keyboardView.transform = CGAffineTransform(translationX: 0, y: -keyboard.height)
        guard tableView.contentSize.height >= tableView.height else {
            return
        }
        tableView.transform = CGAffineTransform(translationX: 0, y: -keyboard.height)
        tableView.scrollToRow(at: IndexPath(row: 0, section: 1), at: .bottom, animated: true)
    }
    
    @objc private func hidekeyboard(note: Notification) {
        keyboardView.transform = .identity
        keyboardView.layoutIfNeeded()
        tableView.transform = .identity
        tableView.layoutSubviews()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    private func setupLayout() {
        commentLabel.textAlignment = .center
        backButton.tintColor = .black
        shareButton.tintColor = .black
        views.backgroundColor = .white
        keyboardView.delegate = self
        
        view.addSubview(tableView)
        view.addSubview(views)
        view.addSubview(backButton)
        view.addSubview(commentLabel)
        view.addSubview(shareButton)
        view.addSubview(keyboardView)
        
        backButton.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, width: 40, height: 40, leftPadding: 10)
        shareButton.anchor(top: view.safeAreaLayoutGuide.topAnchor, right: view.rightAnchor, width: 40, height: 40, rightPadding: 10)
        commentLabel.anchor(top: backButton.topAnchor, bottom: backButton.bottomAnchor, left: backButton.rightAnchor, right: shareButton.leftAnchor)
        views.anchor(top: view.topAnchor, bottom: backButton.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, bottomPadding: -10)
        keyboardView.anchor(bottom: view.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor)
        tableView.anchor(top: views.bottomAnchor, bottom: keyboardView.topAnchor, left: view.leftAnchor, right: view.rightAnchor)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        views.layer.addBoard(edge: .bottom, color: .systemGray3, thickness: 0.5)
        keyboardView.layer.addBoard(edge: .top, color: .systemGray3, thickness: 0.5)
    }
}

extension CommentViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
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
        if indexPath.section == 0 {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: CommentSelfTableViewCell.identifier, for: indexPath) as? CommentSelfTableViewCell else {
                return UITableViewCell()
            }
            
            let userImageUrl = postData.owner.picture
            let firstName = postData.owner.firstName
            let lastName = postData.owner.lastName
            let commentText = postData.text
            let commentPublishTime = postData.publishDate
            
            cell.configure(userImageUrl: userImageUrl, firstName: firstName, lastName: lastName, commentText: commentText, commentPublishTime: commentPublishTime)
            cell.selectionStyle = .none
            return cell
        }
        else if indexPath.section == 1 {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: CommentOtherTableViewCell.identifier, for: indexPath) as? CommentOtherTableViewCell else {
                return UITableViewCell()
            }
            
            guard let model = commentData.data?[indexPath.row] else {
                      return UITableViewCell()
                  }
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

extension CommentViewController {
    
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
        view.transform = CGAffineTransform(translationX: point.x, y: 0)
    }
    
    func ended(point: CGPoint) {
        if point.x > view.width/2 {
            UIView.animate(withDuration: 0.1) { [weak self] in
                self?.view.transform = CGAffineTransform(translationX: self?.view.width ?? 0, y: 0)
            } completion: { done in
                if done {
                    self.dismiss(animated: false, completion: nil)
                }
            }
        }
        else {
            UIView.animate(withDuration: 0.1) { [weak self] in
                self?.view.transform = CGAffineTransform(translationX: 0, y: 0)
            } completion: { done in
                if done {
                    self.view.transform = .identity
                    self.view.layoutIfNeeded()
                }
            }
        }
    }
}

extension CommentViewController: KeyBoardModelsDelegate {
    
    func sendToMessage(_ text: String?) {
        guard let text = text,
                   text != "" else {
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
                let alert = UIAlertController(title: "發生錯誤", message: "請再試一次", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "確定", style: .cancel, handler: nil))
                self?.present(alert, animated: true, completion: nil)
            }
        }
    }
}
