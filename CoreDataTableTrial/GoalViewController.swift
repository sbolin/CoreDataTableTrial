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
  private let filterViewControllerSegueIdentifier = "toFilterViewController"
  let delegate = GoalViewDelegate()
  var dataSource: GoalViewDataSource<Note, GoalViewController>!
  var fetchedResultsController: NSFetchedResultsController<Note>!
  var predicate: NSPredicate?
 
  var fetchRequest: NSFetchRequest<Goal>?
  var goals: [Goal] = []
  var asyncFetchRequest: NSAsynchronousFetchResult<Goal>?
  
  
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
      fetchedResultsController = CoreDataController.shared.fetchedNoteGoalResultsController
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
  
  //MARK: - Navigation
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    guard segue.identifier == filterViewControllerSegueIdentifier,
      let navController = segue.destination as? UINavigationController,
      let filterVC = navController.topViewController as? FilterViewController
    else {
      return
    }
    filterVC.delegate = self
    
  }
  
  //MARK: - IBActions
  @IBAction func filterTapped(_ sender: UIBarButtonItem) {
//    updateDataSource()
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

extension GoalViewController {
  func fetchAndReload() {
    guard let fetchRequest = fetchRequest else {
      return
    }
    do {
      goals = try CoreDataController.shared.persistentContainer.viewContext.fetch(fetchRequest)
      tableView.reloadData()
    } catch let error as NSError {
      print("Could not fetch \(error), \(error.userInfo)")
    }
  }
}

//MARK: - Delegate Methods
extension GoalViewController: GoalViewDataSourceDelegate {
  func configureGoalCell(at indexPath: IndexPath, _ cell: GoalCell, for object: Goal) {
    cell.configureGoalCell(at: indexPath, for: object)
  }
  
  func configureNoteCell(at indexPath: IndexPath, _ cell: NoteCell, for object: Note) {
    cell.configureNoteCell(at: indexPath, for: object)
  }
}

extension GoalViewController: FilterViewControllerDelegate {
  func filterViewController(filter: FilterViewController, didSelectPredicate predicate: NSPredicate?, sortDescriptor: NSSortDescriptor?) {
    
    guard let fetchRequest = fetchRequest else {
      return
    }
    fetchRequest.predicate = nil
    fetchRequest.sortDescriptors = nil
    fetchRequest.predicate = predicate
    
    if let sort = sortDescriptor {
      fetchRequest.sortDescriptors = [sort]
    }
    fetchAndReload()
  }
  
}
