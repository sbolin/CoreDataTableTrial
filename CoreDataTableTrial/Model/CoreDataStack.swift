//
//  CoreDataController.swift
//  CoreDataTableTrial
//
//  Created by Scott Bolin on 5/24/20.
//  Copyright © 2020 Scott Bolin. All rights reserved.
//

import UIKit
import CoreData

class CoreDataController: NSObject, NSFetchedResultsControllerDelegate {
  
  private let modelName: String
  
  init(modelName: String) {
    self.modelName = modelName
  }
  
  lazy var managedContext: NSManagedObjectContext = {
    return self.persistentContainer.viewContext
  }()
  
  private lazy var persistentContainer: NSPersistentContainer = {
    let container = NSPersistentContainer(name: self.modelName)
    container.loadPersistentStores { (storeDescription, error) in
      container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
      if let error = error as NSError? {
        print("Unresolved error \(error), \(error.userInfo)")
      }
    }
    return container
  }()
  
  
  func saveContext () {
    guard managedContext.hasChanges else { return }
    do {
      try managedContext.save()
    } catch let error as NSError {
      print("Unresolved error \(error), \(error.localizedDescription)")
    }
  }
  
  lazy var fetchAllNotes: NSFetchedResultsController<Note> = {
    let context = persistentContainer.viewContext
    let fetchNotes = NSFetchRequest<Note>(entityName: "Note")
    let sortDescriptor = NSSortDescriptor(key: "dateCreated", ascending: false)
    fetchNotes.sortDescriptors = [sortDescriptor]
    
    let fetchedResultsController = NSFetchedResultsController(
      fetchRequest: fetchNotes,
      managedObjectContext: context,
      sectionNameKeyPath: "title",
      cacheName: nil)
//    fetchedResultsController.delegate = self
    return fetchedResultsController
  }()
  
  lazy var fetchCompletedNotes: NSFetchedResultsController<Note> = {
    let context = persistentContainer.viewContext
    let fetchNotes = Note.noteFetchRequest()
    let sortDescriptor = NSSortDescriptor(key: "dateCreated", ascending: false)
    let task = true
    fetchNotes.sortDescriptors = [sortDescriptor]
    fetchNotes.predicate = NSPredicate(format: "accomplished == %@", task)
    
    let fetchedResultsController = NSFetchedResultsController(
      fetchRequest: fetchNotes,
      managedObjectContext: context,
      sectionNameKeyPath: "title",
      cacheName: nil)
//    fetchedResultsController.delegate = self
    return fetchedResultsController
  }()
  
  func initializeFetchedResultsController() {
    let context = persistentContainer.viewContext
    let request = Note.noteFetchRequest()
    
    let createdSort = NSSortDescriptor(key: "dateCreated", ascending: true)
    let doneSort = NSSortDescriptor(key: "accomplished", ascending: true)
    
    request.sortDescriptors = [createdSort, doneSort]
    
    let fetchedResultsController = NSFetchedResultsController(
      fetchRequest: request,
      managedObjectContext: context,
      sectionNameKeyPath: "dateCreated",
      cacheName: nil)
    
    fetchedResultsController.delegate = self
    
    do {
      try fetchedResultsController.performFetch()
    } catch {
      fatalError("Failed to initialize FetchedResultsController: \(error)")
    }
  }
  
  func createNotesIfNeeded() {
    
    // check if notes exist, if so return
    
    let fetchRequest = Note.noteFetchRequest()
    let count = try! managedContext.count(for: fetchRequest)
    
    guard count == 0 else { return }
    
    // Note 1
    let note = NSEntityDescription.insertNewObject(forEntityName: "Note", into: managedContext) as! Note
    note.title = "First Note"
    note.dateCreated = Date()
    note.accomplished = false
    let attachment1 = NSEntityDescription.insertNewObject(forEntityName: "Attachment", into: managedContext) as! Attachment
    attachment1.noteText = "Entry 1, Note 1"
    attachment1.noteDate = Date(timeIntervalSinceNow: -60*60*24*1)
    attachment1.completed = false
    attachment1.note = note
    
    let attachment2 = NSEntityDescription.insertNewObject(forEntityName: "Attachment", into: managedContext) as! Attachment
    attachment2.noteText = "Entry 1, Note 2"
    attachment2.noteDate = Date(timeIntervalSinceNow: -60*60*24*2)
    attachment2.completed = false
    attachment2.note = note
    
    let attachment3 = NSEntityDescription.insertNewObject(forEntityName: "Attachment", into: managedContext) as! Attachment
    attachment3.noteText = "Entry 1, Note 3"
    attachment3.noteDate = Date(timeIntervalSinceNow: -60*60*24*3)
    attachment3.completed = false
    attachment3.note = note
    
    // Note 2
    let note2 = NSEntityDescription.insertNewObject(forEntityName: "Note", into: managedContext) as! Note
    note2.title = "Second Note"
    note2.dateCreated = Date(timeIntervalSinceNow: -60*60*24*4)
    note2.accomplished = false
    let attachment4 = NSEntityDescription.insertNewObject(forEntityName: "Attachment", into: managedContext) as! Attachment
    attachment4.noteText = "Entry 2, Note 1"
    attachment4.noteDate = Date(timeIntervalSinceNow: -60*60*24*5)
    attachment4.completed = false
    attachment4.note = note2
    
    let attachment5 = NSEntityDescription.insertNewObject(forEntityName: "Attachment", into: managedContext) as! Attachment
    attachment5.noteText = "Entry 2, Note 2"
    attachment5.noteDate = Date(timeIntervalSinceNow: -60*60*24*6)
    attachment5.completed = false
    attachment5.note = note2
    
    let attachment6 = NSEntityDescription.insertNewObject(forEntityName: "Attachment", into: managedContext) as! Attachment
    attachment6.noteText = "Entry 2, Note 3"
    attachment6.noteDate = Date(timeIntervalSinceNow: -60*60*24*7)
    attachment6.completed = false
    attachment6.note = note2
    
    // Note 3
    let note3 = NSEntityDescription.insertNewObject(forEntityName: "Note", into: managedContext) as! Note
    note3.title = "Second Note"
    note3.dateCreated = Date(timeIntervalSinceNow: -60*60*24*8)
    note3.accomplished = true
    note3.dataAccomplished = Date(timeIntervalSinceNow: -60*60*24*7)
    let attachment7 = NSEntityDescription.insertNewObject(forEntityName: "Attachment", into: managedContext) as! Attachment
    attachment7.noteText = "Entry 3, Note 1"
    attachment7.noteDate = Date(timeIntervalSinceNow: -60*60*24*9)
    attachment7.completed = false
    //    attachment7.note = note3
    
    let attachment8 = NSEntityDescription.insertNewObject(forEntityName: "Attachment", into: managedContext) as! Attachment
    attachment8.noteText = "Entry 3, Note 2"
    attachment8.noteDate = Date(timeIntervalSinceNow: -60*60*24*10)
    attachment8.completed = false
    //    attachment8.note = note3
    
    let attachment9 = NSEntityDescription.insertNewObject(forEntityName: "Attachment", into: managedContext) as! Attachment
    attachment9.noteText = "Entry 3, Note 3"
    attachment9.noteDate = Date(timeIntervalSinceNow: -60*60*24*11)
    attachment9.completed = false
    //    attachment9.note = note3
    
    note3.addToAttachments([attachment7, attachment8, attachment9])
    
    saveContext()
  }
}
