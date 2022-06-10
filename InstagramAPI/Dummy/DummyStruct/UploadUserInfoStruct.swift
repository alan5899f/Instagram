//
//  ReviseUserInfoStruct.swift
//  ReviseUserInfoStruct
//
//  Created by 陳韋綸 on 2022/5/27.
//

import Foundation

struct UploadUserInfoStruct: Codable {
    let data: [UploadUserInfoStructData]
}

struct UploadUserInfoStructData: Codable {
    let firstName: String
    let lastName: String
    let dateOfBirth: String
    let phone: String
    let picture: String
    let location: UploadUserInfoStructLocation
}

struct UploadUserInfoStructLocation: Codable {
    let street: String
    let city: String
    let country: String
}
