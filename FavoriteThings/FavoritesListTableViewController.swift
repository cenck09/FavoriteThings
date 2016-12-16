//
//  ViewController.swift
//  FavoriteThings
//
//  Created by chris on 11/6/16.
//  Copyright © 2016 chris. All rights reserved.
//

import UIKit
import CoreData


class FavoritesListTableViewController:  UITableViewController {

    static let FAVORITESLIST_CELL_REUSE_IDENTIFIER = "FavoritesListCell"
    static let FAVORITESLIST_REFRESH_DATA_IDENTIFIER : NSNotification.Name = NSNotification.Name(rawValue: "RefreshListTableView")
    static let FAVORITESLIST_ADD_DATA_WITH_NAME_IDENTIFIER : NSNotification.Name = NSNotification.Name(rawValue: "AddNewFavoriteList")

    lazy var fetchedLists : [FavoritesList] = []
    
    var notificationObserverRefreshData: Any?
    var notificationObserverAddData: Any?
  
    
    func refetch(){
        do {
            self.fetchedLists = try (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext.fetch(FavoritesList.fetchRequest()) as! [FavoritesList]
        } catch {
            fatalError("Failed to fetch Lists: \(error)")
        }
        
        self.tableView.reloadData()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
       refetch()
        
        notificationObserverRefreshData = (  NotificationCenter.default ).addObserver(forName: FavoritesListTableViewController.FAVORITESLIST_REFRESH_DATA_IDENTIFIER, object: nil, queue: OperationQueue.main) { notification in
            
            self.refetch()
        }
        
        
        notificationObserverAddData = (  NotificationCenter.default ).addObserver(forName: FavoritesListTableViewController.FAVORITESLIST_ADD_DATA_WITH_NAME_IDENTIFIER, object: addListAlert, queue: OperationQueue.main) { notification in
            
            self.createNewFavoriteListWith(name: (notification.userInfo?.first)?.value as! String)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated);
        NotificationCenter.default.removeObserver(notificationObserverRefreshData!)
        NotificationCenter.default.removeObserver(notificationObserverAddData!)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    // MARK - The TableView Methods
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
           return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        let list = fetchedLists[indexPath.row]
 
        let listFavs = list.favorites!
        list.removeFromFavorites(listFavs)
        (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext.delete(list)
        
        (UIApplication.shared.delegate as! AppDelegate).saveContext()
        
        refetch()
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return fetchedLists.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80.0
    }


    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let favoriteList : FavoritesList = fetchedLists[indexPath.row]
        
        let favoritesTable : FavoritesTableViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: FavoritesTableViewController.FAVORITES_STORYBOARD_ID) as! FavoritesTableViewController
        
        favoritesTable.parentList = favoriteList
        
        self.navigationController?.pushViewController(favoritesTable, animated: true)

    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        let cell : UITableViewCell = {
            let nCell = tableView.dequeueReusableCell(withIdentifier: FavoritesListTableViewController.FAVORITESLIST_CELL_REUSE_IDENTIFIER)
            if nCell != nil {
                return nCell!
            }
            return UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: FavoritesListTableViewController.FAVORITESLIST_CELL_REUSE_IDENTIFIER)
        }()
        
        cell.textLabel?.text = fetchedLists[indexPath.row].title
        cell.textLabel?.textAlignment = .center
        return cell;
    }

    
    @IBAction func displayAddListPrompt(_ sender: UIBarButtonItem) {
        present(addListAlert, animated: true, completion: nil)
    }
    
    
    // The Alert View Controller to handel input validation & creating the managed object to save
    
    let addListAlert : UIAlertController = {
        
       let alertView = UIAlertController(title: "Add List :", message: nil, preferredStyle: UIAlertControllerStyle.alert)
       
        alertView.addTextField(configurationHandler: { (textField: UITextField) in textField.placeholder = "New List Name" })
      
        alertView.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: { (action) in   alertView.textFields?[0].text = "" }))

        alertView.addAction(UIAlertAction(title: "Create", style: UIAlertActionStyle.default, handler: { (action) in
            
            let listName : String? = {
                if ((alertView.textFields?[0].text?.trimmingCharacters(in: CharacterSet.whitespaces)) != "" ){
                    return alertView.textFields?[0].text
                }
                return ""
            }()
            
            alertView.textFields?[0].text = ""
            
            print("User clicked create \(listName)")

            if listName != "" {
              
                NotificationCenter.default.post(name: FavoritesListTableViewController.FAVORITESLIST_ADD_DATA_WITH_NAME_IDENTIFIER, object: alertView, userInfo: Dictionary(dictionaryLiteral: ("Name", listName!)))
            }
            
        }))

        
        return alertView
    }()
    
    
    
    func createNewFavoriteListWith(name:String){
        print("Segment prior to creating \(name) || with persistentContainer \( (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext)")

        
        (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext.perform {
            let newList = FavoritesList(context: (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext)
            newList.title = name
            print("Creating new List :: \(newList.title) || with persistentContainer \( (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext)")
            ( UIApplication.shared.delegate as! AppDelegate ).saveContext()
            
            NotificationCenter.default.post(name: FavoritesListTableViewController.FAVORITESLIST_REFRESH_DATA_IDENTIFIER, object: nil, userInfo: nil)

        }
    }
}


