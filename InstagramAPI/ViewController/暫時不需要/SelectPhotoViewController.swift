//
//  NewPostViewController.swift
//  NewPostViewController
//
//  Created by 陳韋綸 on 2022/6/7.
//

import UIKit

class SelectPhotoViewController: UIImagePickerController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let barbutton = UIBarButtonItem.appearance()
        barbutton.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.clear], for: .normal)
        barbutton.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.clear], for: .highlighted)
        view.backgroundColor = .white
        sourceType = .photoLibrary
        allowsEditing = true
        delegate = self
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: false)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.editedImage] as? UIImage else {
            return
        }
    }
}
