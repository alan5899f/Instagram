//
//  UserStruct.swift
//  UserStruct
//
//  Created by 陳韋綸 on 2022/5/25.
//

import Foundation

struct UserInfoStruct: Codable {
    let dateOfBirth: String
    let email: String
    let firstName: String
    let gender: String
    let id: String
    let lastName: String
    let phone: String
    let picture: String
    let registerDate: String
    let title: String
    let updatedDate: String
    let location: UserStructLocation
}

struct UserStructLocation: Codable {
    let city: String
    let country: String
    let state: String?
    let street: String
    let timezone: String?
}
