//
//  CoreDataController.swift
//  CoreDataTableTrial
//
//  Created by Scott Bolin on 5/24/20.
//  Copyright © 2020 Scott Bolin. All rights reserved.
//

import UIKit
import CoreData

class CoreDataController {
  
  static let sharedManager = CoreDataController() // singleton
  private init() {} // Prevent clients from creating another instance.
  
  lazy var persistentContainer: NSPersistentContainer = {
    
    let container = NSPersistentContainer(name: "Model")
    
    /* for migration
     let description = NSPersistentStoreDescription()
     description.shouldMigrateStoreAutomatically = true
     description.shouldInferMappingModelAutomatically = true
     container.persistentStoreDescriptions = [description]
     end migration
     */
    
    container.loadPersistentStores(completionHandler: { (storeDescription, error) in
      
      container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
      
      if let error = error as NSError? {
        fatalError("Unresolved error \(error), \(error.userInfo)")
      }
    })
    return container
  }()
  
  // Fetch methods
  lazy var fetchedGoalResultsController: NSFetchedResultsController<Goal> = {
    let context = persistentContainer.viewContext
    let request = Goal.goalFetchRequest()
    let createdSort = NSSortDescriptor(keyPath: \Goal.goalDateCreated, ascending: false)
    request.sortDescriptors = [createdSort]
    
    let fetchedResultsController = NSFetchedResultsController(
      fetchRequest: request,
      managedObjectContext: context,
      sectionNameKeyPath: "goalDateCreated",
      cacheName: nil)
    
    return fetchedResultsController
  }()
  
  lazy var fetchedNoteResultsController: NSFetchedResultsController<Note> = {
    let context = persistentContainer.viewContext
    let request = Note.noteFetchRequest()
    let goalSort = NSSortDescriptor(keyPath: \Note.goal.goalTitle, ascending: true)
    let createdSort = NSSortDescriptor(keyPath: \Note.noteDateCreated, ascending: false)
    request.sortDescriptors = [goalSort, createdSort]
    
    let fetchedResultsController = NSFetchedResultsController(
      fetchRequest: request,
      managedObjectContext: context,
      sectionNameKeyPath: "Goal.goalTitle",
      cacheName: nil)
    
    return fetchedResultsController
  }()
  
  lazy var fetchedNoteGoalResultsController: NSFetchedResultsController<Note> = {
    let context = persistentContainer.viewContext
    let request = Note.noteFetchRequest()
    let createdSort = NSSortDescriptor(keyPath: \Note.goal.goalDateCreated, ascending: false)
    request.sortDescriptors = [createdSort]
    
    let fetchedResultsController = NSFetchedResultsController(
      fetchRequest: request,
      managedObjectContext: context,
      sectionNameKeyPath: "goal.goalDateCreated",
      cacheName: nil)
    
    return fetchedResultsController
  }()
  
  func saveContext () {
    let context = persistentContainer.viewContext
    guard context.hasChanges else { return }
    do {
      try context.save()
    } catch let error as NSError {
      print("Unresolved error \(error), \(error.localizedDescription)")
    }
  }
  
  //Add new Note
  func addNote(text: String, at indexPath: IndexPath) {
    print("addNote")
    let context = persistentContainer.viewContext
    let note = fetchedNoteResultsController.object(at: indexPath)
    let goal = note.goal
    let newNote = NSEntityDescription.insertNewObject(forEntityName: "Note", into: context) as! Note
    newNote.noteText = text
    newNote.noteDateCreated = Date()
    newNote.noteCompleted = false
    newNote.goal = goal
    
  }
  
  //Add new Goal
  func addGoal(title: String, noteText: String) -> Goal? {
    print("addGoal")
    let context = persistentContainer.viewContext
    let goal = Goal(context: context)
    let note = Note(context: context)
    
    goal.goalTitle = title
    goal.goalDateCreated = Date()
    goal.goalCompleted = false
    note.noteText = noteText
    note.noteDateCreated = Date()
    note.noteCompleted = false
    goal.addToNotes(note)
    //    note.goal = goal
    saveContext()
    return goal
  }
  
  func updateGoal(updatedGoalTitle: String, updatedNoteText: String, at indexPath: IndexPath) {
    print("updateGoal")
    let note = fetchedNoteResultsController.object(at: indexPath)
    let goal = note.goal
    
    if note.noteText != updatedNoteText {
      note.noteText = updatedNoteText
    }
    if goal.goalTitle != updatedGoalTitle {
      goal.goalTitle = updatedGoalTitle
    }
    goal.addToNotes(note)
    saveContext()
  }
  
  //Mark Goal Completed
  func markGoalCompleted(completed: Bool, goal: Goal) {
    print("markGoalCompleted")
    goal.goalCompleted = completed
    goal.goalDateCompleted =  Date()
    let notes = goal.notes
    notes.forEach { item in
      item.noteCompleted = completed
      item.noteDateCompleted = Date()
    }
    saveContext()
  }
  
  //Mark Note Completed
  func markNoteCompleted(completed: Bool, note: Note) {
    print("markNoteCompleted")
    note.noteCompleted = completed
    note.noteDateCompleted = Date()
    saveContext()
  }
  
  
  //Delete Goal
  func deleteGoal(goal: Goal) {
    print("deleteGoal")
    let context = CoreDataController.sharedManager.persistentContainer.viewContext
    context.delete(goal)
    saveContext()
  }
  
  //Delete Note
  func deleteNote(note: Note) {
    print("deleteNote")
    let context = CoreDataController.sharedManager.persistentContainer.viewContext
    let associatedGoal = note.goal
    let noteCount = associatedGoal.notes.count
    if noteCount < 2 {
      context.delete(note)
      context.delete(associatedGoal)
    } else {
      context.delete(note)
    }
    saveContext()
  }
  
  // create notes
  //TODO: make json file and read in
  func createNotesIfNeeded() {
    
    // check if notes exist, if so return
    let context = persistentContainer.viewContext
    let fetchRequest = Note.noteFetchRequest()
    let count = try! context.count(for: fetchRequest)
    
    guard count == 0 else { return }
    
    // Goal 4
    let goal4 = NSEntityDescription.insertNewObject(forEntityName: "Goal", into: context) as! Goal
    goal4.goalTitle = "Fourth Goal"
    goal4.goalDateCreated = Date()
    goal4.goalCompleted = false
    
    let note1 = NSEntityDescription.insertNewObject(forEntityName: "Note", into: context) as! Note
    note1.noteText = "Goal 4, Note 1"
    note1.noteDateCreated = Date(timeIntervalSinceNow: -60*60*24*1)
    note1.noteCompleted = false
    note1.goal = goal4
    
    let note2 = NSEntityDescription.insertNewObject(forEntityName: "Note", into: context) as! Note
    note2.noteText = "Goal 4, Note 2"
    note2.noteDateCreated = Date(timeIntervalSinceNow: -60*60*24*2)
    note2.noteCompleted = false
    note2.goal = goal4
    
    let note3 = NSEntityDescription.insertNewObject(forEntityName: "Note", into: context) as! Note
    note3.noteText = "Goal 4, Note 3"
    note3.noteDateCreated = Date(timeIntervalSinceNow: -60*60*24*3)
    note3.noteCompleted = false
    note3.goal = goal4
    
    // Goal 3
    let goal3 = NSEntityDescription.insertNewObject(forEntityName: "Goal", into: context) as! Goal
    goal3.goalTitle = "Third Goal"
    goal3.goalDateCreated = Date(timeIntervalSinceNow: -60*60*24*4)
    goal3.goalCompleted = false
    
    let note4 = NSEntityDescription.insertNewObject(forEntityName: "Note", into: context) as! Note
    note4.noteText = "Goal 3, Note 1"
    note4.noteDateCreated = Date(timeIntervalSinceNow: -60*60*24*5)
    note4.noteCompleted = false
    note4.goal = goal3
    
    let note5 = NSEntityDescription.insertNewObject(forEntityName: "Note", into: context) as! Note
    note5.noteText = "Goal 3, Note 2"
    note5.noteDateCreated = Date(timeIntervalSinceNow: -60*60*24*6)
    note5.noteCompleted = true
    note5.goal = goal3
    
    let note6 = NSEntityDescription.insertNewObject(forEntityName: "Note", into: context) as! Note
    note6.noteText = "Goal 3, Note 3"
    note6.noteDateCreated = Date(timeIntervalSinceNow: -60*60*24*7)
    note6.noteCompleted = false
    note6.goal = goal3
    
    // Goal 2
    let goal2 = NSEntityDescription.insertNewObject(forEntityName: "Goal", into: context) as! Goal
    goal2.goalTitle = "Second Goal"
    goal2.goalDateCreated = Date(timeIntervalSinceNow: -60*60*24*8)
    goal2.goalCompleted = true
    goal2.goalDateCompleted = Date(timeIntervalSinceNow: -60*60*24*7)
    
    let note7 = NSEntityDescription.insertNewObject(forEntityName: "Note", into: context) as! Note
    note7.noteText = "Goal 2, Note 1"
    note7.noteDateCreated = Date(timeIntervalSinceNow: -60*60*24*9)
    note7.noteCompleted = true
    note7.noteDateCompleted = Date(timeIntervalSinceNow: -60*60*24*8)
    note7.goal = goal2
    
    let note8 = NSEntityDescription.insertNewObject(forEntityName: "Note", into: context) as! Note
    note8.noteText = "Goal 2, Note 2"
    note8.noteDateCreated = Date(timeIntervalSinceNow: -60*60*24*10)
    note8.noteCompleted = true
    note8.noteDateCompleted = Date(timeIntervalSinceNow: -60*60*24*9)
    note8.goal = goal2
    
    let note9 = NSEntityDescription.insertNewObject(forEntityName: "Note", into: context) as! Note
    note9.noteText = "Goal 2, Note 3"
    note9.noteDateCreated = Date(timeIntervalSinceNow: -60*60*24*11)
    note9.noteCompleted = true
    note9.noteDateCompleted = Date(timeIntervalSinceNow: -60*60*24*10)
    note9.goal = goal2
    
    // Goal 4
    let goal1 = NSEntityDescription.insertNewObject(forEntityName: "Goal", into: context) as! Goal
    goal1.goalTitle = "First Goal"
    goal1.goalDateCreated = Date(timeIntervalSinceNow: -60*60*24*31)
    goal1.goalCompleted = false
    
    let note10 = NSEntityDescription.insertNewObject(forEntityName: "Note", into: context) as! Note
    note10.noteText = "Goal 1, Note 1"
    note10.noteDateCreated = Date(timeIntervalSinceNow: -60*60*24*32)
    note10.noteCompleted = true
    note10.noteDateCompleted = Date(timeIntervalSinceNow: -60*60*24*25)
    note10.goal = goal1
    
    let note11 = NSEntityDescription.insertNewObject(forEntityName: "Note", into: context) as! Note
    note11.noteText = "Goal 1, Note 2"
    note11.noteDateCreated = Date(timeIntervalSinceNow: -60*60*24*33)
    note11.noteCompleted = false
    note11.goal = goal1
    
    let note12 = NSEntityDescription.insertNewObject(forEntityName: "Note", into: context) as! Note
    note12.noteText = "Goal 1, Note 3"
    note12.noteDateCreated = Date(timeIntervalSinceNow: -60*60*24*34)
    note12.noteCompleted = false
    note12.goal = goal1
    
    saveContext()
  }
}
