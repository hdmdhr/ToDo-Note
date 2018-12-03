//
//  Image+CoreDataProperties.swift
//  
//
//  Created by DongMing on 2018-12-01.
//
//

import Foundation
import CoreData


extension Image {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Image> {
        return NSFetchRequest<Image>(entityName: "Image")
    }

    @NSManaged public var order: Int32
    @NSManaged public var picture: NSData?
    @NSManaged public var fromItem: ToDoItems?

}
