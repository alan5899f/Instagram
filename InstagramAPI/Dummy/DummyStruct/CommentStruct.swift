//
//  CommentStruct.swift
//  CommentStruct
//
//  Created by 陳韋綸 on 2022/5/25.
//

import Foundation

struct CommentStruct: Codable {
    let data: [CommentStructData]?
    let total: Int
}

struct CommentStructData: Codable {
    let id: String
    let message: String
    let owner: CommentStructOwner
    let post: String
    let publishDate: String
}

struct CommentStructOwner: Codable {
    let firstName: String
    let id: String
    let lastName: String
    let picture: String
    let title: String
}
