//
//  Reposatory.swift
//  TestGithubRepos
//
//  Created by macbook on 7/20/19.
//  Copyright © 2019 macbook. All rights reserved.
//

//   let repo = try? newJSONDecoder().decode(Reposatory.self, from: jsonData)

import Foundation

// MARK: - Reposatory
class Reposatory: Codable {
    let id: Int
    let name: String
    let owner: Owner
    let repoDescription: String
    let url: String
    let createdAt: String
    let language: Language?
    let forksCount: Int
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case owner
        case repoDescription = "description"
        case url = "clone_url"
        case createdAt = "created_at"
        case language
        case forksCount = "forks_count"
    } 
}

enum Language: String, Codable {
    case css = "CSS"
    case objectiveC = "Objective-C"
    case ruby = "Ruby"
    case shell = "Shell"
    case swift = "Swift"
}

// MARK: - Owner
struct Owner: Codable {
    let id: Int
    let avatarURL: String
    let url: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case avatarURL = "avatar_url"
        case url
    }
}


