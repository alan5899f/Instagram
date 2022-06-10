//
//  UserProfileViewController.swift
//  UserProfileViewController
//
//  Created by 陳韋綸 on 2022/5/25.
//

import UIKit
import SkeletonView

class SelfProfileViewController: UIViewController {
    
    private let usernameLabel = UILabel().normal(text: "姓名", ofSize: 20, weight: .bold, textColor: .black)
    private let signOutButton = UIButton(type: .system).normal(system: "list.dash", size: 20, tintColor: .black)
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 1
        layout.minimumInteritemSpacing = 1
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.itemSize = CGSize(width: view.width/3-1, height: view.width/3)
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(UserProfileCollectionViewCell.self, forCellWithReuseIdentifier: UserProfileCollectionViewCell.identifier)
        collectionView.register(UserProfileHeaderCollectionReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: UserProfileHeaderCollectionReusableView.identifier)
        return collectionView
    }()
    private let nothingPost = UILabel().normal(text: "暫無貼文", ofSize: 24, weight: .semibold, textColor: .systemGray3)
    private let refresh = UIRefreshControl()
    
    private var selfUserData: UserInfoStruct?
    private var selfUserPostsData: PostsStruct?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.isHidden = true
        view.backgroundColor = .white
        setupLayout()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupBinding()
    }
    
    private func setupBinding() {
        guard let selfUserID = UserDefaults.standard.string(forKey: "userID") else {
            return
        }
        CatchAPI.catchUserInfo(userID: selfUserID) { [weak self] result in
            switch result {
            case .success(let data):
                DispatchQueue.main.async {
                    self?.selfUserData = data
                    self?.usernameLabel.text = data.firstName + data.lastName
                    self?.collectionView.reloadData()
                }
            case .failure(let error):
                print(error)
            }
        }
        CatchAPI.catchUserPosts(userID: selfUserID) { [weak self] result in
            switch result {
            case .success(let data):
                DispatchQueue.main.async {
                    self?.selfUserPostsData = data
                    self?.collectionView.reloadData()
                    self?.refresh.endRefreshing()
                    if self?.selfUserPostsData?.data.count == 0 {
                        self?.nothingPost.isHidden = false
                    } else {
                        self?.nothingPost.isHidden = true
                    }
                }
            case .failure(let error):
                print(error)
            }
        }
    }
    
    @objc private func didTapReload() {
        setupBinding()
    }
    
    @objc private func didTapSignOut() {
        let alert = UIAlertController(title: "登出", message: "確定要登出嗎？", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "登出", style: .destructive, handler: { _ in
            self.view.window?.rootViewController = SignInViewController()
            UserDefaults.standard.setValue("", forKey: "userID")
            UserDefaults.standard.setValue("" ,forKey: "firstName")
            UserDefaults.standard.setValue("" ,forKey: "lastName")
            UserDefaults.standard.setValue("" ,forKey: "phone")
            UserDefaults.standard.setValue("" ,forKey: "dateOfBirth")
            UserDefaults.standard.setValue("" ,forKey: "country")
            UserDefaults.standard.setValue("" ,forKey: "city")
            UserDefaults.standard.setValue("" ,forKey: "street")
        }))
        alert.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    private func setupLayout() {
        nothingPost.isHidden = true
        nothingPost.textAlignment = .center
        signOutButton.tintColor = .black
        collectionView.addSubview(refresh)
        refresh.addTarget(self, action: #selector(didTapReload), for: .valueChanged)
        signOutButton.addTarget(self, action: #selector(didTapSignOut), for: .touchUpInside)
        
        view.addSubview(usernameLabel)
        view.addSubview(signOutButton)
        view.addSubview(collectionView)
        view.addSubview(nothingPost)
        
        signOutButton.anchor(top: view.safeAreaLayoutGuide.topAnchor, right: view.rightAnchor, width: 40, height: 40, rightPadding: 10)
        usernameLabel.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, right: signOutButton.leftAnchor, height: 40, leftPadding: 20, rightPadding: 10)
        collectionView.anchor(top: usernameLabel.bottomAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor)
        nothingPost.anchor(top: collectionView.topAnchor, bottom: view.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, topPadding: 300)
    }
}

extension SelfProfileViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: UserProfileHeaderCollectionReusableView.identifier, for: indexPath) as? UserProfileHeaderCollectionReusableView else {
            return UICollectionReusableView()
        }
        header.delegate = self
        guard let selfUserData = selfUserData else {
            header.isSkeletonable = true
            header.showSkeleton()
            return header
        }

        let username = selfUserData.firstName + selfUserData.lastName
        let userImageUrl = selfUserData.picture
        let postsCount = selfUserPostsData?.total ?? 0
        let userEmail = selfUserData.email
        let userPhoneNumber = selfUserData.phone
        let userBirth = selfUserData.dateOfBirth
        let userLocal = selfUserData.location
        header.configure(username: username, userImageUrl: userImageUrl, postsCount: postsCount, userEmail: userEmail, userPhoneNumber: userPhoneNumber, userBirth: userBirth, userLocal: userLocal)
        header.hideSkeleton()
        return header
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: view.width, height: 300)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return selfUserPostsData?.data.count ?? 12
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: UserProfileCollectionViewCell.identifier, for: indexPath) as? UserProfileCollectionViewCell else {
            return UICollectionViewCell()
        }
        guard let postImageUrl = selfUserPostsData?.data[indexPath.row].image else {
            cell.isSkeletonable = true
            cell.showSkeleton()
            return cell
        }
        cell.hideSkeleton()
        cell.configure(postImageUrl: postImageUrl)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let userPostsData = selfUserPostsData,
              let selfUserData = selfUserData else {
                  print("error2")
            return
        }
        let username = selfUserData.lastName + selfUserData.firstName
        let vc = UserPostsViewController(postsData: userPostsData, username: username, indexRow: indexPath.row)
        vc.modalPresentationStyle = .overFullScreen
        present(vc, animated: true, completion: nil)
    }
}

extension SelfProfileViewController: UserProfileHeaderCollectionReusableViewDelegate {
    
    func didTapEditProfile() {
        guard let userData = selfUserData else { return }
        let vc = EditProfileViewController(userData: userData)
        let navvc = UINavigationController(rootViewController: vc)
        navvc.modalPresentationStyle = .fullScreen
        present(navvc, animated: true, completion: nil)
    }
}
