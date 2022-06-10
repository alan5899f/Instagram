//
//  CatchImageUrlStruct.swift
//  CatchImageUrlStruct
//
//  Created by 陳韋綸 on 2022/5/30.
//

import Foundation

struct UploadImageStruct: Codable {
    struct Data: Codable {
        let link: URL
    }
    let data: Data
}
