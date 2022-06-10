//
//  EditProfileViewController.swift
//  EditProfileViewController
//
//  Created by 陳韋綸 on 2022/5/31.
//

import Nuke
import UIKit
import PKHUD
import Alamofire

class EditProfileViewController: UIViewController {

    private lazy var tableView: UITableView = {
       let tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(EditProfileTableViewCell.self, forCellReuseIdentifier: EditProfileTableViewCell.identifier)
        return tableView
    }()
    
    private let headerViews = UIView()
    private let userImage = UIImageView().customModel(contentMode: .scaleAspectFill)
    private let userImageEditButton = UIButton(type: .system).normal(title: "個人照片變更", titleColor: .systemBlue, ofSize: 15, weight: .bold)
    
    private let titleLabel = ["姓氏", "名字", "電話", "生日", "國家", "城市", "街道"]
    private var userData: UserInfoStruct
    
    init(userData: UserInfoStruct) {
        self.userData = userData
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "取消", style: .done, target: self, action: #selector(didTapBack))
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "完成", style: .done, target: self, action: #selector(didTapDone))
        self.navigationItem.leftBarButtonItem?.tintColor = .black
        self.navigationItem.title = "編輯個人檔案"

        setupLayout()
        setupBinding()
    }
    
    private func setupBinding() {
        userImageEditButton.addTarget(self, action: #selector(didTapEdit), for: .touchUpInside)
        let imageUrl = userData.picture
        UserDefaults.standard.setValue(imageUrl, forKey: "picture")
        Nuke.loadImage(with: imageUrl, into: userImage)
    }
    
    @objc private func didTapEdit() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        picker.sourceType = .photoLibrary
        present(picker, animated: true, completion: nil)
    }
    
    private func setupUserInfo() {
        guard let firstName = UserDefaults.standard.string(forKey: "firstName"),
              let lastName = UserDefaults.standard.string(forKey: "lastName"),
              let dateOfBirth = UserDefaults.standard.string(forKey: "dateOfBirth"),
              let phone = UserDefaults.standard.string(forKey: "phone"),
              let country = UserDefaults.standard.string(forKey: "country"),
              let city = UserDefaults.standard.string(forKey: "city"),
              let street = UserDefaults.standard.string(forKey: "street"),
              let picture = UserDefaults.standard.string(forKey: "picture") else {
                  let alert = UIAlertController(title: "發生錯誤", message: "請稍後再試", preferredStyle: .alert)
                  alert.addAction(UIAlertAction(title: "確定", style: .cancel, handler: nil))
                  present(alert, animated: true, completion: nil)
                  return
              }

        HUD.show(.customView(view: LottieAnimation(frame: CGRect(x: 0, y: 0, width: view.width/3, height: view.width/3))), onView: view)
        PostAPI.uploadUserInfo(firstName: firstName, lastName: lastName, dateOfBirth: dateOfBirth, phone: phone, street: street, city: city, country: country, pictureUrl: picture) { [weak self] success in
            DispatchQueue.main.async {
                if success {
                    HUD.hide()
                    self?.dismiss(animated: true, completion: nil)
                }
                else {
                    HUD.hide()
                    let alert = UIAlertController(title: "發生錯誤", message: "請稍後再試", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "確定", style: .cancel, handler: nil))
                    self?.present(alert, animated: true, completion: nil)
                }
            }
        }
    }
    
    private func setupLayout() {
        userImage.layer.cornerRadius = 50
        tableView.tableHeaderView = headerView()
        
        view.addSubview(tableView)
        tableView.anchor(top: view.safeAreaLayoutGuide.topAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, leftPadding: 10, rightPadding: 10)
    }
    
    private func headerView() -> UIView {
        headerViews.frame = CGRect(x: 0, y: 0, width: view.width-20, height: 180)
        headerViews.addSubview(userImage)
        headerViews.addSubview(userImageEditButton)
        userImage.frame = CGRect(x: headerViews.center.x - 50, y: 20, width: 100, height: 100)
        userImageEditButton.frame = CGRect(x: headerViews.center.x - 50, y: userImage.bottom + 20, width: 100, height: 40)
        return headerViews
    }
    
    @objc private func didTapDone() {
        setupUserInfo()
    }
    
    @objc private func didTapBack() {
        dismiss(animated: true)
    }
}

extension EditProfileViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return titleLabel.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: EditProfileTableViewCell.identifier, for: indexPath) as? EditProfileTableViewCell else {
            return UITableViewCell()
        }
        cell.index = indexPath
        cell.delegate = self
        cell.selectionStyle = .none
        cell.configure(titleLabel: titleLabel[indexPath.row], userData: userData)
        return cell
    }
    
    func textViewList(text: String ,int: Int) {
        if int == 0 {
            UserDefaults.standard.setValue(text ,forKey: "firstName")
        }
        else if int == 1 {
            UserDefaults.standard.setValue(text ,forKey: "lastName")
        }
        else if int == 2 {
            UserDefaults.standard.setValue(text ,forKey: "phone")
        }
        else if int == 3 {
            UserDefaults.standard.setValue(text ,forKey: "dateOfBirth")
        }
        else if int == 4 {
            UserDefaults.standard.setValue(text ,forKey: "country")
        }
        else if int == 5 {
            UserDefaults.standard.setValue(text ,forKey: "city")
        }
        else if int == 6 {
            UserDefaults.standard.setValue(text ,forKey: "street")
        }
    }
}

extension EditProfileViewController: EditProfileTableViewCellDelegate {
    
    func updateHeightOfRow(_ cell: EditProfileTableViewCell, _ textView: UITextView, index: IndexPath?) {
        textViewList(text: textView.text, int: index?.row ?? 0)
        let size = textView.bounds.size
        let newSize = tableView.sizeThatFits(CGSize(width: size.width, height: CGFloat.greatestFiniteMagnitude))
        
        if size.height != newSize.height {
            UIView.setAnimationsEnabled(false)
            tableView.beginUpdates()
            tableView.endUpdates()
            UIView.setAnimationsEnabled(true)
            if let thisIndexPath = tableView.indexPath(for: cell) {
                tableView.scrollToRow(at: thisIndexPath, at: .bottom, animated: false)
            }
        }
    }
}

extension EditProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let info = info[.editedImage] as? UIImage else { return }
        self.userImage.image = info
        CatchImgurAPI.uploadImage(image: info) { [weak self] urlString in
            DispatchQueue.main.async {
                UserDefaults.standard.setValue(urlString, forKey: "picture")
            }
        }
        dismiss(animated: true)
    }
}
