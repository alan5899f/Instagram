//
//  UserListStruct.swift
//  UserListStruct
//
//  Created by 陳韋綸 on 2022/5/26.
//

import Foundation

struct UserListStruct: Codable {
    var data: [UserListStructData]
}

struct UserListStructData: Codable {
    let firstName: String
    let id: String
    let lastName: String
    let picture: String
    let title: String
}
