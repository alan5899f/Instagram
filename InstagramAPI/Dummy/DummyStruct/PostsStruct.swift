//
//  PostsStruct.swift
//  PostsStruct
//
//  Created by 陳韋綸 on 2022/5/25.
//

import Foundation

struct PostsStruct: Codable {
    let data: [PostsStructData]
    let total: Int
}

struct PostsStructData: Codable {
    let id: String
    let image: String
    let likes: Int
    let publishDate: String
    let tags: [String]?
    let text: String
    let owner: PostsStructOwner
}

struct PostsStructOwner: Codable {
    let firstName: String
    let id: String
    let lastName: String
    let picture: String
    let title: String
}
