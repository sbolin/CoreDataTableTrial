//
//  NoteViewController.swift
//  CoreDataTableTrial
//
//  Created by Scott Bolin on 5/24/20.
//  Copyright © 2020 Scott Bolin. All rights reserved.
//

import UIKit
import CoreData

class NoteViewController: UIViewController {
  
  //MARK: - Properties
  let delegate = TableViewDelegate()
  
  //  var dataSource: TableViewDataSource<Goal, NoteViewController>!
  var dataSource: TableViewDataSource<Note>!
  
  //  var fetchedResultsController: NSFetchedResultsController<Goal>!
  var fetchedResultsController: NSFetchedResultsController<Note>!
  
  var goalPredicate: NSPredicate?
  
  //MARK: - IBOutlets
  @IBOutlet weak var tableView: UITableView!
  
  //MARK: - View Lifecycle
  override func viewDidLoad() {
    super.viewDidLoad()
    CoreDataController.sharedManager.createNotesIfNeeded()
    tableView.delegate = delegate
    setupTableView()
    navigationItem.title = "Goals"
  }
  
  func setupTableView() {
    if fetchedResultsController == nil {
      //      fetchedResultsController = CoreDataController.sharedManager.fetchedGoalResultsController
      fetchedResultsController = CoreDataController.sharedManager.fetchedNoteResultsController
    }
    fetchedResultsController.fetchRequest.predicate = goalPredicate
    do {
      try fetchedResultsController.performFetch()
      tableView.reloadData()
    } catch {
      print("Fetch failed")
    }
    
    dataSource = TableViewDataSource(tableView: tableView, fetchedResultsController: fetchedResultsController)
  }
  
  //MARK: - IBActions
  @IBAction func addNoteTapped(_ sender: UIBarButtonItem) {
    addNote()
  }
  
  @IBAction func filterTapped(_ sender: UIBarButtonItem) {
    updateDataSource()
  }
  
  //MARK: - IBAction Helper functions
  func updateDataSource() {
    let ac = UIAlertController(title: "Filter Notes...", message: nil, preferredStyle: .actionSheet)
    
    ac.addAction(UIAlertAction(title: "Only show fixes", style: .default) { [unowned self] _ in
      self.goalPredicate = nil
      self.fetchedResultsController.fetchRequest.fetchLimit = 0
      self.goalPredicate = NSPredicate(format: "noteText CONTAINS[cd] 'fix'")
      self.setupTableView()
    })
    ac.addAction(UIAlertAction(title: "Only show todos", style: .default) { [unowned self] _ in
      self.goalPredicate = nil
      self.fetchedResultsController.fetchRequest.fetchLimit = 0
      self.goalPredicate = NSPredicate(format:
        //       "(Goal.goalTitle CONTAINS[cd] 'todo') || (Goal.goalTitle CONTAINS[cd] 'to do') || (noteText CONTAINS[cd] 'todo') || (noteText CONTAINS[cd] 'to do')")
        "(noteText CONTAINS[cd] 'todo') || (noteText CONTAINS[cd] 'to do')")
      self.setupTableView()
    })
    ac.addAction(UIAlertAction(title: "Only show completed", style: .default) { [unowned self] _ in
      self.goalPredicate = nil
      self.fetchedResultsController.fetchRequest.fetchLimit = 0
      //      self.goalPredicate = NSPredicate(format: "(Goal.goalCompleted == true) || (noteCompleted == true)")
      self.goalPredicate = NSPredicate(format: "(noteCompleted == true)")
      self.setupTableView()
    })
    
    ac.addAction(UIAlertAction(title: "Show today", style: .default) { [unowned self ] _ in
      self.goalPredicate = nil
      self.fetchedResultsController.fetchRequest.fetchLimit = 0
      let twentyfourHoursAgo = Date().addingTimeInterval(-86400)
      self.goalPredicate = NSPredicate(format: "noteDateCreated > %@", twentyfourHoursAgo as NSDate)
      self.setupTableView()
    })
    ac.addAction(UIAlertAction(title: "Show last week", style: .default) { [unowned self ] _ in
      self.goalPredicate = nil
      self.fetchedResultsController.fetchRequest.fetchLimit = 0
      let lastWeek = Date().addingTimeInterval(-604800)
      self.goalPredicate = NSPredicate(format: "noteDateCreated > %@", lastWeek as NSDate)
      self.setupTableView()
    })
    ac.addAction(UIAlertAction(title: "Show last month", style: .default) { [unowned self ] _ in
      self.goalPredicate = nil
      self.fetchedResultsController.fetchRequest.fetchLimit = 0
      let lastMonth = Date().addingTimeInterval(-2592000)
      self.goalPredicate = NSPredicate(format: "noteDateCreated > %@", lastMonth as NSDate)
      self.setupTableView()
    })
    ac.addAction(UIAlertAction(title: "Show last note", style: .default) { [unowned self] _ in
      self.goalPredicate = nil
      self.fetchedResultsController.fetchRequest.fetchLimit = 0
      let createdAtDescriptor = NSSortDescriptor(key: "noteDateCreated", ascending: false)
      self.fetchedResultsController.fetchRequest.sortDescriptors = [createdAtDescriptor]
      self.fetchedResultsController.fetchRequest.fetchLimit = 1
      self.setupTableView()
    })
    
    ac.addAction(UIAlertAction(title: "Show all notes", style: .default) { [unowned self] _ in
      self.goalPredicate = nil
      self.fetchedResultsController.fetchRequest.fetchLimit = 0
      self.setupTableView()
    })
    
    ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
    
    present(ac, animated: true)
  }
  
  func addNote() {
    let alertController = UIAlertController(
      title: "Add Goal",
      message: "Add a new Goal and Text",
      preferredStyle: .alert)
    
    alertController.addTextField { textField in
      textField.placeholder = "Goal Name"
    }
    
    alertController.addTextField { textField in
      textField.placeholder = "Text"
    }
    
    let saveAction = UIAlertAction(title: "Save", style: .default) { [unowned self] action in
      guard
        let noteTextField = alertController.textFields?.first,
        let textTextField = alertController.textFields?.last
        else {
          return
      }
      guard let goalTitle = noteTextField.text else { return }
      guard let noteText = textTextField.text else { return }
      
      let _ = CoreDataController.sharedManager.addGoal(title: goalTitle, noteText: noteText)
      
      print("Attempted to make new note, Title: \(goalTitle), Text: \(noteText)")
      
      self.tableView.reloadData()
    }
    alertController.addAction(saveAction)
    alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
    present(alertController, animated: true)
  }
  
}

//MARK: - Delegate Methods
extension NoteViewController: TableViewDataSourceDelegate {
  func configureGoalCell(_ cell: GoalCell, for object: Goal) {
    print("In NoteViewController: configureGoalCell")

  }
  
  //  func configure(_ cell: NoteCell, for object: Goal) {
  func configureNoteCell(_ cell: NoteCell, for object: Note) {
    print("In NoteViewController: configureNoteCell")
    cell.configure(for: object)
  }
}


