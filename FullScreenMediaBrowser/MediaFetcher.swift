//
//  MediaFetcher.swift
//  FullScreenMediaBrowser
//
//  Created by Daval Cato on 3/17/17.
//  Copyright © 2017 Daval Cato. All rights reserved.
//

import UIKit

@objc protocol MediaFetcherDelegate {
    @objc optional func didFetchMediaItems(_ items: NSArray)
    @objc optional func didFailToFetchMediaItems(_ error: NSError)
    @objc optional func didFetchImage(_ image: UIImage, tag: String)
    @objc optional func didFailToFetchImage(_ error: NSError)
}

class MediaFetcher {
    
    let baseURL = "https://api.instagram.com/v1/users/self/"
    let popularEndpoint = "media/recent/"
    let access_token = "1907538394.a160293.dc2dcaa3d86f4d82a9b1d902bc5220eb"
    
    var lastSearchURL: String?
    
    var delegate: MediaFetcherDelegate?
    
    init(delegate:MediaFetcherDelegate) {
        self.delegate = delegate
    }
    
    func get(_ path: String) {
        
        let url = URL(string: path)
        let request = NSMutableURLRequest(url:url!);
        request.httpMethod = "GET";
        
        lastSearchURL = path
        
        let task = URLSession.shared.dataTask(with: request as URLRequest) {
            data, response, error in
            
            if error != nil {
                print(error!.localizedDescription)
                self.delegate?.didFailToFetchMediaItems?(error! as NSError)
                return
            }
            
            do {
                
                let json = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as? NSDictionary
                
                if json == nil {
                    let results: NSArray = json!["data"] as! NSArray
                    self.delegate?.didFetchMediaItems?(results)
                }
            }
            catch {
                print(error)
            }
        }
        
        task.resume()
    }
    
    func fetchPopularPhotos() {
        get("\(baseURL)\(popularEndpoint)?access_token=\(access_token)")
    }
    
    func refresh() {
        if let url = lastSearchURL {
            get(url)
        }
    }
    
    
    
}
