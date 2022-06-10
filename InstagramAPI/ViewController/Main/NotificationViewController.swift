//
//  NotificationViewController.swift
//  NotificationViewController
//
//  Created by 陳韋綸 on 2022/5/29.
//

import UIKit
import PKHUD

class NotificationViewController: UIViewController {
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(NotificationTableViewCell.self, forCellReuseIdentifier: NotificationTableViewCell.identifier)
        tableView.separatorStyle = .none
        return tableView
    }()
    private let refresh = UIRefreshControl()
    
    private var commentData = [CommentStructData]()
    private var postsData = [PostsStructData]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 60
        view.backgroundColor = .white
        self.navigationItem.title = "通知"
        setupLayout()
        HUD.show(.customView(view: LottieAnimation(frame: CGRect(x: 0, y: 0, width: view.width/3, height: view.width/3))), onView: view)
        setupBinding()
    }
    
    private func setupBinding() {
        guard let userID = UserDefaults.standard.string(forKey: "userID") else {
            print("NotificationViewControllerUserIDError")
            return
        }
        CatchAPI.catchUserPosts(userID: userID) { [weak self] result in
            switch result {
            case .success(let data):
                data.data.forEach { postData in
                    let postID = postData.id
                    CatchAPI.catchComment(postID: postID) { [weak self] done in
                        switch done {
                        case .success(let comments):
                            guard let comment = comments.data,
                                  !comment.isEmpty else {
                                      return
                                  }
                            self?.postsData.append(postData)
                            self?.commentData.append(comment[0])
                             DispatchQueue.main.async {
                                HUD.hide()
                                self?.tableView.reloadData()
                                 self?.refresh.endRefreshing()
                            }
                        case .failure(let errors):
                            print(errors)
                        }
                    }
                }
            case .failure(let error):
                print(error)
            }
        }
    }
    
    @objc private func didTapReload() {
        postsData.removeAll()
        commentData.removeAll()
        setupBinding()
    }
    
    private func setupLayout() {
        refresh.addTarget(self, action: #selector(didTapReload), for: .valueChanged)
        tableView.addSubview(refresh)
        view.addSubview(tableView)
        tableView.anchor(top: view.topAnchor, bottom: view.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor)
    }
}

extension NotificationViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return postsData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: NotificationTableViewCell.identifier, for: indexPath) as? NotificationTableViewCell else {
            return UITableViewCell()
        }
        cell.selectionStyle = .none
        let model = commentData[indexPath.row]
        let postImage = postsData[indexPath.row].image
        let firstName = model.owner.firstName
        let lastName = model.owner.lastName
        let username = firstName + lastName
        cell.configure(userImageUrl: model.owner.picture, text: model.message, postImageUrl: postImage, username: username)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        guard let userID = UserDefaults.standard.string(forKey: "userID") else {
            print("noID")
            return
        }
        HUD.show(.customView(view: LottieAnimation(frame: CGRect(x: 0, y: 0, width: view.width/3, height: view.width/3))), onView: view)
        let postData = postsData[indexPath.row]
        CatchAPI.catchUserInfo(userID: userID) { [weak self] result in
            switch result {
            case .success(let data):
                let userImage = data.picture
                CatchAPI.catchComment(postID: postData.id) { [weak self] result in
                    switch result {
                    case .success(let data):
                        DispatchQueue.main.async {
                            let vc = OnlyPostViewController(postData: postData, commentData: data, userImageUrl: userImage)
                            vc.modalPresentationStyle = .overFullScreen
                            PresentView.presentView(view: self?.view ?? UIView(), subtype: .fromRight)
                            self?.present(vc, animated: false, completion: nil)
                            HUD.hide()
                        }
                    case .failure(let error):
                        print(error)
                    }
                }
            case .failure(let error):
                print(error)
            }
        }
    }
}
