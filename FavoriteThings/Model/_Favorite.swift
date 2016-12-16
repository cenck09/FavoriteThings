// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Favorite.swift instead.

import Foundation
import CoreData

public enum FavoriteAttributes: String {
    case dateAdded = "dateAdded"
    case rating = "rating"
    case title = "title"
}

public enum FavoriteRelationships: String {
    case favoritesList = "favoritesList"
}

open class _Favorite: NSManagedObject {

    // MARK: - Class methods

    open class func entityName () -> String {
        return "Favorite"
    }

    open class func entity(managedObjectContext: NSManagedObjectContext) -> NSEntityDescription? {
        return NSEntityDescription.entity(forEntityName: self.entityName(), in: managedObjectContext)
    }

    // MARK: - Life cycle methods

    public override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }

    public convenience init?(managedObjectContext: NSManagedObjectContext) {
        guard let entity = _Favorite.entity(managedObjectContext: managedObjectContext) else { return nil }
        self.init(entity: entity, insertInto: managedObjectContext)
    }

    // MARK: - Properties

    @NSManaged open
    var dateAdded: Date?

    @NSManaged open
    var rating: NSNumber?

    @NSManaged open
    var title: String?

    // MARK: - Relationships

    @NSManaged open
    var favoritesList: FavoritesList?

}

