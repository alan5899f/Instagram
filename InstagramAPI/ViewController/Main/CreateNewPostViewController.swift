//
//  CreatePostViewController.swift
//  CreatePostViewController
//
//  Created by 陳韋綸 on 2022/5/29.
//

import UIKit
import PKHUD
import AssetsLibrary

class CreateNewPostViewController: UIViewController {

    private let postTextView: UITextView = {
        let textView = UITextView()
        textView.sizeToFit()
        textView.textColor = .black
        textView.isScrollEnabled = false
        textView.font = .systemFont(ofSize: 16)
        textView.layer.masksToBounds = true
        textView.backgroundColor = .systemGray3
        return textView
    }()
    
    private let postImage = UIImageView().customModel(contentMode: .scaleAspectFill)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        self.navigationItem.title = "投稿"
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "送出", style: .done, target: self, action: #selector(didTapPosted))
        setupLayout()
        setupBinding()
    }
    
    private func setupBinding() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapImage))
        postImage.addGestureRecognizer(tap)
    }
    
    @objc private func didTapImage() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        picker.sourceType = .photoLibrary
        present(picker, animated: true) 
    }
    
    private func setupLayout() {
        postImage.isUserInteractionEnabled = true
        
        view.addSubview(postTextView)
        view.addSubview(postImage)
        postImage.image = UIImage(named: "noImage")
        postImage.tintColor = .black
        postImage.layer.borderWidth = 1
        postImage.layer.borderColor = UIColor.systemGray3.cgColor
        
        postImage.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, width: 100, height: 100, topPadding: 20, leftPadding: 20)
        postTextView.anchor(top: postImage.topAnchor, left: postImage.rightAnchor, right: view.rightAnchor, leftPadding: 10, rightPadding: 30)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    @objc private func didTapPosted() {
        guard let text = postTextView.text,
              let image = postImage.image,
              image != UIImage(named: "noImage"),
              !text.isEmpty else {
                  let alert = UIAlertController(title: "照片與欄位不得為空", message: "", preferredStyle: .alert)
                  alert.addAction(UIAlertAction(title: "確定", style: .cancel, handler: nil))
                  present(alert, animated: true, completion: nil)
                  return
              }
        HUD.show(.customView(view: LottieAnimation(frame: CGRect(x: 0, y: 0, width: view.width/3, height: view.width/3))), onView: view)
        CatchImgurAPI.uploadImage(image: image) { [weak self] imageUrl in
                PostAPI.createUserPost(text: text, image: imageUrl, tags: ["spy","ania"]) { [weak self] result in
                    DispatchQueue.main.async {
                        switch result {
                        case .success(_):
                            HUD.hide()
                            self?.postTextView.text = ""
                            self?.postImage.image = nil
                            print("成功po文")
                        case .failure(let error):
                            HUD.hide()
                            self?.postTextView.text = ""
                            self?.postImage.image = nil
                            print("po文失敗原因: ", error)
                        }
                    }
                }
        }
    }
}

extension CreateNewPostViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.editedImage] as? UIImage else {
            print("imageInfoError")
            return
        }
        postImage.image = image
        dismiss(animated: true, completion: nil)
    }
}
