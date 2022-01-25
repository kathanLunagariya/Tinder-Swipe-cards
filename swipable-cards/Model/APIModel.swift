//
//  APIModel.swift
//  swipable-cards
//
//  Created by Kathan Lunagariya on 24/12/21.
//

import Foundation

struct model:Decodable{
    let results:[Result]
}

struct Result:Decodable{
    let name:Name
    let dob:DOB
    let picture:Pics
    let location:Location
}

struct Name:Decodable{
    let title:String
    let first:String
    let last:String
}

struct DOB:Decodable{
    let age:Int
}

struct Pics:Decodable{
    let large:String
    let medium:String
    let thumbnail:String
}

struct Location:Decodable{
    let city:String
    let country:String
}
