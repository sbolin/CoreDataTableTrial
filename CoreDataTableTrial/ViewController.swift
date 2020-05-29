//
//  ViewController.swift
//  CoreDataTableTrial
//
//  Created by Scott Bolin on 5/24/20.
//  Copyright © 2020 Scott Bolin. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController {
  
  //MARK: - Properties
  let delegate = TableViewDelegate()
  var dataSource: TableViewDataSource<Goal, ViewController>!
  var fetchedResultsController: NSFetchedResultsController<Goal>!
  var goalPredicate: NSPredicate?
  
  //MARK: - IBOutlets
  @IBOutlet weak var tableView: UITableView!
  
  //MARK: - View Lifecycle
  override func viewDidLoad() {
    super.viewDidLoad()
    CoreDataController.sharedManager.createNotesIfNeeded()
    tableView.delegate = delegate
    setupTableView()
  }
  
  func setupTableView() {
    if fetchedResultsController == nil {
      fetchedResultsController = CoreDataController.sharedManager.fetchedResultsController
    }
    fetchedResultsController.fetchRequest.predicate = goalPredicate
    do {
      try fetchedResultsController.performFetch()
      tableView.reloadData()
    } catch {
      print("Fetch failed")
    }
    
    dataSource = TableViewDataSource(tableView: tableView, cellIdentifier: "NoteCell", fetchedResultsController: fetchedResultsController, delegate: self)
  }
  
  //MARK: - IBActions
  @IBAction func addNote(_ sender: UIBarButtonItem) {
    
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
  
  @IBAction func filterTapped(_ sender: UIBarButtonItem) {
    let ac = UIAlertController(title: "Filter Notes...", message: nil, preferredStyle: .actionSheet)
    
    ac.addAction(UIAlertAction(title: "Only show fixes", style: .default) { [unowned self] _ in
      self.goalPredicate = NSPredicate(format: "goalTitle CONTAINS[cd] 'fix'")
      self.setupTableView()
    })
    ac.addAction(UIAlertAction(title: "Only show todos", style: .default) { [unowned self] _ in
      self.goalPredicate = NSPredicate(format: "(goalTitle CONTAINS[cd] 'todo') || (goalTitle CONTAINS[cd] 'to do')")
      //      self.notePredicate = NSPredicate(format: "NOT message BEGINSWITH 'Merge pull request'")
      self.setupTableView()
    })
    ac.addAction(UIAlertAction(title: "Only show completed", style: .default) { [unowned self] _ in
      self.goalPredicate = NSPredicate(format: "goalCompleted == true")
      self.setupTableView()
    })
    
    ac.addAction(UIAlertAction(title: "Show today", style: .default) { [unowned self ] _ in
      let twentyfourHoursAgo = Date().addingTimeInterval(-86400)
      self.goalPredicate = NSPredicate(format: "goalDateCreated > %@", twentyfourHoursAgo as NSDate)
      self.setupTableView()
    })
    ac.addAction(UIAlertAction(title: "Show last week", style: .default) { [unowned self ] _ in
      let lastWeek = Date().addingTimeInterval(-86400 * 7)
      self.goalPredicate = NSPredicate(format: "goalDateCreated > %@", lastWeek as NSDate)
      self.setupTableView()
    })
    ac.addAction(UIAlertAction(title: "Show last month", style: .default) { [unowned self ] _ in
      let lastMonth = Date().addingTimeInterval(-86400 * 30)
      self.goalPredicate = NSPredicate(format: "goalDateCreated > %@", lastMonth as NSDate)
      self.setupTableView()
    })
    ac.addAction(UIAlertAction(title: "Show last note", style: .default) { [unowned self] _ in
      self.fetchedResultsController.fetchRequest.fetchLimit = 1
      self.setupTableView()
    })
    
    ac.addAction(UIAlertAction(title: "Show all notes", style: .default) { [unowned self] _ in
      self.goalPredicate = nil
      self.setupTableView()
    })
    
    ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
    present(ac, animated: true)
  }
}

//MARK: - Delegate Methods
extension ViewController: TableViewDataSourceDelegate {
  func configure(_ cell: NoteCell, for object: Goal) {
    cell.configure(for: object)
  }
}


