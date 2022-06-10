//
//  TabBarController.swift
//  TabBarController
//
//  Created by 陳韋綸 on 2022/5/24.
//

import UIKit

class TabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let userID = UserDefaults.standard.string(forKey: "userID") else {
            return
        }
        let home = HomeViewController()
        let search = SearchViewController()
        let newPost = CreateNewPostViewController()
        let notification = NotificationViewController()
        let profile = SelfProfileViewController()
        
        let navHome = UINavigationController(rootViewController: home)
        let navSearch = UINavigationController(rootViewController: search)
        let navNewPost = UINavigationController(rootViewController: newPost)
        let navNotification = UINavigationController(rootViewController: notification)
        let navProfile = UINavigationController(rootViewController: profile)
        
        navHome.tabBarItem = UITabBarItem(title: nil, image: UIImage(systemName: "house"), tag: 1)
        navSearch.tabBarItem = UITabBarItem(title: nil, image: UIImage(systemName: "magnifyingglass"), tag: 2)
        navNewPost.tabBarItem = UITabBarItem(title: nil, image: UIImage(systemName: "plus.app"), tag: 3)
        navNotification.tabBarItem = UITabBarItem(title: nil, image: UIImage(systemName: "heart"), tag: 4)
        navProfile.tabBarItem = UITabBarItem(title: nil, image: UIImage(systemName: "circlebadge.fill"), tag: 5)
        CatchAPI.catchUserInfo(userID: userID) { result in
            switch result {
            case .success(let data):
                let urlString = data.picture
                let url = URL(string: urlString)
                URLSession.shared.dataTask(with: url!) { data, _, error in
                    guard let data = data else {
                        return
                    }
                    let imageFrame = UIImage(data: data)?.size ?? CGSize()
                    let imageRatio = imageFrame.width / imageFrame.height
                    let imageWeight = 34 * imageRatio
                    DispatchQueue.main.async {
                        let image = UIImage(data: data)!.resizeImage(to: CGSize(width: imageWeight, height: 34)).cornerRadiusImage(to: 17)!.withRenderingMode(.alwaysOriginal)
                        navProfile.tabBarItem = UITabBarItem(title: nil, image: image, tag: 5)
                    }
                }.resume()
            case .failure(let error):
                print(error)
            }
        }
        self.tabBar.unselectedItemTintColor = .systemGray2
        self.tabBar.tintColor = .black
        self.tabBar.barTintColor = .white
        self.setViewControllers([navHome, navSearch, navNewPost, navNotification, navProfile], animated: false)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
}

extension UIImage {
    
    func resizeImage(to size: CGSize) -> UIImage {
        return UIGraphicsImageRenderer(size: size).image { _ in
            self.draw(in: CGRect(origin: .zero, size: size))
        }
    }
    
    func cornerRadiusImage(to radius: CGFloat? = nil) -> UIImage? {
        let maxRadius = min(size.width, size.height) / 2
        let cornerRadius: CGFloat
        if let radius = radius, radius > 0 && radius <= maxRadius {
            cornerRadius = radius
        }
        else {
            cornerRadius = maxRadius
        }
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        let rect = CGRect(origin: .zero, size: size)
        UIBezierPath(roundedRect: rect, cornerRadius: cornerRadius).addClip()
        draw(in: rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
}

