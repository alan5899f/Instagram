//
//  SearchViewController.swift
//  SearchViewController
//
//  Created by 陳韋綸 on 2022/5/24.
//

import UIKit
import SkeletonView
import PKHUD

class SearchViewController: UIViewController {
    
    private let searchBar = UISearchBar()
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(SearchTableViewCell.self, forCellReuseIdentifier: SearchTableViewCell.identifier)
        tableView.separatorStyle = .none
        return tableView
    }()
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewCompositionalLayout { index, _  in
            
            let bigItem = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(0.67), heightDimension: .fractionalHeight(1)))
            bigItem.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 1, bottom: 1, trailing: 1)
            let smallItem = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1)))
            smallItem.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 1, trailing: 0)
            let tripleItem = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.33), heightDimension: .fractionalHeight(1)))
            tripleItem.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 1, trailing: 1)
            let verticalGroup = NSCollectionLayoutGroup.vertical(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.33), heightDimension: .fractionalHeight(1)), subitem: smallItem, count: 2)
            
            let horizontalGroup = NSCollectionLayoutGroup.horizontal(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalWidth(0.67)), subitems: [verticalGroup, bigItem])
            
            let threeItemGroup = NSCollectionLayoutGroup.horizontal(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalWidth(0.33)), subitem: tripleItem, count: 3)
            
            let finalGroup = NSCollectionLayoutGroup.vertical(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalWidth(1)), subitems: [horizontalGroup, threeItemGroup])
            return NSCollectionLayoutSection(group: finalGroup)
        }
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(UserProfileCollectionViewCell.self, forCellWithReuseIdentifier: UserProfileCollectionViewCell.identifier)
        return collectionView
    }()
    private let refresh = UIRefreshControl()
    
    private var postsData: [PostsStructData]?
    private var allUserInfo: UserListStruct?
    private var filteredUserInfo = [UserListStructData]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.titleView = searchBar
        view.backgroundColor = .white
        setupLayout()
        setupBinding()
    }
    
    @objc private func didTapReload() {
        collectionView.reloadData()
        refresh.endRefreshing()
    }
    
    private func setupLayout() {
        searchBar.delegate = self
        tableView.alpha = 0
        tableView.isHidden = true
        collectionView.addSubview(refresh)
        view.addSubview(collectionView)
        view.addSubview(tableView)
        collectionView.anchor(top: view.topAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor)
        tableView.anchor(top: view.safeAreaLayoutGuide.topAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor)
    }
    
    private func setupBinding() {
        refresh.addTarget(self, action: #selector(didTapReload), for: .valueChanged)
        CatchAPI.catchPost { [weak self] result in
            switch result {
            case .success(let data):
                self?.postsData = data
                DispatchQueue.main.async {
                    self?.collectionView.reloadData()
                }
            case .failure(let error):
                print(error)
            }
        }
        CatchAPI.catchUserList { [weak self] result in
            switch result {
            case .success(let data):
                self?.allUserInfo = data
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
        searchBar.frame = CGRect(x: 0, y: 0, width: view.width, height: 50)
    }
}

extension SearchViewController: UISearchBarDelegate {
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(true, animated: true)
        searchBar.becomeFirstResponder()
        self.tableView.isHidden = true
        UIView.animate(withDuration: 0.2) { [weak self] in
            self?.tableView.alpha = 1
        }
        
        tableView.isHidden = false
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(false, animated: true)
        searchBar.resignFirstResponder()
        UIView.animate(withDuration: 0.2) { [weak self] in
            self?.tableView.alpha = 0
        } completion: { done in
            if done {
                self.tableView.isHidden = true
            }
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filteredUserInfo = []
        guard searchText != "" else {
            filteredUserInfo = []
            tableView.reloadData()
            return
        }
        allUserInfo?.data.forEach({ [weak self] userInfo in
            let username = userInfo.firstName + userInfo.lastName
            if username.contains(searchText) {
                DispatchQueue.main.async {
                    self?.filteredUserInfo.append(userInfo)
                    self?.tableView.reloadData()
                }
            }
        })
    }
}

extension SearchViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return postsData?.count ?? 18
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: UserProfileCollectionViewCell.identifier, for: indexPath) as? UserProfileCollectionViewCell else {
            return UICollectionViewCell()
        }
        guard let postsData = postsData else {
            cell.isSkeletonable = true
            cell.showSkeleton()
            return cell
        }
        let postImageUrl = postsData[indexPath.row].image
        cell.configure(postImageUrl: postImageUrl)
        cell.hideSkeleton()
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        HUD.show(.customView(view: LottieAnimation(frame: CGRect(x: 0, y: 0, width: view.width/3, height: view.width/3))), onView: view)
        let postUserID = postsData?[indexPath.row].owner.id ?? ""
        CatchAPI.catchUserPosts(userID: postUserID) { [weak self] result in
            switch result {
            case .success(let data):
                DispatchQueue.main.async {
                    HUD.hide()
                    let vc = UserPostsViewController(postsData: data, username: "搜索", indexRow: 0)
                    PresentView.presentView(view: self?.view ?? UIView(), subtype: .fromRight)
                    vc.modalPresentationStyle = .overFullScreen
                    self?.present(vc, animated: false, completion: nil)
                }
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == collectionView {
            let defaultOffset = view.safeAreaInsets.top
            let offset = scrollView.contentOffset.y + defaultOffset
            navigationController?.navigationBar.transform = .init(translationX: 0, y: min(0, -offset))
        }
    }
}

extension SearchViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if !filteredUserInfo.isEmpty {
            return filteredUserInfo.count
        }
        return allUserInfo?.data.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: SearchTableViewCell.identifier, for: indexPath) as? SearchTableViewCell else {
            return UITableViewCell()
        }
        guard let userInfo = allUserInfo?.data else {
            return UITableViewCell()
        }
        if !filteredUserInfo.isEmpty {
            let filteredUserID = filteredUserInfo[indexPath.row].id
            CatchAPI.catchUserInfo(userID: filteredUserID) { [weak self] result in
                switch result {
                case .success(let data):
                    DispatchQueue.main.async {
                        cell.configure(userInfo: data)
                    }
                case .failure(let error):
                    print(error)
                }
            }
        }
        else {
            let userID = userInfo[indexPath.row].id
            CatchAPI.catchUserInfo(userID: userID) { [weak self] result in
                switch result {
                case .success(let data):
                    DispatchQueue.main.async {
                        cell.configure(userInfo: data)
                    }
                case .failure(let error):
                    print(error)
                }
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if !filteredUserInfo.isEmpty {
            let userID = filteredUserInfo[indexPath.row].id
            CatchAPI.catchUserInfo(userID: userID) { [weak self] result in
                switch result {
                case .success(let data):
                    DispatchQueue.main.async {
                        let vc = UserProfileViewController(userData: data)
                        vc.modalPresentationStyle = .overFullScreen
                        PresentView.presentView(view: self?.view ?? UIView(), subtype: .fromRight)
                        self?.present(vc, animated: false, completion: nil)
                    }
                case .failure(let error):
                    print(error)
                }
            }
        }
        else {
            let userID = allUserInfo?.data[indexPath.row].id ?? ""
            CatchAPI.catchUserInfo(userID: userID) { [weak self] result in
                switch result {
                case .success(let data):
                    DispatchQueue.main.async {
                        let vc = UserProfileViewController(userData: data)
                        vc.modalPresentationStyle = .overFullScreen
                        PresentView.presentView(view: self?.view ?? UIView(), subtype: .fromRight)
                        self?.present(vc, animated: false, completion: nil)
                    }
                case .failure(let error):
                    print(error)
                }
            }
        }
    }
}
