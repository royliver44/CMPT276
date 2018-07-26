//
//  DisplayTableViewController.swift
//  FoodForThought
//
//  Created by Russell Wong on 2018-07-17.
//  Copyright © 2018 Food For Thought All rights reserved.
//


import UIKit
import CoreData
import Foundation

class DisplayTableViewController: UITableViewController, UISearchBarDelegate {
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var items: [Item] = []
    var selectedIndex: Int!
    
    var filteredData: [Item] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        createSearchBar()
        // Creates a search bar to allow users to search through journal entries
        self.tableView.estimatedRowHeight = 10
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.navigationController?.isNavigationBarHidden = false
        self.navigationItem.hidesBackButton = true
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = false
        fetchData()
    }
    
    // Fetches Core Data
    func fetchData() {
        
        do {
            items = try context.fetch(Item.fetchRequest())
            filteredData = items

//            for each in filteredData {
//                self.context.delete(each)
//                (UIApplication.shared.delegate as! AppDelegate).saveContext()
//            }
//            filteredData.removeAll()
           
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        } catch {
            print("Couldn't Fetch Data")
        }
        
    }
    
}


extension DisplayTableViewController {
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "JournalTableViewCell", for: indexPath) as! JournalTableViewCell
        print(filteredData[indexPath.row].name!)
        if filteredData[indexPath.row].entryText == "Shit" {
            print(filteredData[indexPath.row].entryText!)
            
        }
        
        cell.entryTitle.text = filteredData[indexPath.row].name
        cell.entryDate.text = filteredData[indexPath.row].date!
        cell.entryText.text = filteredData[indexPath.row].entryText!
        
        
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredData.count
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        selectedIndex = indexPath.row
        
        performSegue(withIdentifier: "UpdateVC", sender: self)
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        // Allows users to delete journal entries,
        // This is accessed through swiping left over a journal entry
        let delete = UITableViewRowAction(style: .default, title: "Delete") { (action, indexPath) in
            // delete item at indexPath
            
            let item = self.filteredData[indexPath.row]
            self.context.delete(item)
            (UIApplication.shared.delegate as! AppDelegate).saveContext()
            
            self.filteredData.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            
        }
        
        // Allows users to share journal entries to social media
        // Social media not yet implemented
        let share = UITableViewRowAction(style: .default, title: "Share") { (action, indexPath) in
            // delete item at indexPath
            
            print("Share")
            
        }
        // Creates the the icons for share and delete when a user swipes left over an entry
        delete.backgroundColor = UIColor(red: 0/255, green: 177/255, blue: 106/255, alpha: 1.0)
        share.backgroundColor = UIColor(red: 54/255, green: 215/255, blue: 183/255, alpha: 1.0)
        
        
        return [delete,share]
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "UpdateVC" {
            let updateVC = segue.destination as! UpdateItemViewController
            updateVC.item = filteredData[selectedIndex!]
        }
    }
    
    
    // Creates a search bar in application for users to search through journal entries
    
    func createSearchBar() {
        
        let searchBar = UISearchBar()
        searchBar.showsCancelButton = false
        searchBar.placeholder = "Search"
        searchBar.delegate = self
        
        self.navigationItem.titleView = searchBar
        
    }
    
    // This method updates filteredData based on the text in the Search Box
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        // Checks for journal entries with similar text
        if searchText.isEmpty {
            filteredData = items
            
        } else {
            
            filteredData = items.filter { ($0.name?.lowercased().contains(searchText.lowercased()))! }
            
        }
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
        
    }
    
}
