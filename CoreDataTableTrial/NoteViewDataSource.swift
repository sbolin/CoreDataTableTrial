//
//  NoteViewDataSource.swift
//  CoreDataTableTrial
//
//  Created by Scott Bolin on 5/24/20.
//  Copyright © 2020 Scott Bolin. All rights reserved.
//

import UIKit
import CoreData

protocol NoteViewDataSourceDelegate: class {
  func configureNoteCell(at indexPath: IndexPath, _ cell: NoteCell, for object: Note)
  func configureGoalCell(at indexPath: IndexPath,_ cell: GoalCell, for object: Goal)
}

class NoteViewDataSource<Result: NSFetchRequestResult, Delegate: NoteViewDataSourceDelegate>: NSObject, UITableViewDataSource, NSFetchedResultsControllerDelegate {
  
  // MARK:- Private Parameters
  fileprivate let tableView: UITableView
  fileprivate var fetchedResultsController: NSFetchedResultsController<Result>
  fileprivate weak var delegate: Delegate!
  
  //MARK: - Initializer
  required init(tableView: UITableView, fetchedResultsController: NSFetchedResultsController<Result>, delegate: Delegate) {
    self.tableView = tableView
    self.fetchedResultsController = fetchedResultsController
    self.delegate = delegate
    
    super.init()
    fetchedResultsController.delegate = self
    try! fetchedResultsController.performFetch()
    tableView.dataSource = self
    tableView.reloadData()
  }
  
  //MARK: - UITableViewDataSource methods
  
  func numberOfSections(in tableView: UITableView) -> Int {
    return fetchedResultsController.sections?.count ?? 0
  }
  
  func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    guard let sectionInfo = self.fetchedResultsController.sections?[section] else {
      return nil
    }
    return sectionInfo.name
  }
  
  /*
  func sectionIndexTitles(for tableView: UITableView) -> [String]? {
    return self.fetchedResultsController.sectionIndexTitles
  }
  
  func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
    return self.fetchedResultsController.section(forSectionIndexTitle: title, at: index)
  }
  */
 
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    guard let section = self.fetchedResultsController.sections?[section] else { return 0 }
    return section.numberOfObjects
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let noteCell = tableView.dequeueReusableCell(withIdentifier: NoteCell.reuseIdentifier , for: indexPath) as! NoteCell
    noteCell.noteCellDelegate = self
    let noteObject = self.fetchedResultsController.object(at: indexPath)
    delegate?.configureNoteCell(at: indexPath, noteCell, for: noteObject as! Note)
    return noteCell
  }
  
  //MARK: - TableView editing methods
  func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
    switch editingStyle {
    case .delete:
      let note = fetchedResultsController.object(at: indexPath)
      CoreDataController.shared.deleteNote(note: note as! Note)
      CoreDataController.shared.saveContext()
    // delete data
    case .insert:
      CoreDataController.shared.addNote(text: "New Note", at: indexPath)
      tableView.beginUpdates()
      let rowToInsertAt = IndexPath.init(row: indexPath.row - 1, section: indexPath.section)
      tableView.insertRows(at: [rowToInsertAt], with: .automatic)
      tableView.endUpdates()
    // insert data
    case .none:
      break
    // do nothing
    @unknown default:
      break
    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
      
      let editAction = UIContextualAction(style: .normal,
                                          title:  "Edit",
                                          handler: { (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in
                                            success(true)
      })
      editAction.backgroundColor = .systemGreen
      return UISwipeActionsConfiguration(actions: [editAction])
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
      
      let deleteAction = UIContextualAction(style: .normal,
                                            title:  "Delete",
                                            handler: { (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in
                                              success(true)
      })
      deleteAction.backgroundColor = .systemRed
      
      return UISwipeActionsConfiguration(actions: [deleteAction])
    }
  }
  
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
    case .delete:
      tableView.deleteRows(at: [indexPath!], with: .automatic)
    case .move:
      tableView.moveRow(at: indexPath!, to: newIndexPath!)
    case .update:
      tableView.reloadRows(at: [indexPath!], with: .automatic)
    @unknown default:
      break
    }
  }
  
  func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
    tableView.endUpdates()
  }
}

extension NoteViewDataSource: NoteCellDelegate {
  func noteCell(_ cell: NoteCell, completionChanged completion: Bool) {
    
    guard let indexPath = tableView.indexPath(for: cell) else { return }
    let note = CoreDataController.shared.fetchedNoteResultsController.object(at: indexPath)
    
    CoreDataController.shared.markNoteCompleted(completed: completion, note: note)
    CoreDataController.shared.saveContext()
  }
}


