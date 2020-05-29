//
//  TableViewDataSource.swift
//  CoreDataTableTrial
//
//  Created by Scott Bolin on 5/24/20.
//  Copyright © 2020 Scott Bolin. All rights reserved.
//

import UIKit
import CoreData

protocol TableViewDataSourceDelegate: class {
  associatedtype Object
  associatedtype Cell: UITableViewCell
  func configure(_ cell: Cell, for object: Object)
//  func supplementaryObject(at indexPath: IndexPath) -> Object?
//  func fetchedIndexPath(for presentedIndexPath: IndexPath) -> IndexPath?
}
//extension TableViewDataSourceDelegate {
//  func supplementaryObject(at indexPath: IndexPath) -> Object? {
//    return nil
//  }
//
//  func fetchedIndexPath(for presentedIndexPath: IndexPath) -> IndexPath? {
//    return presentedIndexPath
//  }
//}

class TableViewDataSource<Result: NSFetchRequestResult, Delegate: TableViewDataSourceDelegate>: NSObject, UITableViewDataSource, NSFetchedResultsControllerDelegate {
  
  typealias Object = Delegate.Object
  typealias Cell = Delegate.Cell
  
  // MARK:- Private Parameters
  fileprivate let tableView: UITableView
  fileprivate var fetchedResultsController: NSFetchedResultsController<Goal>?
  fileprivate weak var delegate: Delegate!
  fileprivate let cellIdentifier: String
  
  //MARK: - Initializer
  required init(tableView: UITableView, cellIdentifier: String, fetchedResultsController: NSFetchedResultsController<Goal>, delegate: Delegate) {
    self.tableView = tableView
    self.cellIdentifier = cellIdentifier
    self.fetchedResultsController = fetchedResultsController
    self.delegate = delegate
    super.init()
    fetchedResultsController.delegate = self
    try! fetchedResultsController.performFetch()
    tableView.dataSource = self
    print("Initialized tableview, about to reloadData")
    print("number of sections: \(String(describing: fetchedResultsController.sections?.count)))")
    tableView.reloadData()
  }
  
  //MARK:- Helper functions
//  var selectedObject: Object? {
//    guard let indexPath = tableView.indexPathForSelectedRow else { return nil }
//    return objectAtIndexPath(indexPath)
//  }
//
//  func objectAtIndexPath(_ indexPath: IndexPath) -> Object {
//    guard let fetchedIndexPath = delegate.fetchedIndexPath(for: indexPath) else {
//      return delegate.supplementaryObject(at: indexPath)!
//    }
//    return (fetchedGoalResultsController.object(at: fetchedIndexPath) as! Object)
//  }
  
  //MARK: - UITableViewDataSource methods
  
  func numberOfSections(in tableView: UITableView) -> Int {
    if let frc = fetchedResultsController {
      return frc.sections!.count
    }
    return 0
  }
  
  func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    guard let sectionInfo = self.fetchedResultsController?.sections?[section] else {
      return nil
    }
    return sectionInfo.name
  }
  

  func sectionIndexTitles(for tableView: UITableView) -> [String]? {
    return self.fetchedResultsController?.sectionIndexTitles
  }
  
  func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
    guard let result = self.fetchedResultsController?.section(forSectionIndexTitle: title, at: index) else {
      fatalError("Unable to locate section for \(title) at \(index)")
    }
    return result
  }

  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    guard let sections = self.fetchedResultsController?.sections else {
      fatalError("No sections in fetchedGoalResultsController")
    }
    let sectionInfo = sections[section]
    return sectionInfo.numberOfObjects
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier , for: indexPath) as! Cell
    guard let noteObject = self.fetchedResultsController?.object(at: indexPath) else {
      fatalError("Unexpected cell type at \(indexPath)")
    }
    delegate.configure(cell, for: noteObject as! Object)
    //    configureCell(cell, at: indexPath)
    return cell
  }
  
  /*
  //MARK: - Helper methods
  func configureCell(_ cell: UITableViewCell, at indexPath: IndexPath) {
    let note = CoreDataController.sharedManager.fetchedGoalResultsController.object(at: indexPath)
    
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "dd-mmm-yyyy"
    
    if let todos = note.notes.allObjects as? [Note] {
      let cellInfo = todos[indexPath.row]
      cell.textLabel?.text = cellInfo.noteText
      let dateString = dateFormatter.string(from: cellInfo.noteDate)
      cell.detailTextLabel?.text = dateString
    }
    //    cell.textLabel?.text = note.goalTitleLabel
  }
  
  func configCell(view: ViewController, cell: UITableViewCell, indexPath: IndexPath) {
    configureCell(cell, at: indexPath)
  }
  */
  
  //MARK: - NSFetchedResultsControllerDelegate delegate methods
  func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
    tableView.beginUpdates()
  }
  
  func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
    
    let indexSet = IndexSet(integer: sectionIndex)
    
    switch type {
    case .insert:
      tableView.insertSections(indexSet, with: .automatic)
    case .delete:
      tableView.deleteSections(indexSet, with: .automatic)
    case .move:
      break
    case .update:
      break
    @unknown default:
      break
    }
  }
  
  func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
    
    switch type {
    case .insert:
      tableView.insertRows(at: [newIndexPath!], with: .automatic)
//      guard let indexPath = newIndexPath else { fatalError("Index path should be not nil") }
//      let indexSet = NSIndexSet(index: indexPath.section)
//      tableView.insertSections(indexSet as IndexSet, with: .automatic)
      
    case .delete:
      tableView.deleteRows(at: [indexPath!], with: .automatic)
//      guard let indexPath = indexPath else { fatalError("Index path should be not nil") }
//      let indexSet = NSIndexSet(index: indexPath.section)
//      tableView.deleteSections(indexSet as IndexSet, with: .automatic)
      
    case .update:
      tableView.reloadRows(at: [indexPath!], with: .automatic)
      
//      guard let indexPath = indexPath else { fatalError("Index path should be not nil") }
//      let indexSet = NSIndexSet(index: indexPath.section)
//      let object = objectAtIndexPath(indexPath)
//      guard let cell = tableView.cellForRow(at: indexPath) as? Cell else { break }
//      delegate.configure(cell, for: object)
//      dataSource.configureCell(cell, at: indexPath)
      
    case .move:
      tableView.moveRow(at: indexPath!, to: newIndexPath!)

//      guard let indexPath = indexPath else { fatalError("Index path should be not nil") }
//      guard let newIndexPath = newIndexPath else { fatalError("New index path should be not nil") }
//      let indexSet = NSIndexSet(index: indexPath.section)
//      let newindexSet = NSIndexSet(index: newIndexPath.section)
//      tableView.deleteSections(indexSet as IndexSet, with: .automatic)
//      tableView.insertSections(newindexSet as IndexSet, with: .automatic)
      
    @unknown default:
      break
    }
  }
  
  func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
    tableView.endUpdates()
  }
}

extension TableViewDataSource: NoteCellDelegate {
  
  func noteCell(_ cell: NoteCell, completionChanged completion: Bool) {
    print("in TableViewDataSource: noteCell, completion: \(completion)")
    let context = CoreDataController.sharedManager.persistentContainer.viewContext
    // standard method
//    guard let indexPath = tableView.indexPath(for: cell) else { fatalError("Index path should not be nil")}
//    let goal = CoreDataController.sharedManager.fetchedGoalResultsController.object(at: indexPath)
    
    // alt method
    guard let indexPath = tableView.indexPathForSelectedRow else { return }
    let goal = CoreDataController.sharedManager.fetchedGoalResultsController.object(at: indexPath)
    let note = CoreDataController.sharedManager.fetchedNoteResultsController.object(at: indexPath)
    
    CoreDataController.sharedManager.markGoalCompleted(completed: completion, goal: goal)
    CoreDataController.sharedManager.markNoteCompleted(completed: completion, note: note)

    /*
     goal.goalCompleted = completion
     let notes = goal.notes
     notes.forEach { (note) in
       note.noteCompleted = completion
     }
     if completion {
       goal.goalDateCompleted = Date()
       notes.forEach { (note) in
         note.noteDateCompleted = Date()
       }
     }
     */
    
    do {
    try context.save()
    } catch {
      print("Could not save updated completion state")
    }
  }
}


