//
//  Models.swift
//  sample01
//
//  Created by makoto sakamaki on 2022/02/01.
//

import Foundation

struct Category:Codable {
    let id:Int?
    let name:String?
    let created_at:String?
    let updated_at:String?
}

struct Item:Codable {
    let id:Int?
    let name:String?
    let price:Int?
    let category_id:Int?
    let image_path:String?
    let created_at:String?
    let updated_ad:String?
}

struct Customer:Codable {
    let id:Int?
    let name:String?
    let mail:String?
    let password:String?
    let created_at:String?
    let updated_at:String?
}
