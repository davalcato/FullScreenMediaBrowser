//
//  MediaItem.swift
//  FullScreenMediaBrowser
//
//  Created by Daval Cato on 3/17/17.
//  Copyright © 2017 Daval Cato. All rights reserved.
//

import Foundation

class MediaItem {
    
    var itemID: String?
    var username: String?
    var thumbnailURL: String?
    var mediaType: String?
    var tags: [String]?
    var sourceURL: String?
    var profilePictureURL: String?
    var likes: Int?
    
    init(item: NSDictionary){
        
        itemID = item.value(forKeyPath: "user.id") as? String
        username = item.value(forKeyPath: "user.username") as? String
        thumbnailURL = item.value(forKeyPath: "images.thumbnail.url") as? String
        mediaType = item["type"] as? String
        if mediaType == "image" {
            sourceURL = item.value(forKeyPath: "images.standard_resolution.url") as? String
        } else {
            sourceURL = item.value(forKeyPath: "videos.standard_resolution.url") as? String
        }
        tags = item["tags"] as? [String]
        profilePictureURL = item.value(forKeyPath: "user.profile_picture") as? String
        likes = item.value(forKeyPath: "likes.count") as? Int
        
        NSLog("\(String(describing: username)), \(String(describing: itemID)), \(String(describing: mediaType)), \(String(describing: sourceURL)), \(String(describing: tags)), \(String(describing: likes))")
    }
}
