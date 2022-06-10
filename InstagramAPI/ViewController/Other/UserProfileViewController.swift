//
//  UserProfileViewController.swift
//  UserProfileViewController
//
//  Created by 陳韋綸 on 2022/5/25.
//

import UIKit

protocol UserProfileViewControllerDelegate: AnyObject {
    func didStories()
}

class UserProfileViewController: UIViewController {
    
    private let backButton = UIButton(type: .system).normal(system: "chevron.left", size: 20, tintColor: .black)
    private let usernameLabel = UILabel().normal(text: "姓名", ofSize: 20, weight: .bold, textColor: .black)
    private let notificationButton = UIButton(type: .system).normal(system: "bell", size: 20, tintColor: .black)
    
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
    
    private let refresh = UIRefreshControl()
    
    private var userData: UserInfoStruct
    private var userPostsData: PostsStruct?
    weak var delegate: UserProfileViewControllerDelegate?
    
    init(userData: UserInfoStruct) {
        self.userData = userData
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.isHidden = true
        view.backgroundColor = .white
        swipe()
        setupLayout()
        setupBinding()
    }
    
    private func setupBinding() {
        CatchAPI.catchUserPosts(userID: userData.id) { [weak self] result in
            switch result {
            case .success(let userPostsData):
                DispatchQueue.main.async {
                    self?.userPostsData = userPostsData
                    self?.collectionView.reloadData()
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
        backButton.addTarget(self, action: #selector(didTapBack), for: .touchUpInside)
    }
    
    @objc private func didTapBack() {
        PresentView.presentView(view: view, subtype: .fromLeft)
        dismiss(animated: false, completion: nil)
        delegate?.didStories()
    }
    
    @objc private func didTapReload() {
        CatchAPI.catchUserPosts(userID: userData.id) { [weak self] result in
            switch result {
            case .success(let userPostsData):
                DispatchQueue.main.async {
                    self?.userPostsData = userPostsData
                    self?.collectionView.reloadData()
                    self?.refresh.endRefreshing()
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    private func setupLayout() {
        usernameLabel.textAlignment = .center
        backButton.tintColor = .black
        notificationButton.tintColor = .black
        usernameLabel.text = userData.firstName + userData.lastName
        collectionView.addSubview(refresh)
        refresh.addTarget(self, action: #selector(didTapReload), for: .valueChanged)
        
        view.addSubview(backButton)
        view.addSubview(usernameLabel)
        view.addSubview(notificationButton)
        view.addSubview(collectionView)
        
        backButton.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, width: 40, height: 40, leftPadding: 10)
        notificationButton.anchor(top: view.safeAreaLayoutGuide.topAnchor, right: view.rightAnchor, width: 40, height: 40, rightPadding: 10)
        usernameLabel.anchor(top: backButton.topAnchor, bottom: backButton.bottomAnchor, left: backButton.rightAnchor, right: notificationButton.leftAnchor)
        collectionView.anchor(top: backButton.bottomAnchor, bottom: view.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor)
    }
}

extension UserProfileViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: UserProfileHeaderCollectionReusableView.identifier, for: indexPath) as? UserProfileHeaderCollectionReusableView else {
            return UICollectionReusableView()
        }
        header.delegate = self
        let username = userData.firstName + userData.lastName
        let userImageUrl = userData.picture
        let postsCount = userPostsData?.total ?? 0
        let userEmail = userData.email
        let userPhoneNumber = userData.phone
        let userBirth = userData.dateOfBirth
        let userLocal = userData.location
        header.configure(username: username, userImageUrl: userImageUrl, postsCount: postsCount, userEmail: userEmail, userPhoneNumber: userPhoneNumber, userBirth: userBirth, userLocal: userLocal)
        return header
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: view.width, height: 300)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return userPostsData?.data.count ?? 12
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: UserProfileCollectionViewCell.identifier, for: indexPath) as? UserProfileCollectionViewCell else {
            return UICollectionViewCell()
        }
        guard let postImageUrl = userPostsData?.data[indexPath.row].image else {
            cell.isSkeletonable = true
            cell.showSkeleton()
            return cell
        }
        cell.configure(postImageUrl: postImageUrl)
        cell.hideSkeleton()
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let userPostsData = userPostsData,
              let userID = UserDefaults.standard.string(forKey: "userID")  else {
            return
        }
        let username = self.userData.firstName + self.userData.lastName
        let vc = UserPostsViewController(postsData: userPostsData, username: username, indexRow: indexPath.row)
        vc.modalPresentationStyle = .overFullScreen
        present(vc, animated: true, completion: nil)
    }
}

extension UserProfileViewController {
    
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
                    self.delegate?.didStories()
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

extension UserProfileViewController: UserProfileHeaderCollectionReusableViewDelegate {
    
    func didTapEditProfile() {
        let vc = EditProfileViewController(userData: userData)
        let navvc = UINavigationController(rootViewController: vc)
        navvc.modalPresentationStyle = .fullScreen
        present(navvc, animated: true, completion: nil)
    }
}
