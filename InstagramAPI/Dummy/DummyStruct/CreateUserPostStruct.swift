//
//  CreateUserPostStruct.swift
//  CreateUserPostStruct
//
//  Created by 陳韋綸 on 2022/5/29.
//

import Foundation

struct CreateUserPostStruct: Codable {
    let text: String
    let image: String
    let likes: Int
    let tags: [String]
    let owner: String
}
