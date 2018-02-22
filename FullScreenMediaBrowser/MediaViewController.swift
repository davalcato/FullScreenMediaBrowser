//
//  MediaViewController.swift
//  FullScreenMediaBrowser
//
//  Created by Daval Cato on 3/17/17.
//  Copyright © 2017 Daval Cato. All rights reserved.
//

import UIKit

class MediaViewController: UIViewController, MediaFetcherDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    //MARK: - Property
    @IBOutlet weak var mediaCollectionView: UICollectionView!
    
    var mediaItems: [MediaItem] = []
    lazy var mediaFetcher:MediaFetcher = MediaFetcher(delegate: self)
    var imageCache = NSMutableDictionary()
    lazy var refreshControl: UIRefreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mediaFetcher.fetchPopularPhotos()
        
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor : UIColor.BlueColor()]
        refreshControl.tintColor = UIColor.gray
        refreshControl.addTarget(self, action: #selector(self.refresh), for: .valueChanged)
        mediaCollectionView.alwaysBounceVertical = true
        mediaCollectionView.insertSubview(refreshControl, aboveSubview: mediaCollectionView)
        
        self.extendedLayoutIncludesOpaqueBars = true
        self.navigationController?.navigationBar.alpha = 0
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 19/255, green: 85/255, blue: 135/255, alpha: 1.0)
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.font: UIFont(name: "Billabong", size: 35)!,
            NSAttributedStringKey.foregroundColor: UIColor.white]
    }
    
    override func viewWillAppear(_ animated: Bool) {
        mediaFetcher.delegate = self
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - MediaFetcherDelegate
    func didFetchMediaItems(_ items: NSArray) {
        mediaItems.removeAll(keepingCapacity: true)
        refreshControl.endRefreshing()
        
        for item in items {
            let newItem: MediaItem = MediaItem(item: item as! NSDictionary)
            mediaItems.append(newItem)
        }
        
        DispatchQueue.main.async(execute: {
            self.mediaCollectionView.reloadData()
        })
    }
    
    func didFailToFetchMediaItems(_ error: NSError) {
        print("Failed to download")
    }
    
    //MARK: - UICollectionViewDelegate
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return mediaItems.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let mediaCell = collectionView.dequeueReusableCell(withReuseIdentifier: "MediaCell", for: indexPath) as! MediaCell
        let mediaItem = mediaItems[indexPath.item]
        
        let imgUrlString = mediaItem.thumbnailURL
        let imgURL: URL = URL(string: imgUrlString!)!
        
        var image: UIImage?
        
        getDataFromUrl(url: imgURL) { (data, response, error)  in
            guard let data = data, error == nil else { return }
            print(response?.suggestedFilename ?? imgURL.lastPathComponent)
            DispatchQueue.main.async() { () -> Void in
                image = UIImage(data: data)
                self.animateImage(image!, intoImageView: mediaCell.imageView)
                
            }
        }
        
        if mediaItem.mediaType == "video" {
            mediaCell.videoImageView.isHidden = false
        }
        else {
            mediaCell.videoImageView.isHidden = true
        }
        
        return mediaCell
    }
    
    // MARK: - UICollectionViewFlowLayout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellsAcross: CGFloat = 3
        let spaceBetweenCells: CGFloat = 1
        let dim = (collectionView.bounds.width - (cellsAcross - 1) * spaceBetweenCells) / cellsAcross
        return CGSize(width: dim, height: dim)
    }
    
    //MARK: - Action
    @IBAction func refresh(_ sender: UIBarButtonItem) {
        mediaFetcher.refresh()
    }
    
    //MARK: - Functions
    func animateImage(_ image: UIImage, intoImageView imageView: UIImageView) {
        
        UIView.animate(withDuration: 0.3, animations: {
            imageView.alpha = 0
            imageView.image = image
            imageView.alpha = 1
        })
    }
    
    func getDataFromUrl(url: URL, completion: @escaping (_ data: Data?, _  response: URLResponse?, _ error: Error?) -> Void) {
        URLSession.shared.dataTask(with: url) {
            (data, response, error) in
            completion(data, response, error)
            }.resume()
    }
}
