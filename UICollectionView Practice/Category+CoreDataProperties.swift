//
//  Category+CoreDataProperties.swift
//  
//
//  Created by DongMing on 2018-12-01.
//
//

import Foundation
import CoreData


extension Category {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Category> {
        return NSFetchRequest<Category>(entityName: "Category")
    }

    @NSManaged public var colorHex: String?
    @NSManaged public var dateCreated: NSDate?
    @NSManaged public var doneExpanded: Bool
    @NSManaged public var failedExpanded: Bool
    @NSManaged public var name: String?
    @NSManaged public var order: Int32
    @NSManaged public var toDoExpanded: Bool
    @NSManaged public var itemsToDo: NSSet?

}

// MARK: Generated accessors for itemsToDo
extension Category {

    @objc(addItemsToDoObject:)
    @NSManaged public func addToItemsToDo(_ value: ToDoItems)

    @objc(removeItemsToDoObject:)
    @NSManaged public func removeFromItemsToDo(_ value: ToDoItems)

    @objc(addItemsToDo:)
    @NSManaged public func addToItemsToDo(_ values: NSSet)

    @objc(removeItemsToDo:)
    @NSManaged public func removeFromItemsToDo(_ values: NSSet)

}
