//
//  CreatePostCommentStruct.swift
//  CreatePostCommentStruct
//
//  Created by 陳韋綸 on 2022/6/1.
//

import Foundation

struct CreatePostCommentStruct: Codable {
    let message: String
    let owner: String
    let post: String
}
