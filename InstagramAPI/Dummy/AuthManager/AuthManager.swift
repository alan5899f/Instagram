//
//  AuthManager.swift
//  AuthManager
//
//  Created by 陳韋綸 on 2022/5/30.
//

import Foundation

class AuthManager {
    
    static func authSignIn(userEmail: String, phoneNumber: String, completion: @escaping (Bool) -> Void) {
        
            CatchAPI.catchAuthUserList { result in
                switch result {
                case .success(let data):
                    let userListData = data.data
                    
                    userListData.forEach { userData in
                        let userID = userData.id
                        CatchAPI.catchUserInfo(userID: userID) { results in
                            switch results {
                            case .success(let datas):
                                let email = datas.email
                                if userEmail.contains(email) {
                                    if phoneNumber.contains(datas.phone) {
                                        UserDefaults.standard.setValue(datas.id, forKey: "userID")
                                        UserDefaults.standard.setValue(datas.firstName+datas.lastName, forKey: "username")
                                        completion(true)
                                    }
                                    else {
                                        print("手機錯誤")
                                        completion(false)
                                    }
                                }
                                else {
                                    completion(false)
                                    print("沒帳戶")
                                }
                            case .failure(let error):
                                completion(false)
                                print(error)
                            }
                        }
                    }
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
        }
}
