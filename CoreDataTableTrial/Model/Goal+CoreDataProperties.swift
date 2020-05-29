//
//  Goal+CoreDataProperties.swift
//  CoreDataTableTrial
//
//  Created by Scott Bolin on 5/29/20.
//  Copyright © 2020 Scott Bolin. All rights reserved.
//
//

import Foundation
import CoreData


extension Goal {

    @nonobjc public class func goalFetchRequest() -> NSFetchRequest<Goal> {
        return NSFetchRequest<Goal>(entityName: "Goal")
    }

    @NSManaged public var goalCompleted: Bool
    @NSManaged public var goalDateCompleted: Date?
    @NSManaged public var goalDateCreated: Date
    @NSManaged public var goalTitle: String
  @NSManaged public var notes: Set<Note>

}

// MARK: Generated accessors for notes
extension Goal {

    @objc(addNotesObject:)
    @NSManaged public func addToNotes(_ value: Note)

    @objc(removeNotesObject:)
    @NSManaged public func removeFromNotes(_ value: Note)

    @objc(addNotes:)
  @NSManaged public func addToNotes(_ values: Set<Note>)

    @objc(removeNotes:)
  @NSManaged public func removeFromNotes(_ values: Set<Note>)

}
