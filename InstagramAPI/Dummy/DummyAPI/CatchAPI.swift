//
//  CatchAPI.swift
//  CatchAPI
//
//  Created by 陳韋綸 on 2022/5/25.
//

import Foundation

enum CatchAPIError: Error {
    case catchPostError
    case catchCommentError
    case catchUserError
    case catchUserPostsError
    case catchUserListError
    case catchAuthUserList
}

class CatchAPI {
    
    static func catchPost(completion: @escaping (Result<[PostsStructData], Error>) -> Void) {
        let url = URL(string: APIURL.postsURL + "?page=0&limit=21")
        var request = URLRequest(url: url!)
        request.addValue(APIURL.appID, forHTTPHeaderField: "app-id")
        let task = URLSession.shared.dataTask(with: request) { data, _, error in
            guard error == nil,
                  let data = data else {
                      return
                  }
            do {
                let printJSON = try JSONSerialization.jsonObject(with: data, options: .fragmentsAllowed)
//                print(printJSON)
                let result = try JSONDecoder().decode(PostsStruct.self, from: data)
                completion(.success(result.data))
            }
            catch {
                completion(.failure(CatchAPIError.catchPostError))
            }
        }
        task.resume()
    }
    
    static func catchComment(postID: String, completion: @escaping (Result<CommentStruct, Error>) -> Void) {
        let url = URL(string: APIURL.postsURL + "/\(postID)/comment")
        var request = URLRequest(url: url!)
        request.addValue(APIURL.appID, forHTTPHeaderField: "app-id")
        let task = URLSession.shared.dataTask(with: request) { data, _, error in
            guard error == nil,
                  let data = data else {
                      return
                  }
            do {
                let printJSON = try JSONSerialization.jsonObject(with: data, options: .fragmentsAllowed)
//                print(printJSON)
                let result = try JSONDecoder().decode(CommentStruct.self, from: data)
                completion(.success(result))
            }
            catch {
                completion(.failure(CatchAPIError.catchCommentError))
            }
        }
        task.resume()
    }
    
    static func catchUserInfo(userID: String, completion: @escaping (Result<UserInfoStruct, Error>) -> Void) {
        let url = URL(string: APIURL.userURL + "/\(userID)")
        var request = URLRequest(url: url!)
        request.addValue(APIURL.appID, forHTTPHeaderField: "app-id")
        let task = URLSession.shared.dataTask(with: request) { data, _, error in
            guard error == nil,
                  let data = data else {
                      return
                  }
            do {
                let printJSON = try JSONSerialization.jsonObject(with: data, options: .fragmentsAllowed)
//                print(printJSON)
                let result = try JSONDecoder().decode(UserInfoStruct.self, from: data)
                completion(.success(result))
            }
            catch {
                completion(.failure(CatchAPIError.catchUserError))
            }
        }
        task.resume()
    }
    
    static func catchUserPosts(userID: String, completion: @escaping (Result<PostsStruct, Error>) -> Void) {
        let url = URL(string: APIURL.userURL + "/\(userID)/post")
        var request = URLRequest(url: url!)
        request.addValue(APIURL.appID, forHTTPHeaderField: "app-id")
        let task = URLSession.shared.dataTask(with: request) { data, _, error in
            guard error == nil,
                  let data = data else {
                      return
                  }
            do {
                let printJSON = try JSONSerialization.jsonObject(with: data, options: .fragmentsAllowed)
//                print(printJSON)
                let result = try JSONDecoder().decode(PostsStruct.self, from: data)
                completion(.success(result))
            }
            catch {
                completion(.failure(CatchAPIError.catchUserPostsError))
            }
        }
        task.resume()
    }
    
    static func catchUserList(completion: @escaping (Result<UserListStruct, Error>) -> Void) {
        let url = URL(string: APIURL.userURL + "?page=3&limit=20")
        var request = URLRequest(url: url!)
        request.addValue(APIURL.appID, forHTTPHeaderField: "app-id")
        let task = URLSession.shared.dataTask(with: request) { data, _, error in
            guard error == nil,
                  let data = data else {
                      return
                  }
            do {
                let printJSON = try JSONSerialization.jsonObject(with: data, options: .fragmentsAllowed)
//                print(printJSON)
                let result = try JSONDecoder().decode(UserListStruct.self, from: data)
                completion(.success(result))
                print("使用者列表: ",result)
            }
            catch {
                completion(.failure(CatchAPIError.catchUserListError))
            }
        }
        task.resume()
    }
    
    static func catchAuthUserList(completion: @escaping (Result<UserListStruct, Error>) -> Void) {
        let url = URL(string: APIURL.userURL + "?created=1")
        var request = URLRequest(url: url!)
        request.addValue(APIURL.appID, forHTTPHeaderField: "app-id")
        let task = URLSession.shared.dataTask(with: request) { data, _, error in
            guard error == nil,
                  let data = data else {
                      return
                  }
            do {
                let printJSON = try JSONSerialization.jsonObject(with: data, options: .fragmentsAllowed)
//                print(printJSON)
                let result = try JSONDecoder().decode(UserListStruct.self, from: data)
                completion(.success(result))
            }
            catch {
                completion(.failure(CatchAPIError.catchAuthUserList))
            }
        }
        task.resume()
    }
}
