// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to FavoritesList.swift instead.

import Foundation
import CoreData

public enum FavoritesListAttributes: String {
    case dateAdded = "dateAdded"
    case title = "title"
}

public enum FavoritesListRelationships: String {
    case favorites = "favorites"
}

open class _FavoritesList: NSManagedObject {

    // MARK: - Class methods

    open class func entityName () -> String {
        return "FavoritesList"
    }

    open class func entity(managedObjectContext: NSManagedObjectContext) -> NSEntityDescription? {
        return NSEntityDescription.entity(forEntityName: self.entityName(), in: managedObjectContext)
    }

    // MARK: - Life cycle methods

    public override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }

    public convenience init?(managedObjectContext: NSManagedObjectContext) {
        guard let entity = _FavoritesList.entity(managedObjectContext: managedObjectContext) else { return nil }
        self.init(entity: entity, insertInto: managedObjectContext)
    }

    // MARK: - Properties

    @NSManaged open
    var dateAdded: Date?

    @NSManaged open
    var title: String?

    // MARK: - Relationships

    @NSManaged open
    var favorites: NSSet

    open func favoritesSet() -> NSMutableSet {
        return self.favorites.mutableCopy() as! NSMutableSet
    }

}

extension _FavoritesList {

    open func addFavorites(_ objects: NSSet) {
        let mutable = self.favorites.mutableCopy() as! NSMutableSet
        mutable.union(objects as Set<NSObject>)
        self.favorites = mutable.copy() as! NSSet
    }

    open func removeFavorites(_ objects: NSSet) {
        let mutable = self.favorites.mutableCopy() as! NSMutableSet
        mutable.minus(objects as Set<NSObject>)
        self.favorites = mutable.copy() as! NSSet
    }

    open func addFavoritesObject(_ value: Favorite) {
        let mutable = self.favorites.mutableCopy() as! NSMutableSet
        mutable.add(value)
        self.favorites = mutable.copy() as! NSSet
    }

    open func removeFavoritesObject(_ value: Favorite) {
        let mutable = self.favorites.mutableCopy() as! NSMutableSet
        mutable.remove(value)
        self.favorites = mutable.copy() as! NSSet
    }

}

