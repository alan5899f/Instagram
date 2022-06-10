//
//  PostAPI.swift
//  PostAPI
//
//  Created by 陳韋綸 on 2022/5/27.
//

import UIKit


enum PostAPIError: Error {
    case reviseUserInfoError
    case createUserInfoError
    case createUserPostError
}

class PostAPI {
    
    static func uploadUserInfo(firstName: String, lastName: String, dateOfBirth: String, phone: String, street: String, city: String, country: String, pictureUrl: String, completion: @escaping (Bool) -> Void) {
        guard let userID = UserDefaults.standard.string(forKey: "userID") else {
            completion(false)
            return
        }
        let url = URL(string: APIURL.userURL + "/\(userID)")
        var request = URLRequest(url: url!)
        request.httpMethod = "PUT"
        request.addValue(APIURL.appID, forHTTPHeaderField: "app-id")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let encoder = JSONEncoder()
        let user = UploadUserInfoStructData(
            firstName: firstName, lastName: lastName, dateOfBirth: dateOfBirth, phone: phone, picture: pictureUrl,
            location: UploadUserInfoStructLocation(
                street: street, city: city, country: country))
        
        let data = try? encoder.encode(user)
        request.httpBody = data

        URLSession.shared.dataTask(with: request) { data, response, error in
            guard error == nil else {
                completion(false)
                return
            }
            
            if let data = data, let content = String(data: data, encoding: .utf8) {
                print("result:", content)
                completion(true)
            }
        }.resume()
    }
    
    static func createUserInfo(email: String, firstName: String, lastName: String, gender: String, phone: String, picture: String, dateOfBirth: String, street: String?, city: String?, state: String?, country: String?, timezone: String?, completion: @escaping (Bool) -> Void) {
        let url = URL(string: APIURL.createURL)
        var request = URLRequest(url: url!)
        request.httpMethod = "POST"
        request.addValue(APIURL.appID, forHTTPHeaderField: "app-id")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let encoder = JSONEncoder()
        print(dateOfBirth)
        let user = CreateUserInfoStructData(
            title: "mr", firstName: firstName, lastName: lastName, gender: gender, email: email, dateOfBirth: dateOfBirth, phone: phone, picture: picture,
            location: CreateUserInfoStructLocation(
                street: street ?? "", city: city ?? "", state: state ?? "", country: country ?? "", timezone: timezone ?? ""))
        let data = try? encoder.encode(user)
        request.httpBody = data

        URLSession.shared.dataTask(with: request) { data, response, error in
            guard error == nil,
                  let data = data else {
                      completion(false)
                return
            }
            do {
                let result = try JSONDecoder().decode(UserInfoStruct.self, from: data)
                print("result: ", result)
                completion(true)
            }
            catch {
                print("error: ", error)
                completion(false)
            }
        }.resume()
    }
    
    static func createUserPost(text: String, image: String, tags: [String], completion: @escaping (Result<Bool, Error>) -> Void) {
        guard let selfUserID = UserDefaults.standard.string(forKey: "userID") else {
            return
        }
        
        let url = URL(string: APIURL.createPost)
        var request = URLRequest(url: url!)
        request.httpMethod = "POST"
        request.addValue(APIURL.appID, forHTTPHeaderField: "app-id")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let encoder = JSONEncoder()
        let user = CreateUserPostStruct(text: text, image: image, likes: 0, tags: tags, owner: selfUserID)
        let data = try? encoder.encode(user)
        request.httpBody = data

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data, let content = String(data: data, encoding: .utf8) {
                if content.contains("error") {
                    completion(.failure(PostAPIError.createUserPostError))
                } else {
                    completion(.success(true))
                }
            }
        }.resume()
    }
    
    static func deleteUserPost(postID: String) {
        let url = URL(string: APIURL.postsURL + "/\(postID)")
        var request = URLRequest(url: url!)
        request.httpMethod = "delete"
        request.addValue(APIURL.appID, forHTTPHeaderField: "app-id")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let encoder = JSONEncoder()
        let user = DeleteUserPostStruct(id: postID)
        let data = try? encoder.encode(user)
        request.httpBody = data

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data, let content = String(data: data, encoding: .utf8) {
                print("content: ", content)
            }
        }.resume()
    }
    
    static func uploadUserPost(postID: String, likes: Int) {
        let url = URL(string: APIURL.postsURL + "/\(postID)")
        var request = URLRequest(url: url!)
        request.httpMethod = "PUT"
        request.addValue(APIURL.appID, forHTTPHeaderField: "app-id")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let encoder = JSONEncoder()
        let user = UploadUserPostStruct(likes: likes + 1)
        let data = try? encoder.encode(user)
        request.httpBody = data

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data, let content = String(data: data, encoding: .utf8) {
                print("content: ", content)
            }
        }.resume()
    }

    static func createPostComment(postID: String, message: String, completion: @escaping (Bool) -> Void) {
        guard let userID = UserDefaults.standard.string(forKey: "userID") else {
            completion(false)
            return
        }
        let url = URL(string: APIURL.createComment)
        var request = URLRequest(url: url!)
        request.httpMethod = "POST"
        request.addValue(APIURL.appID, forHTTPHeaderField: "app-id")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let encoder = JSONEncoder()
        let user = CreatePostCommentStruct(message: message, owner: userID, post: postID)
        let data = try? encoder.encode(user)
        request.httpBody = data
        
        URLSession.shared.dataTask(with: request) { data, respone, error in
            guard error == nil else {
                completion(false)
                return
            }
            if let data = data, let content = String(data: data, encoding: .utf8) {
                print("content: ", content)
                completion(true)
            }
        }.resume()
    }
}

