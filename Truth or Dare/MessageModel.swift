//
//  MessageModel.swift
//  truthordare
//
//  Created by Dustin Palmatier on 11/2/19.
//  Copyright © 2019 Hexham Network. All rights reserved.
//

import UIKit

protocol MessageModelProtocol: class {
    func itemsDownloaded(items: NSArray)
}

class MessageModel: NSObject, URLSessionDataDelegate {
    //properties
    
    weak var delegate: MessageModelProtocol!
    
    let urlPath = "https://truthordare.hexhamnetwork.com/api/92fFDd93D/retrieve.php" //this will be changed to the path where service.php lives
    
    let deleteUrl = "https://truthordare.hexhamnetwork.com/api/92fFDd93D/erase.php"
    
    func downloadItems(TYPE: String, IDENTIFIER: String) {
        let url: URL = URL(string: urlPath)!
        
        var request = URLRequest(url: url)
        
        request.httpMethod = "POST"
        let postString = "type=\(TYPE)&identifier=\(IDENTIFIER)";
        request.httpBody = postString.data(using: String.Encoding.utf8);
        
        let defaultSession = Foundation.URLSession(configuration: URLSessionConfiguration.default)
        
        let task = defaultSession.dataTask(with: request) { (data: Data?, response: URLResponse?, error: Error?) in
            
            if error != nil {
                print("Failed to download data")
            }else {
                print("Data downloaded")
                self.parseJSON(data!)
            }
            
        }
        
        task.resume()
    }
    
    func deleteItems(TYPE: String, SKU: String) {
        let myUrl = URL(string: "https://truthordare.hexhamnetwork.com/api/92fFDd93D/erase.php");
        
        var request = URLRequest(url:myUrl!)
        
        request.httpMethod = "POST"// Compose a query string
        
        let postString = "type=\(TYPE)&sku=\(SKU)";
        
        request.httpBody = postString.data(using: String.Encoding.utf8);
        
        let task = URLSession.shared.dataTask(with: request) { (data: Data?, response: URLResponse?, error: Error?) in
            
            if error != nil
            {
                print("error=\(error ?? "Empty" as! Error)")
                return
            }
        }
        task.resume()
    }
    
    func parseJSON(_ data:Data) {
        
        var jsonResult = NSArray()
        
        do{
            jsonResult = try JSONSerialization.jsonObject(with: data, options: [.allowFragments, .mutableContainers]) as! NSArray
            
        } catch let error as NSError {
            print(error)
            
        }
        
        var jsonElement = NSDictionary()
        let tables = NSMutableArray()
        
        for i in 0 ..< jsonResult.count
        {
            
            jsonElement = jsonResult[i] as! NSDictionary
            
            let table = TableModel()
            
            //the following insures none of the JsonElement values are nil through optional binding
            if let sku = jsonElement["SKU"] as? String,
                let message = jsonElement["MESSAGE"] as? String
            {
                
                table.sku = sku
                table.message = message
                
            }
            
            tables.add(table)
            
        }
        
        DispatchQueue.main.async(execute: { () -> Void in
            
            self.delegate.itemsDownloaded(items: tables)
            
        })
    }
}
