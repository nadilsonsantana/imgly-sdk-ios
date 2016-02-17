//
//  ImageStore.swift
//  imglyKit
//
//  Created by Carsten Przyluczky on 14/02/16.
//  Copyright © 2016 9elements GmbH. All rights reserved.
//

import UIKit

/**
 The `JSONStore` provides methods to retrieve JSON data from any URL.
 */
@objc(IMGLYImageStoreProtocol) public protocol ImageStoreProtocol {
    /**
     Retrieves JSON data from the specified URL.

     - parameter url:             A valid URL.
     - parameter completionBlock: A completion block.
     */
    func get(url: String, completionBlock: (UIImage?, NSError?) -> Void)
}

/**
 The `JSONStore` class provides methods to retrieve JSON data from any URL.
 It also caches the data due to efficiency.
 */
@objc(IMGLYImageStore) public class ImageStore: NSObject, ImageStoreProtocol {

    /// A shared instance for convenience.
    public static let sharedStore = ImageStore()

    private var store = [String : UIImage?]()

    private func httpGet(request: NSURLRequest!, callback: (NSData?, NSError?) -> Void) {
        let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
        configuration.requestCachePolicy = NSURLRequestCachePolicy.ReloadIgnoringLocalCacheData
        let session  = NSURLSession(configuration: configuration)
        let task = session.dataTaskWithRequest(request) {
            (data, response, error) -> Void in
            callback(data, error)
        }
        task.resume()
    }

    /**
     Retrieves JSON data from the specified URL.

     - parameter url:             A valid URL.
     - parameter completionBlock: A completion block.
     */
    public func get(url: String, completionBlock: (UIImage?, NSError?) -> Void) {
        if let dict = store[url] {
            print("using ", url)
            completionBlock(dict, nil)
        } else {
            startRequest(url, completionBlock: completionBlock)
        }
    }

    private func startRequest(url: String, completionBlock: (UIImage?, NSError?) -> Void) {
        let request = NSMutableURLRequest(URL: NSURL(string: url)!)
        httpGet(request) {
            (data, error) -> Void in
            if error != nil {
                completionBlock(nil, error)
            } else {
                if let data = data {
                    if let image = UIImage(data: data) {
                        self.store[url] = image
                        print("added ", url)
                        completionBlock(image, nil)
                    } else {
                        completionBlock(nil, NSError(info: "No image found at \(url)."))
                    }
                }
            }
        }

    }
}
