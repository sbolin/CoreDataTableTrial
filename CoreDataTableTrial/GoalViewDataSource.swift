//
//  GoalViewDataSource.swift
//  CoreDataTableTrial
//
//  Created by Scott Bolin on 6/1/20.
//  Copyright © 2020 Scott Bolin. All rights reserved.
//

import UIKit
import CoreData

protocol GoalViewDataSourceDelegate: class {
  func configureNoteCell(_ cell: NoteCell, for object: Note)
  func configureGoalCell(_ cell: GoalCell, for object: Goal)
}

class GoalViewDataSource<Result: NSFetchRequestResult, Delegate: GoalViewDataSourceDelegate>: NSObject, UITableViewDataSource, NSFetchedResultsControllerDelegate {
  
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
  // # Sections
  func numberOfSections(in tableView: UITableView) -> Int {
    return fetchedResultsController.sections?.count ?? 0
  }
  
  // Title of section
  func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    guard let sectionInfo = self.fetchedResultsController.sections?[section] else {
      return nil
    }
    let dateFormatterGet = DateFormatter()
    dateFormatterGet.dateFormat =  "yyyy-MM-dd HH:mm:ss Z"
    let dateFormatterPrint = DateFormatter()
    dateFormatterPrint.dateFormat = "dd-MMM-yyyy"
    guard let date = dateFormatterGet.date(from: sectionInfo.name) else { return "No Date" }
    let sectionTitle = dateFormatterPrint.string(from: date)
    return sectionTitle

  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    guard let section = self.fetchedResultsController.sections?[section] else { return 0 }
    let numberOfRows = section.numberOfObjects
    return numberOfRows
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
    print("Indexpath: \(indexPath), section: \(indexPath.section), row: \(indexPath.row)")
    let noteObject = self.fetchedResultsController.object(at: indexPath) as! Note
    let goalObject = noteObject.goal
    print("Indexpath: section: \(indexPath.section), row: \(indexPath.row)")
    print("Objects - \nGoal: \(goalObject), \nNote: \(noteObject)")
    
    if indexPath.row == 0 {
//    if goalObject.isKind(of: Goal.self) {
      let goalCell = tableView.dequeueReusableCell(withIdentifier: "GoalCell" , for: indexPath) as! GoalCell
//      print("Goal indexPath.section: \(indexPath.section), indexPath.row: \(indexPath.row)")
      delegate?.configureGoalCell(goalCell, for: goalObject)
      print("goalcell configured: \(goalCell)")
      return goalCell
    }
    let noteCell = tableView.dequeueReusableCell(withIdentifier: "NoteCell", for: indexPath) as! NoteCell
//    print("Note indexPath.section: \(indexPath.section), indexPath.row: \(indexPath.row)")
    delegate?.configureNoteCell(noteCell, for: noteObject)
    print("notecell configured: \(noteCell)")
    return noteCell
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




