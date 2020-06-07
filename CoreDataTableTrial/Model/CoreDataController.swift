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
  
  static let shared = CoreDataController() // singleton
  private init() {} // Prevent clients from creating another instance.
  
  lazy var managedContext: NSManagedObjectContext = {
    return self.persistentContainer.viewContext
  }()
  
  lazy var persistentContainer: NSPersistentContainer = {
    let container = NSPersistentContainer(name: "Model")
    container.loadPersistentStores(completionHandler: { (storeDescription, error) in
      container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
      if let error = error as NSError? {
        fatalError("Unresolved error \(error), \(error.userInfo)")
      }
    })
    return container
  }()
  
// Fetch methods
  
//  lazy var fetchedGoalResultsController: NSFetchedResultsController<Goal> = {
//    let context = persistentContainer.viewContext
//    let request = Goal.goalFetchRequest()
//    let goalCreatedSort = NSSortDescriptor(keyPath: \Goal.goalDateCreated, ascending: false)
//    let noteCreatedSort = NSSortDescriptor(keyPath: \Note.noteDateCreated, ascending: false)
//    request.sortDescriptors = [noteCreatedSort, goalCreatedSort ]
//
//    let fetchedResultsController = NSFetchedResultsController(
//      fetchRequest: request,
//      managedObjectContext: context,
//      sectionNameKeyPath: "goalDateCreated",
//      cacheName: nil)
//
//    return fetchedResultsController
//  }()
  
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
    let goalCreatedSort = NSSortDescriptor(keyPath: \Note.goal.goalDateCreated, ascending: false)
    let noteCreatedSort = NSSortDescriptor(keyPath: \Note.noteDateCreated, ascending: false)

    request.sortDescriptors = [goalCreatedSort, noteCreatedSort]
    
    let fetchedResultsController = NSFetchedResultsController(
      fetchRequest: request,
      managedObjectContext: context,
      sectionNameKeyPath: "goal.goalDateCreated",
      cacheName: nil)
    
    return fetchedResultsController
  }()
  
  func saveContext () {
    guard managedContext.hasChanges else { return }
    do {
      try managedContext.save()
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
  
  //Mark Note Completed
  func markNoteCompleted(completed: Bool, note: Note) {
    print("markNoteCompleted")
    note.noteCompleted = completed
    note.noteDateCompleted = Date()
    
    let goalToCheck = note.goal
    let notes = goalToCheck.notes
    let noteCount = notes.count
    var count = 0
    for note in notes {
      if note.noteCompleted == true { count += 1}
    }
    if noteCount == count {
      goalToCheck.goalCompleted = true
      goalToCheck.goalDateCompleted = Date()
    }
    saveContext()
  }
  
  
  //Delete Goal
  func deleteGoal(goal: Goal) {
    print("deleteGoal")
    let context = CoreDataController.shared.persistentContainer.viewContext
    context.delete(goal)
    saveContext()
  }
  
  //Delete Note
  func deleteNote(note: Note) {
    print("deleteNote")
    let context = CoreDataController.shared.persistentContainer.viewContext
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
  func createNotesIfNeeded() {
    
    // check if notes exist, if so return
    let context = persistentContainer.viewContext
    let fetchRequest = Note.noteFetchRequest()
    let count = try! context.count(for: fetchRequest)
    
    guard count == 0 else { return }
  
    // Goal 8
    let goal8 = NSEntityDescription.insertNewObject(forEntityName: "Goal", into: context) as! Goal
    goal8.goalTitle = "Eighth Goal"
    goal8.goalDateCreated = Date(timeIntervalSinceNow: -60*60*24*366)
    goal8.goalCompleted = false
    
    let note22 = NSEntityDescription.insertNewObject(forEntityName: "Note", into: context) as! Note
    note22.noteText = "Goal 8, Note 1"
    note22.noteDateCreated = Date(timeIntervalSinceNow: -60*60*24*367)
    note22.noteCompleted = false
    note22.goal = goal8
    
    let note23 = NSEntityDescription.insertNewObject(forEntityName: "Note", into: context) as! Note
    note23.noteText = "Goal 8, Note 2"
    note23.noteDateCreated = Date(timeIntervalSinceNow: -60*60*24*368)
    note23.noteCompleted = false
    note23.goal = goal8
    
    let note24 = NSEntityDescription.insertNewObject(forEntityName: "Note", into: context) as! Note
    note24.noteText = "Goal 8, Note 3"
    note24.noteDateCreated = Date(timeIntervalSinceNow: -60*60*24*369)
    note24.noteCompleted = false
    note24.goal = goal8
    
    // Goal 7
    let goal7 = NSEntityDescription.insertNewObject(forEntityName: "Goal", into: context) as! Goal
    goal7.goalTitle = "Seventh Goal"
    goal7.goalDateCreated = Date(timeIntervalSinceNow: -60*60*24*181)
    goal7.goalCompleted = false
    
    let note19 = NSEntityDescription.insertNewObject(forEntityName: "Note", into: context) as! Note
    note19.noteText = "Goal 7, Note 1"
    note19.noteDateCreated = Date(timeIntervalSinceNow: -60*60*24*182)
    note19.noteCompleted = false
    note19.goal = goal7
    
    let note20 = NSEntityDescription.insertNewObject(forEntityName: "Note", into: context) as! Note
    note20.noteText = "Goal 7, Note 2"
    note20.noteDateCreated = Date(timeIntervalSinceNow: -60*60*24*183)
    note20.noteCompleted = false
    note20.goal = goal7
    
    let note21 = NSEntityDescription.insertNewObject(forEntityName: "Note", into: context) as! Note
    note21.noteText = "Goal 7, Note 3"
    note21.noteDateCreated = Date(timeIntervalSinceNow: -60*60*24*184)
    note21.noteCompleted = false
    note21.goal = goal7
    
    // Goal 6
    let goal6 = NSEntityDescription.insertNewObject(forEntityName: "Goal", into: context) as! Goal
    goal6.goalTitle = "Sixth Goal"
    goal6.goalDateCreated = Date(timeIntervalSinceNow: -60*60*24*90)
    goal6.goalCompleted = false
    
    let note16 = NSEntityDescription.insertNewObject(forEntityName: "Note", into: context) as! Note
    note16.noteText = "Goal 6, Note 1"
    note16.noteDateCreated = Date(timeIntervalSinceNow: -60*60*24*91)
    note16.noteCompleted = false
    note16.goal = goal6
    
    let note17 = NSEntityDescription.insertNewObject(forEntityName: "Note", into: context) as! Note
    note17.noteText = "Goal 6, Note 2"
    note17.noteDateCreated = Date(timeIntervalSinceNow: -60*60*24*92)
    note17.noteCompleted = false
    note17.goal = goal6
    
    let note18 = NSEntityDescription.insertNewObject(forEntityName: "Note", into: context) as! Note
    note18.noteText = "Goal 6, Note 3"
    note18.noteDateCreated = Date(timeIntervalSinceNow: -60*60*24*93)
    note18.noteCompleted = false
    note18.goal = goal6
    
    // Goal 5
    let goal5 = NSEntityDescription.insertNewObject(forEntityName: "Goal", into: context) as! Goal
    goal5.goalTitle = "Fifth Goal"
    goal5.goalDateCreated = Date(timeIntervalSinceNow: -60*60*24*32)
    goal5.goalCompleted = false
    
    let note13 = NSEntityDescription.insertNewObject(forEntityName: "Note", into: context) as! Note
    note13.noteText = "Goal 5, Note 1"
    note13.noteDateCreated = Date(timeIntervalSinceNow: -60*60*24*33)
    note13.noteCompleted = false
    note13.goal = goal5
    
    let note14 = NSEntityDescription.insertNewObject(forEntityName: "Note", into: context) as! Note
    note14.noteText = "Goal 5, Note 2"
    note14.noteDateCreated = Date(timeIntervalSinceNow: -60*60*24*34)
    note14.noteCompleted = false
    note14.goal = goal5
    
    let note15 = NSEntityDescription.insertNewObject(forEntityName: "Note", into: context) as! Note
    note15.noteText = "Goal 5, Note 3"
    note15.noteDateCreated = Date(timeIntervalSinceNow: -60*60*24*35)
    note15.noteCompleted = false
    note15.goal = goal5
    
    // Goal 4
    let goal4 = NSEntityDescription.insertNewObject(forEntityName: "Goal", into: context) as! Goal
    goal4.goalTitle = "Fourth Goal"
    goal4.goalDateCreated = Date(timeIntervalSinceNow: -60*60*24*16)
    goal4.goalCompleted = false
    
    let note1 = NSEntityDescription.insertNewObject(forEntityName: "Note", into: context) as! Note
    note1.noteText = "Goal 4, Note 1"
    note1.noteDateCreated = Date(timeIntervalSinceNow: -60*60*24*17)
    note1.noteCompleted = false
    note1.goal = goal4
    
    let note2 = NSEntityDescription.insertNewObject(forEntityName: "Note", into: context) as! Note
    note2.noteText = "Goal 4, Note 2"
    note2.noteDateCreated = Date(timeIntervalSinceNow: -60*60*24*18)
    note2.noteCompleted = false
    note2.goal = goal4
    
    let note3 = NSEntityDescription.insertNewObject(forEntityName: "Note", into: context) as! Note
    note3.noteText = "Goal 4, Note 3"
    note3.noteDateCreated = Date(timeIntervalSinceNow: -60*60*24*19)
    note3.noteCompleted = false
    note3.goal = goal4
    
    // Goal 3
    let goal3 = NSEntityDescription.insertNewObject(forEntityName: "Goal", into: context) as! Goal
    goal3.goalTitle = "Third Goal"
    goal3.goalDateCreated = Date(timeIntervalSinceNow: -60*60*24*12)
    goal3.goalCompleted = false
    
    let note4 = NSEntityDescription.insertNewObject(forEntityName: "Note", into: context) as! Note
    note4.noteText = "Goal 3, Note 1"
    note4.noteDateCreated = Date(timeIntervalSinceNow: -60*60*24*13)
    note4.noteCompleted = false
    note4.goal = goal3
    
    let note5 = NSEntityDescription.insertNewObject(forEntityName: "Note", into: context) as! Note
    note5.noteText = "Goal 3, Note 2"
    note5.noteDateCreated = Date(timeIntervalSinceNow: -60*60*24*14)
    note5.noteCompleted = true
    note5.goal = goal3
    
    let note6 = NSEntityDescription.insertNewObject(forEntityName: "Note", into: context) as! Note
    note6.noteText = "Goal 3, Note 3"
    note6.noteDateCreated = Date(timeIntervalSinceNow: -60*60*24*15)
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
    note9.noteDateCompleted = Date(timeIntervalSinceNow: -60*60*24*8)
    note9.goal = goal2
    
    // Goal 1
    let goal1 = NSEntityDescription.insertNewObject(forEntityName: "Goal", into: context) as! Goal
    goal1.goalTitle = "First Goal"
    goal1.goalDateCreated = Date(timeIntervalSinceNow: -60*60*24*4)
    goal1.goalCompleted = false
    
    let note10 = NSEntityDescription.insertNewObject(forEntityName: "Note", into: context) as! Note
    note10.noteText = "Goal 1, Note 1"
    note10.noteDateCreated = Date(timeIntervalSinceNow: -60*60*24*5)
    note10.noteCompleted = true
    note10.noteDateCompleted = Date(timeIntervalSinceNow: -60*60*24*4)
    note10.goal = goal1
    
    let note11 = NSEntityDescription.insertNewObject(forEntityName: "Note", into: context) as! Note
    note11.noteText = "Goal 1, Note 2"
    note11.noteDateCreated = Date(timeIntervalSinceNow: -60*60*24*6)
    note11.noteCompleted = false
    note11.goal = goal1
    
    let note12 = NSEntityDescription.insertNewObject(forEntityName: "Note", into: context) as! Note
    note12.noteText = "Goal 1, Note 3"
    note12.noteDateCreated = Date(timeIntervalSinceNow: -60*60*24*7)
    note12.noteCompleted = false
    note12.goal = goal1
    
    saveContext()
  }
}
