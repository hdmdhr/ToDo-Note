//
//  ToDoItems+CoreDataProperties.swift
//  
//
//  Created by DongMing on 2018-12-01.
//
//

import Foundation
import CoreData


extension ToDoItems {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ToDoItems> {
        return NSFetchRequest<ToDoItems>(entityName: "ToDoItems")
    }

    @NSManaged public var done: String?
    @NSManaged public var note: String?
    @NSManaged public var title: String?
    @NSManaged public var parentCategory: Category?
    @NSManaged public var savedImages: Image?

}
