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
    let goalSort = NSSortDescriptor(keyPath: \Goal.goalTitle, ascending: true)
    let createdSort = NSSortDescriptor(keyPath: \Goal.goalDateCreated, ascending: false)
    request.sortDescriptors = [goalSort, createdSort]
    
    let fetchedResultsController = NSFetchedResultsController(
      fetchRequest: request,
      managedObjectContext: context,
      sectionNameKeyPath: "goalTitle",
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
      sectionNameKeyPath: "goal.goalTitle",
      cacheName: nil)
    
    return fetchedResultsController
  }()
  
  func saveContext () {
    print("func saveContext")
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
    let context = persistentContainer.viewContext
    let goal = fetchedGoalResultsController.object(at: indexPath)
    let note = NSEntityDescription.insertNewObject(forEntityName: "Note", into: context) as! Note
    note.noteText = text
    note.noteDateCreated = Date()
    note.noteCompleted = false
    note.goal = goal
  }
  
  //Add new Goal
  func addGoal(title: String, noteText: String) -> Goal? {
    print("\nfunc addGoal: Title: \(title), Text: \(noteText)")
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
    
    NSLog("New Goal: %@", goal)
    NSLog("New Note: %@", note)
    
    return goal
  }
  
  func updateGoal(updatedGoalTitle: String, updatedNoteText: String, at indexPath: IndexPath) {
    print("func updateGoal: Title: \(updatedGoalTitle), Text: \(updatedNoteText)")
    let note = fetchedNoteResultsController.object(at: indexPath)
    note.noteText = updatedNoteText
    let goal = note.goal
    goal.goalTitle = updatedGoalTitle
        
    NSLog("Update Goal: %@", goal)
    NSLog("Update Note: %@", note)
    
    saveContext()
  }
  
  //Mark Goal Completed
  func markGoalCompleted(completed: Bool, goal: Goal) {
    print("func markGoalCompleted")
    //  let context = CoreDataController.sharedManager.persistentContainer.viewContext
    
    goal.goalCompleted = completed
    goal.goalDateCompleted =  Date()
    let notes = goal.notes
    notes.forEach { item in
      item.noteCompleted = completed
      item.noteDateCompleted = Date()
    }
    
    NSLog("Mark Goal Completed Goal: %@", goal)
    NSLog("Mark Goal Completed Note: %@", notes)
    
    saveContext()
  }
  
  //Mark Note Completed
  func markNoteCompleted(completed: Bool, note: Note) {
    print("func markNoteCompleted")
    note.noteCompleted = completed
    note.noteDateCompleted = Date()
    
    NSLog("Mark Note Completed Note: %@", note)
    
    saveContext()
  }
  
  
  //Delete Goal
  func deleteGoal(goal: Goal) {
    print("func deleteNote: note: \(goal)")
    let context = CoreDataController.sharedManager.persistentContainer.viewContext
    context.delete(goal)
    saveContext()
  }
  
  //Delete Note
  func deleteNote(note: Note) {
    print("func deleteAttachment: attachment: \(note)")
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
//    let fetchRequest = Goal.goalFetchRequest()
    let fetchRequest = Note.noteFetchRequest()
    let count = try! context.count(for: fetchRequest)
    
    guard count == 0 else { return }
    
    // Goal 1
    let goal = NSEntityDescription.insertNewObject(forEntityName: "Goal", into: context) as! Goal
    goal.goalTitle = "First Goal"
    goal.goalDateCreated = Date()
    goal.goalCompleted = false
    let note1 = NSEntityDescription.insertNewObject(forEntityName: "Note", into: context) as! Note
    note1.noteText = "Goal 1, Note 1"
    note1.noteDateCreated = Date(timeIntervalSinceNow: -60*60*24*1)
    note1.noteCompleted = false
    note1.goal = goal
    
    let note2 = NSEntityDescription.insertNewObject(forEntityName: "Note", into: context) as! Note
    note2.noteText = "Goal 1, Note 2"
    note2.noteDateCreated = Date(timeIntervalSinceNow: -60*60*24*2)
    note2.noteCompleted = false
    note2.goal = goal
    
    let note3 = NSEntityDescription.insertNewObject(forEntityName: "Note", into: context) as! Note
    note3.noteText = "Goal 1, Note 3"
    note3.noteDateCreated = Date(timeIntervalSinceNow: -60*60*24*3)
    note3.noteCompleted = false
    note3.goal = goal
    
    // Goal 2
    let goal2 = NSEntityDescription.insertNewObject(forEntityName: "Goal", into: context) as! Goal
    goal2.goalTitle = "Second Goal"
    goal2.goalDateCreated = Date(timeIntervalSinceNow: -60*60*24*4)
    goal2.goalCompleted = false
    let note4 = NSEntityDescription.insertNewObject(forEntityName: "Note", into: context) as! Note
    note4.noteText = "Goal 2, Note 1"
    note4.noteDateCreated = Date(timeIntervalSinceNow: -60*60*24*5)
    note4.noteCompleted = false
    note4.goal = goal2
    
    let note5 = NSEntityDescription.insertNewObject(forEntityName: "Note", into: context) as! Note
    note5.noteText = "Goal 2, Note 2"
    note5.noteDateCreated = Date(timeIntervalSinceNow: -60*60*24*6)
    note5.noteCompleted = false
    note5.goal = goal2
    
    let note6 = NSEntityDescription.insertNewObject(forEntityName: "Note", into: context) as! Note
    note6.noteText = "Goal 2, Note 3"
    note6.noteDateCreated = Date(timeIntervalSinceNow: -60*60*24*7)
    note6.noteCompleted = false
    note6.goal = goal2
    
    // Goal 3
    let goal3 = NSEntityDescription.insertNewObject(forEntityName: "Goal", into: context) as! Goal
    goal3.goalTitle = "Third Goal"
    goal3.goalDateCreated = Date(timeIntervalSinceNow: -60*60*24*8)
    goal3.goalCompleted = true
    goal3.goalDateCompleted = Date(timeIntervalSinceNow: -60*60*24*7)
    let note7 = NSEntityDescription.insertNewObject(forEntityName: "Note", into: context) as! Note
    note7.noteText = "Goal 3, Note 1"
    note7.noteDateCreated = Date(timeIntervalSinceNow: -60*60*24*9)
    note7.noteCompleted = true
    //    attachment7.note = note3
    
    let note8 = NSEntityDescription.insertNewObject(forEntityName: "Note", into: context) as! Note
    note8.noteText = "Goal 3, Note 2"
    note8.noteDateCreated = Date(timeIntervalSinceNow: -60*60*24*10)
    note8.noteCompleted = false
    //    attachment8.note = note3
    
    let note9 = NSEntityDescription.insertNewObject(forEntityName: "Note", into: context) as! Note
    note9.noteText = "Goal 3, Note 3"
    note9.noteDateCreated = Date(timeIntervalSinceNow: -60*60*24*11)
    note9.noteCompleted = false
    //    attachment9.note = note3
    
    goal3.addToNotes([note7, note8, note9])
    
    saveContext()
  }
}
