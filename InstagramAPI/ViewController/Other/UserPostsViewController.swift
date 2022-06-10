//
//  UserPostsViewController.swift
//  UserPostsViewController
//
//  Created by 陳韋綸 on 2022/5/26.
//

import UIKit
import PKHUD

class UserPostsViewController: UIViewController {

    private let backButton = UIButton(type: .system).normal(system: "chevron.left", size: 20, tintColor: .black)
    private let usernameLabel = UILabel().normal(text: "姓名", ofSize: 20, weight: .bold, textColor: .black)
    private lazy var tableView: UITableView = {
       let tableView = UITableView()
        tableView.register(HomeTableViewCell.self, forCellReuseIdentifier: HomeTableViewCell.identifier)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        return tableView
    }()
    
    private var indexRow: Int
    private var username: String
    
    private var postsData: PostsStruct
    private var selfUserImageUrl: String?
    weak var delegate: UserProfileViewController?
    
    init(postsData: PostsStruct, username: String, indexRow: Int) {
        self.indexRow = indexRow
        self.postsData = postsData
        self.username = username
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupLayout()
        setupBinding()

        tableView.layoutIfNeeded()
        tableView.scrollToRow(at: IndexPath(item: indexRow, section: 0), at: .top, animated: false)
    }
    
    private func setupBinding() {
        guard let userID = UserDefaults.standard.string(forKey: "userID") else {
            print("userIDError!")
            return
        }
        CatchAPI.catchUserInfo(userID: userID) { [weak self] result in
            switch result {
            case .success(let data):
                DispatchQueue.main.async {
                    self?.selfUserImageUrl = data.picture
                }
            case .failure(let error):
                print(error)
            }
        }
        backButton.addTarget(self, action: #selector(didTapBack), for: .touchUpInside)
        swipe()
    }
    
    @objc private func didTapBack() {
        PresentView.presentView(view: view, subtype: .fromLeft)
        dismiss(animated: false, completion: nil)
    }
    
    private func setupLayout() {
        backButton.tintColor = .black
        usernameLabel.textAlignment = .center
        usernameLabel.text = username
        
        view.addSubview(backButton)
        view.addSubview(usernameLabel)
        view.addSubview(tableView)
        backButton.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, width: 40, height: 40, leftPadding: 10)
        usernameLabel.anchor(top: backButton.topAnchor, bottom: backButton.bottomAnchor, centerX: view.centerXAnchor)
        tableView.anchor(top: backButton.bottomAnchor, bottom: view.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor)
    }
}

extension UserPostsViewController: HomeTableViewCellDelegate {
    func tapLike(_ cell: HomeTableViewCell, indexPath: IndexPath?) {
        let postID = postsData.data[indexPath!.row].id
        let postLike = postsData.data[indexPath!.row].likes
        PostAPI.uploadUserPost(postID: postID, likes: postLike)
    }
    
    func tapUser(_ cell: HomeTableViewCell, indexPath: IndexPath?) {
        HUD.show(.customView(view: LottieAnimation(frame: CGRect(x: 0, y: 0, width: view.width/3, height: view.width/3))), onView: view)
        let userID = postsData.data[indexPath!.row].owner.id
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
                print(error.localizedDescription)
            }
        }
    }
    
    func tapCommnet(_ cell: HomeTableViewCell, indexPath: IndexPath?) {
        HUD.show(.customView(view: LottieAnimation(frame: CGRect(x: 0, y: 0, width: view.width/3, height: view.width/3))), onView: view)
        let postID = postsData.data[indexPath!.row].id
        CatchAPI.catchComment(postID: postID) { [weak self] result in
            switch result {
            case .success(let commentData):
                DispatchQueue.main.async {
                    HUD.hide()
                    PresentView.presentView(view: self!.view, subtype: .fromRight)
                    let vc = CommentViewController(postData: self!.postsData.data[indexPath!.row], commentData: commentData, selfUserImageUrl: self?.selfUserImageUrl ?? "")
                    vc.modalPresentationStyle = .overFullScreen
                    self?.present(vc, animated: false, completion: nil)
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
}

extension UserPostsViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return postsData.data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: HomeTableViewCell.identifier, for: indexPath) as? HomeTableViewCell else {
            return UITableViewCell()
        }
    
        let model = postsData.data[indexPath.row]
        let userImageUrl = model.owner.picture
        let firstName = model.owner.firstName
        let lastName = model.owner.lastName
        let wallImageUrl = model.image
        let postText = model.text
        let tags = model.tags
        let postID = model.id
        let postTime = model.publishDate
        let likeCount = model.likes
        let userID = model.owner.id
        
        cell.delegate = self
        cell.configure(userImageUrl: userImageUrl, firstName: firstName, lastName: lastName, wallImageUrl: wallImageUrl, postText: postText, tags: tags, postID: postID, postTime: postTime, likeCount: likeCount)
        cell.selectionStyle = .none
        cell.index = indexPath
        return cell
    }
}

extension UserPostsViewController {
    
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
