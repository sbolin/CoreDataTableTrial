//
//  Note+CoreDataProperties.swift
//  CoreDataTableTrial
//
//  Created by Scott Bolin on 5/29/20.
//  Copyright © 2020 Scott Bolin. All rights reserved.
//
//

import Foundation
import CoreData


extension Note {

    @nonobjc public class func noteFetchRequest() -> NSFetchRequest<Note> {
        return NSFetchRequest<Note>(entityName: "Note")
    }

    @NSManaged public var noteCompleted: Bool
    @NSManaged public var noteDateCompleted: Date?
    @NSManaged public var noteDateCreated: Date
    @NSManaged public var noteText: String
    @NSManaged public var goal: Goal

}
