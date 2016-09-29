//
//  FlickerImageProvider.swift
//  Lexis
//
//  Created by Wellington Moreno on 9/25/16.
//  Copyright © 2016 RedRoma, Inc. All rights reserved.
//

import AromaSwiftClient
import Foundation
import LexisDatabase
import Sulcus


fileprivate class Flickr
{
    static let api = "https://api.flickr.com/services/rest/"
    static let apiKey = "e904f6fd166f683b7e41a95949d9fc42"
    static let apiSignature = ""
    
    static let searchAPI = api + "?method=flickr.photos.search&format=json&nojsoncallback=1&api_key=\(apiKey)&sort=interestingness-desc&media=photos"
    
    static func createURLSearching(text: String) -> URL?
    {
        let link = searchAPI + "&text=\(text)"
        
        return link.asUrl
    }
}

class FlickrImageProvider: ImageProvider
{
    func searchForImages(withTerm searchTerm: String) -> [URL]
    {
        return searchFlickrForImages(withTerm: searchTerm).flatMap() { $0.imageURL }
    }
    
    func searchFlickrForImages(withWord word: LexisWord) -> [FlickrImage]
    {
        guard let wordName = word.forms.first else { return [] }
        
        return searchFlickrForImages(withTerm: wordName)
    }
    
    func searchFlickrForImages(withTerm searchTerm: String) -> [FlickrImage]
    {
        guard searchTerm.notEmpty else { return [] }
        
        let searchURL = Flickr.createURLSearching(text: searchTerm)
        LOG.info("Searching URL: \(searchURL)")
        
        guard let searchResultsString = searchURL?.downloadToString()
        else
        {
            return []
        }
        
        guard let searchResultsJSON = searchResultsString.asJSONDictionary() else { return [] }
        guard let searchResults = SearchResults.init(fromJSON: searchResultsJSON) else { return [] }
        
        LOG.info("Found \(searchResults.totalImages) images searching for \(searchTerm)")
        
        return searchResults.photos
    }
}



class FlickrImage
{
    let id: String
    let owner: String
    let secret: String
    let server: String
    let farm: Int
    let title: String
    let isPublic: Bool
    
    
    init(id: String, owner: String, secret: String, server: String, farm: Int, title: String, isPublic: Bool)
    {
        self.id = id
        self.owner = owner
        self.secret = secret
        self.server = server
        self.farm = farm
        self.title = title
        self.isPublic = isPublic
    }
    
    convenience init?(fromJSON json: NSDictionary)
    {
        guard
        let id = json[Keys.id] as? String,
        let owner = json[Keys.owner] as? String,
        let secret = json[Keys.secret] as? String,
        let server = json[Keys.server] as? String,
        let farm = json[Keys.farm] as? Int,
        let title = json[Keys.title] as? String,
        let isPublicNumber = json[Keys.isPublic] as? Int
        else
        {
            LOG.warn("Could not extract SearchResult from JSON")
            return nil
        }
        
        let isPublic = isPublicNumber == 1
        
        self.init(id: id, owner: owner, secret: secret, server: server, farm: farm, title: title, isPublic: isPublic)
    }
    
    var imageURL: URL?
    {
        let link = "https://farm\(farm).staticflickr.com/\(server)/\(id)_\(secret).jpg"
        
        return link.asUrl
    }
    
    var webURL: URL?
    {
        let link = "https://www.flickr.com/photos/\(owner)/\(id)"
        
        return link.asUrl
    }
 
    private class Keys
    {
        static let id = "id"
        static let owner = "owner"
        static let secret = "secret"
        static let server = "server"
        static let farm = "farm"
        static let title = "title"
        static let isPublic = "ispublic"
    }
    
}

class SearchResults
{
    let status: String
    let page: Int
    let totalPages: Int
    let imagesPerPage: Int
    let totalImages: Int
    let photos: [FlickrImage]
    
    init(status: String, page: Int, totalPages: Int, imagesPerPage: Int, totalImages: Int, photos: [FlickrImage])
    {
        self.status = status
        self.page = page
        self.totalPages = totalPages
        self.imagesPerPage = imagesPerPage
        self.totalImages = totalImages
        self.photos = photos
    }
    
    convenience init?(fromJSON json: NSDictionary)
    {
        guard let status = json[Keys.status] as? String else { return nil }
        guard let results = json[Keys.innerResults] as? NSDictionary else { return nil }
        
        guard let page = results[Keys.page] as? Int,
        let totalPages = results[Keys.totalPages] as? Int,
        let imagesPerPage = results[Keys.imagesPerPage] as? Int,
        let totalImagesString = results[Keys.totalImages] as? String,
        let totalImages = Int(totalImagesString),
        let photosArray = results[Keys.photos] as? NSArray
        else
        {
            LOG.error("Failed to parse JSON: \(results)")
            return nil
        }
        
        let photos = photosArray
            .flatMap() { $0 as? NSDictionary }
            .flatMap(FlickrImage.init)
        
        LOG.info("Parsed \(photos.count) images")
        
        self.init(status: status, page: page, totalPages: totalPages, imagesPerPage: imagesPerPage, totalImages: totalImages, photos: photos)
    }
    
    private class Keys
    {
        static let page = "page"
        static let status = "stat"
        static let totalPages = "pages"
        static let imagesPerPage = "perpage"
        static let totalImages = "total"
        static let photos = "photo"
        static let innerResults = "photos"
    }
}
