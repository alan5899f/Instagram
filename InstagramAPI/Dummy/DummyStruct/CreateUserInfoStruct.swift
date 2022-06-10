//
//  createUserInfoStruct.swift
//  createUserInfoStruct
//
//  Created by 陳韋綸 on 2022/5/28.
//

import Foundation

struct CreateUserInfoStructData: Codable {
    let title: String
    let firstName: String
    let lastName: String
    let gender: String
    let email: String
    let dateOfBirth: String
    let phone: String
    let picture: String
    let location: CreateUserInfoStructLocation
}

struct CreateUserInfoStructLocation: Codable {
    let street: String
    let city: String
    let state: String
    let country: String
    let timezone: String
}
