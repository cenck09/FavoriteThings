//
//  FavoritesTableViewController.swift
//  FavoriteThings
//
//  Created by chris on 11/6/16.
//  Copyright © 2016 chris. All rights reserved.
//

import Foundation
import UIKit
import CoreData


class FavoritesTableViewController:  UITableViewController {
    
    static let FAVORITES_STORYBOARD_ID = "FavoritesTable"
    static let FAVORITES_CELL_REUSE_IDENTIFIER = "FavoritesCell"
    static let FAVORITES_REFRESH_DATA_IDENTIFIER : NSNotification.Name = NSNotification.Name(rawValue: "RefreshFavoritesTableView")
    static let FAVORITES_ADD_DATA_WITH_NAME_IDENTIFIER : NSNotification.Name = NSNotification.Name(rawValue: "AddNewFavorite")
    
    var fetchedFavorites : [Favorite] = []
    
    var notificationObserverRefreshData: Any?
    var notificationObserverAddData: Any?
    
    var parentList : FavoritesList?
    
    func refetch(){
        do {
            let favFetch : NSFetchRequest<Favorite> = Favorite.fetchRequest()
            
            favFetch.predicate = NSPredicate(format: "favoritesList == %@", parentList!)
            
            fetchedFavorites = try ((UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext.fetch(favFetch)) as [Favorite]
            
        } catch {
            fatalError("Failed to fetch Lists: \(error)")
        }
        tableView.reloadData()
    }
    
  //  var parentList : FavoritesList?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
       
    //    self.navigationItem.title = parentList != nil ? parentList?.title : "Favs"
        
        refetch()
        
       notificationObserverRefreshData = (  NotificationCenter.default ).addObserver(forName: FavoritesTableViewController.FAVORITES_REFRESH_DATA_IDENTIFIER, object: nil, queue: OperationQueue.main) { notification in
        
            self.refetch()
        }
        
        notificationObserverAddData = (  NotificationCenter.default ).addObserver(forName: FavoritesTableViewController.FAVORITES_ADD_DATA_WITH_NAME_IDENTIFIER, object: nil, queue: OperationQueue.main) { notification in
            
            let pair = notification.userInfo?.first
            self.createNewFavoriteItemWith(name: pair?.value as! String)
            
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
        let fav = fetchedFavorites[indexPath.row]

        (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext.delete(fav)
        
        ((UIApplication.shared.delegate as! AppDelegate).saveContext())
        
        refetch()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return fetchedFavorites.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80.0
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        let cell : UITableViewCell = {
            let nCell = tableView.dequeueReusableCell(withIdentifier: FavoritesTableViewController.FAVORITES_CELL_REUSE_IDENTIFIER)
            if nCell != nil {
                return nCell!
            }
            return UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: FavoritesTableViewController.FAVORITES_CELL_REUSE_IDENTIFIER)
        }()
        
        cell.textLabel?.text = fetchedFavorites[indexPath.row].title
        cell.textLabel?.textAlignment = .center

        return cell;
    }
    
    
    @IBAction func displayAddListPrompt(_ sender: UIBarButtonItem) {
        present(addFavoriteAlert, animated: true, completion: nil)
    }
    
    
    // The Alert View Controller to handel input validation & creating the managed object to save
    
    let addFavoriteAlert : UIAlertController = {
        
        let alertView = UIAlertController(title: "Add Favorite :", message: nil, preferredStyle: UIAlertControllerStyle.alert)
        
        alertView.addTextField(configurationHandler: { (textField: UITextField) in
            textField.placeholder = "New Favorite "
        })
        
        alertView.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: { (action) in
            NSLog("Cancel Adding Favorite ")
            alertView.textFields?[0].text = ""
        }))
        
        alertView.addAction(UIAlertAction(title: "Create", style: UIAlertActionStyle.default, handler: { (action) in
            
            let favoriteName : String? = {
                
                if ((alertView.textFields?[0].text?.trimmingCharacters(in: CharacterSet.whitespaces)) != "" ){
                    return alertView.textFields?[0].text
                }else{
                    
                    return ""
                }
                
                }()
            
            alertView.textFields?[0].text = ""

            if favoriteName != "" {
                
                NotificationCenter.default.post(name: FavoritesTableViewController.FAVORITES_ADD_DATA_WITH_NAME_IDENTIFIER, object: nil, userInfo: Dictionary(dictionaryLiteral: ("Name", favoriteName!)))
                
            }
        }))
        
        return alertView
    }()
    
    
    func createNewFavoriteItemWith(name:String){
        
        (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext.perform {
    
            let newFavorite = Favorite(context: (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext)
            
            newFavorite.title = name
            
            newFavorite.favoritesList = self.parentList
            
            do{
                try (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext.save()
            }catch{
                print("Error \(error)")
            }
            ( UIApplication.shared.delegate as! AppDelegate ).saveContext()
         
            DispatchQueue.main.async {
                self.refetch()
            }
        }
    }
}


