//
//  ImagurAPI.swift
//  ImagurAPI
//
//  Created by 陳韋綸 on 2022/5/30.
//

import Alamofire
import UIKit

class CatchImgurAPI {
    
    static func uploadImage(image: UIImage, completion: @escaping (String) -> Void) {
        let headers: HTTPHeaders = [
            "Authorization": "Client-ID 302ff9c41efbbce",
        ]
        AF.upload(multipartFormData: { data in
            let imageData = image.jpegData(compressionQuality: 0.9)
            data.append(imageData!, withName: "image")
        }, to: "https://api.imgur.com/3/image", headers: headers).responseDecodable(of: UploadImageStruct.self, queue: .main, decoder: JSONDecoder()) { response in
            switch response.result {
            case .success(let result):
                let url = result.data.link
                let urlString = url.absoluteString
                completion(urlString)
            case .failure(let error):
                print("error:", error)
            }
        }
    }
}
