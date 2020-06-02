//
//  GoalViewController.swift
//  CoreDataTableTrial
//
//  Created by Scott Bolin on 5/30/20.
//  Copyright © 2020 Scott Bolin. All rights reserved.
//

import UIKit
import CoreData

class GoalViewController: UIViewController {
  
  //MARK: - Properties
  let delegate = GoalViewDelegate()
  var dataSource: GoalViewDataSource<Note, GoalViewController>!
  var fetchedResultsController: NSFetchedResultsController<Note>!
  var predicate: NSPredicate?
  
  //MARK: - IBOutlets
  @IBOutlet weak var tableView: UITableView!
  
  //MARK: - View Lifecycle
  override func viewDidLoad() {
    super.viewDidLoad()
    
    tableView.delegate = delegate
    setupTableView()
    navigationItem.title = "Goal View"
  }
  
  func setupTableView() {
    if fetchedResultsController == nil {
      fetchedResultsController = CoreDataController.sharedManager.fetchedNoteGoalResultsController
    }
    fetchedResultsController.fetchRequest.predicate = predicate
    do {
      try fetchedResultsController.performFetch()
      tableView.reloadData()
    } catch {
      print("Fetch failed")
    }
    dataSource = GoalViewDataSource(tableView: tableView, fetchedResultsController: fetchedResultsController, delegate: self)
  }
  
  
  
  
  
  //MARK: - IBActions
  @IBAction func filterTapped(_ sender: UIBarButtonItem) {
    updateDataSource()
  }
  
  //MARK: - IBAction Helper functions
  func updateDataSource() {
    let ac = UIAlertController(title: "Filter Notes...", message: nil, preferredStyle: .actionSheet)
    
    ac.addAction(UIAlertAction(title: "Only show fixes", style: .default) { [unowned self] _ in
      self.predicate = nil
      self.fetchedResultsController.fetchRequest.fetchLimit = 0
      self.predicate = NSPredicate(format: "goalTitle CONTAINS[cd] 'fix'")
      self.setupTableView()
    })
    ac.addAction(UIAlertAction(title: "Only show todos", style: .default) { [unowned self] _ in
      self.predicate = nil
      self.fetchedResultsController.fetchRequest.fetchLimit = 0
      self.predicate = NSPredicate(format:
        //       "(Goal.goalTitle CONTAINS[cd] 'todo') || (Goal.goalTitle CONTAINS[cd] 'to do') || (Note.noteText CONTAINS[cd] 'todo') || (Note.noteText CONTAINS[cd] 'to do')")
        "(goalTitle CONTAINS[cd] 'todo') || (goalTitle CONTAINS[cd] 'to do')")
      self.setupTableView()
    })
    ac.addAction(UIAlertAction(title: "Only show completed", style: .default) { [unowned self] _ in
      self.predicate = nil
      self.fetchedResultsController.fetchRequest.fetchLimit = 0
      //      self.goalPredicate = NSPredicate(format: "(Goal.goalCompleted == true) || (noteCompleted == true)")
      self.predicate = NSPredicate(format: "(goalCompleted == true)")
      self.setupTableView()
    })
    ac.addAction(UIAlertAction(title: "Show today", style: .default) { [unowned self ] _ in
      self.predicate = nil
      self.fetchedResultsController.fetchRequest.fetchLimit = 0
      let twentyfourHoursAgo = Date().addingTimeInterval(-86400)
      self.predicate = NSPredicate(format: "goalDateCreated > %@", twentyfourHoursAgo as NSDate)
      self.setupTableView()
    })
    ac.addAction(UIAlertAction(title: "Show last week", style: .default) { [unowned self ] _ in
      self.predicate = nil
      self.fetchedResultsController.fetchRequest.fetchLimit = 0
      let lastWeek = Date().addingTimeInterval(-604800)
      self.predicate = NSPredicate(format: "goalDateCreated > %@", lastWeek as NSDate)
      self.setupTableView()
    })
    ac.addAction(UIAlertAction(title: "Show last month", style: .default) { [unowned self ] _ in
      self.predicate = nil
      self.fetchedResultsController.fetchRequest.fetchLimit = 0
      let lastMonth = Date().addingTimeInterval(-2592000)
      self.predicate = NSPredicate(format: "goalDateCreated > %@", lastMonth as NSDate)
      self.setupTableView()
    })
    ac.addAction(UIAlertAction(title: "Show last note", style: .default) { [unowned self] _ in
      self.predicate = nil
      self.fetchedResultsController.fetchRequest.fetchLimit = 0
      let createdAtDescriptor = NSSortDescriptor(key: "goalDateCreated", ascending: false)
      self.fetchedResultsController.fetchRequest.sortDescriptors = [createdAtDescriptor]
      self.fetchedResultsController.fetchRequest.fetchLimit = 1
      self.setupTableView()
    })
    ac.addAction(UIAlertAction(title: "Show all notes", style: .default) { [unowned self] _ in
      self.predicate = nil
      self.fetchedResultsController.fetchRequest.fetchLimit = 0
      self.setupTableView()
    })
    ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
    present(ac, animated: true)
  }
}

//MARK: - Delegate Methods
extension GoalViewController: GoalViewDataSourceDelegate {
  func configureGoalCell(_ cell: GoalCell, for object: Goal) {
    cell.configureGoalCell(for: object)
  }
  
  func configureNoteCell(_ cell: NoteCell, for object: Note) {
    cell.configureNoteCell(for: object)
  }
}
