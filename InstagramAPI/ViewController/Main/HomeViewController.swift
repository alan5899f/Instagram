//
//  ViewController.swift
//  InstagramAPI
//
//  Created by 陳韋綸 on 2022/5/24.
//

import UIKit
import SkeletonView
import PKHUD

class HomeViewController: UIViewController {

    private let logoImage = UIImageView().customModel(contentMode: .scaleToFill)
    private lazy var collectionView: UICollectionView = {
        let layout: UICollectionViewCompositionalLayout = {
            let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1)))
            item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10)
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: NSCollectionLayoutSize(
                widthDimension: .absolute(100),
                heightDimension: .absolute(80)), subitems: [item])
            let section = NSCollectionLayoutSection(group: group)
            section.orthogonalScrollingBehavior = .continuous
            let collection = UICollectionViewCompositionalLayout(section: section)
            return collection
        }()
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(HomeCollectionViewCell.self, forCellWithReuseIdentifier: HomeCollectionViewCell.identifier)
        collectionView.register(HomeSelfCollectionViewCell.self, forCellWithReuseIdentifier: HomeSelfCollectionViewCell.identifier)
        return collectionView
    }()
    
    private lazy var tableView: UITableView = {
       let tableView = UITableView()
        tableView.register(HomeTableViewCell.self, forCellReuseIdentifier: HomeTableViewCell.identifier)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        return tableView
    }()
    
    private let refresh = UIRefreshControl()
    
    private var postsData: [PostsStructData]?
    private var userListData: UserListStruct?
    private var selfUserInfo: UserInfoStruct?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.isHidden = true
        view.backgroundColor = .white
        setupLayout()
        setupBinding()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.tabBarController?.tabBar.isHidden = false
    }
    
    @objc private func didTapReload() {
        guard let selfUserID = UserDefaults.standard.string(forKey: "userID") else {
            return
        }
        CatchAPI.catchUserInfo(userID: selfUserID) { [weak self] result in
            switch result {
            case .success(let data):
                DispatchQueue.main.async {
                    self?.selfUserInfo = data
                    self?.collectionView.reloadData()
                }
            case .failure(let error):
                print(error)
            }
        }
        CatchAPI.catchUserList { [weak self] result in
            switch result {
            case .success(let data):
                DispatchQueue.main.async {
                    self?.userListData = data
                    self?.collectionView.reloadData()
                }
            case .failure(let error):
                print(error)
            }
        }
        CatchAPI.catchPost { [weak self] result in
            switch result {
            case .success(let data):
                self?.postsData = data
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                    self?.refresh.endRefreshing()
                }
            case .failure(let error):
                print(error)
            }
        }
    }
    
    private func tableViewHeader() -> UIView {
        collectionView.frame = CGRect(x: 0, y: 0, width: view.width, height: 110)
        return collectionView
    }
    
    private func setupLayout() {
        logoImage.image = UIImage(named: "IGLOGO")
        tableView.tableHeaderView = tableViewHeader()
        refresh.addTarget(self, action: #selector(didTapReload), for: .valueChanged)
        tableView.addSubview(refresh)
        
        view.addSubview(logoImage)
        view.addSubview(tableView)
        logoImage.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, width: 150, height: 50, leftPadding: 10)
        tableView.anchor(top: logoImage.bottomAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor)
    }
    
    private func setupBinding() {

        guard let selfUserID = UserDefaults.standard.string(forKey: "userID") else {
            return
        }
        CatchAPI.catchUserInfo(userID: selfUserID) { [weak self] result in
            switch result {
            case .success(let data):
                DispatchQueue.main.async {
                    self?.selfUserInfo = data
                    self?.collectionView.reloadData()
                }
            case .failure(let error):
                print(error)
            }
        }
        CatchAPI.catchUserList { [weak self] result in
            switch result {
            case .success(let data):
                DispatchQueue.main.async {
                    self?.userListData = data
                    self?.collectionView.reloadData()
                }
            case .failure(let error):
                print(error)
            }
        }
        CatchAPI.catchPost { [weak self] result in
            switch result {
            case .success(let data):
                self?.postsData = data
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                }
            case .failure(let error):
                print(error)
            }
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.layer.addBoard(edge: .bottom, color: .systemGray3, thickness: 0.5)
    }
}

extension HomeViewController: UITableViewDelegate, SkeletonTableViewDataSource {
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 450
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

    func collectionSkeletonView(_ skeletonView: UITableView, cellIdentifierForRowAt indexPath: IndexPath) -> ReusableCellIdentifier {
        if skeletonView == collectionView, indexPath.row == 0{
            return HomeSelfCollectionViewCell.identifier
        }
        else if skeletonView == collectionView, indexPath.row > 0 {
            return HomeCollectionViewCell.identifier
        }
        return HomeTableViewCell.identifier
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return postsData?.count ?? 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: HomeTableViewCell.identifier, for: indexPath) as? HomeTableViewCell else {
            return UITableViewCell()
        }
        cell.selectionStyle = .none
        guard let postsData = postsData else {
            cell.isSkeletonable = true
            cell.showSkeleton()
            return cell
        }
        
        let model = postsData[indexPath.row]
        let userImageUrl = model.owner.picture
        let firstName = model.owner.firstName
        let lastName = model.owner.lastName
        let wallImageUrl = model.image
        let postText = model.text
        let tags = model.tags
        let postID = model.id
        let postTime = model.publishDate
        let likeCount = model.likes
        cell.delegate = self
        cell.configure(userImageUrl: userImageUrl, firstName: firstName, lastName: lastName, wallImageUrl: wallImageUrl, postText: postText, tags: tags, postID: postID, postTime: postTime, likeCount: likeCount)
        cell.selectionStyle = .none
        cell.index = indexPath
        cell.hideSkeleton()
        return cell
    }
}

extension HomeViewController: UICollectionViewDelegate, UICollectionViewDataSource, HomeCollectionViewCellDelegate, HomeSelfCollectionViewCellDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let userListData = userListData?.data else {
            return 10
        }
        return userListData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        if indexPath.row == 0 {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HomeSelfCollectionViewCell.identifier, for: indexPath) as? HomeSelfCollectionViewCell else {
                return UICollectionViewCell()
            }
            guard let selfUserInfo = selfUserInfo else {
                cell.isSkeletonable = true
                cell.showSkeleton()
                return cell
            }
            cell.configure(userImageUrl: selfUserInfo.picture)
            cell.delegate = self
            cell.hideSkeleton()
            return cell
        }
        else if indexPath.row > 0 {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HomeCollectionViewCell.identifier, for: indexPath) as? HomeCollectionViewCell else {
                return UICollectionViewCell()
            }
            guard let userListData = userListData?.data else {
                cell.isSkeletonable = true
                cell.showSkeleton()
                return cell
            }
            let userImageUrl = userListData[indexPath.row].picture
            let lastName = userListData[indexPath.row].lastName
            let firstName = userListData[indexPath.row].firstName
            let username = lastName + firstName
            cell.configure(userImageUrl: userImageUrl, username: username)
            cell.indexPath = indexPath
            cell.delegate = self
            cell.hideSkeleton()
            return cell
        }
        return UICollectionViewCell()
    }
    
    func didTapAddStories(_ cell: HomeSelfCollectionViewCell) {
        let alert = UIAlertController(title: "敬請期待", message: "", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "確定", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    func didTapStories(_ cell: HomeCollectionViewCell, indexPath: IndexPath?) {
        guard let userID = userListData?.data[indexPath?.row ?? 0].id else { return }
        cell.startStoriesed()
        CatchAPI.catchUserPosts(userID: userID) { [weak self] result in
            switch result {
            case .success(let data):
                DispatchQueue.main.async {
                    let vc = StoriesViewController(userPost: data)
                    vc.modalPresentationStyle = .fullScreen
                    self?.present(vc, animated: false, completion: {
                        cell.endStoriesed()
                    })
                }
            case .failure(let error):
                print(error)
            }
        }

    }
}

extension HomeViewController: HomeTableViewCellDelegate {
    
    func tapLike(_ cell: HomeTableViewCell, indexPath: IndexPath?) {
        
        guard let postsData = postsData else {
            return
        }
        
        let postID = postsData[indexPath!.row].id
        let postLike = postsData[indexPath!.row].likes
        PostAPI.uploadUserPost(postID: postID, likes: postLike)
    }
    
    func tapUser(_ cell: HomeTableViewCell, indexPath: IndexPath?) {
        guard let postsData = postsData else {
            return
        }
        HUD.show(.customView(view: LottieAnimation(frame: CGRect(x: 0, y: 0, width: view.width/3, height: view.width/3))), onView: view)
        let userID = postsData[indexPath!.row].owner.id
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
    
    func tapCommnet(_ cell: HomeTableViewCell, indexPath: IndexPath?) {
        guard let selfUserInfo = selfUserInfo else {
            print("selfUserInfoError")
            return
        }
        guard let postsData = postsData else {
            print("postsDataError")
            return
        }
        HUD.show(.customView(view: LottieAnimation(frame: CGRect(x: 0, y: 0, width: view.width/3, height: view.width/3))), onView: view)
        let postID = postsData[indexPath!.row].id
        
        CatchAPI.catchComment(postID: postID) { [weak self] result in
            switch result {
            case .success(let commentData):
                DispatchQueue.main.async {
                    HUD.hide()
                    PresentView.presentView(view: self!.view, subtype: .fromRight)
                    let vc = CommentViewController(postData: postsData[indexPath!.row], commentData: commentData, selfUserImageUrl: selfUserInfo.picture)
                    vc.modalPresentationStyle = .overFullScreen
                    self?.present(vc, animated: false, completion: nil)
                }
            case .failure(let error):
                print(error)
            }
        }
    }
}
