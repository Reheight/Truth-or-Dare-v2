//
//  truthsViewController.swift
//  truthordare
//
//  Created by Palmatier, Dustin on 10/30/19.
//  Copyright © 2019 Hexham Network. All rights reserved.
//

import UIKit

class truthsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, MessageModelProtocol {
    @IBOutlet weak var listTableView: UITableView!
    
    var identifier = ""
    var displayName = ""
    var bitmojiLink = ""
    
    
    var feedItems: NSArray = NSArray()
    var selectedTable : TableModel = TableModel()
    @IBOutlet weak var labelText: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = ""
        // Do any additional setup after loading the view.
        self.listTableView.delegate = self
        self.listTableView.dataSource = self
        
        listTableView.rowHeight = UITableView.automaticDimension
        listTableView.estimatedRowHeight = UITableView.automaticDimension
        
        let messageModel = MessageModel()
        messageModel.delegate = self
        messageModel.downloadItems(TYPE: "truth", IDENTIFIER: identifier)
        labelText.layer.cornerRadius = 10
        labelText.clipsToBounds = true
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return UITableView.automaticDimension
        } else {
            return 40
        }
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return UITableView.automaticDimension
        } else {
            return 40
        }
    }
    
    func itemsDownloaded(items: NSArray) {
        
        feedItems = items
        self.listTableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Return the number of feed items
        return feedItems.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let myCell = tableView.dequeueReusableCell(withIdentifier: "BasicCell", for: indexPath) as! TableViewCell
        // Get the location to be shown
        let item: TableModel = feedItems[indexPath.row] as! TableModel
        // Get references to labels of cell
        myCell.messageLabel?.text = item.message
        myCell.messageLabel?.numberOfLines = 0
        myCell.messageLabel?.lineBreakMode = .byWordWrapping
        myCell.idLabel?.text = item.sku
        myCell.idLabel?.isHidden = true
        return myCell
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]?
    {
        let shareAction = UITableViewRowAction(style: .normal, title: "Share" , handler: { (action:UITableViewRowAction, indexPath: IndexPath) -> Void in
            
        })
        let deleteAction = UITableViewRowAction(style: .destructive, title: "Delete" , handler: { (action:UITableViewRowAction, indexPath: IndexPath) -> Void in
            let myCell = tableView.cellForRow(at: indexPath) as! TableViewCell
            
            let sku = myCell.idLabel
            
            let messageModel = MessageModel()
            messageModel.deleteItems(TYPE: "truth", SKU: (sku?.text)!)
            
            DispatchQueue.main.async {
                let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                let referredStoryboard = storyBoard.instantiateViewController(withIdentifier: "truthsView") as! truthsViewController
                
                referredStoryboard.bitmojiLink = self.bitmojiLink
                referredStoryboard.displayName = self.displayName
                referredStoryboard.identifier = self.identifier
                
                self.present(referredStoryboard, animated: false, completion: nil)
            }
        })
        
        return [deleteAction, shareAction]
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
