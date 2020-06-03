//
//  FilterViewController.swift
//  CoreDataTableTrial
//
//  Created by Scott Bolin on 6/3/20.
//  Copyright © 2020 Scott Bolin. All rights reserved.
//
import UIKit
import CoreData


protocol FilterViewControllerDelegate: class {
  func filterViewController(filter: FilterViewController, didSelectPredicate predicate: NSPredicate?, sortDescriptor: NSSortDescriptor?)
}

class FilterViewController: UITableViewController {
  
  //MARK: - Label Outlets
  //MARK: Keyword
  @IBOutlet weak var goalCategoryLabel: UILabel!
  @IBOutlet weak var todoCategoryLabel: UILabel!
  @IBOutlet weak var fixCategoryLabel: UILabel!
  
  //MARK: Date
  @IBOutlet weak var pastYearLabel: UILabel!
  @IBOutlet weak var pastMonthLabel: UILabel!
  @IBOutlet weak var pastWeekLabel: UILabel!
  @IBOutlet weak var todayLabel: UILabel!
  @IBOutlet weak var allLabel: UILabel!
  
  //MARK:- Cell Outlets
  //MARK: Key Word
  @IBOutlet weak var goalKeywordCell: UITableViewCell!
  @IBOutlet weak var todoKeywordCell: UITableViewCell!
  @IBOutlet weak var fixKeywordCell: UITableViewCell!
  
  //MARK: Date
  @IBOutlet weak var yearCell: UITableViewCell!
  @IBOutlet weak var monthCell: UITableViewCell!
  @IBOutlet weak var weekCell: UITableViewCell!
  @IBOutlet weak var todayCell: UITableViewCell!
  @IBOutlet weak var allCell: UITableViewCell!
  
  //MARK: Sort
  @IBOutlet weak var goalAZSortCell: UITableViewCell!
  @IBOutlet weak var goalZASortCell: UITableViewCell!
  @IBOutlet weak var dateOldNewCell: UITableViewCell!
  @IBOutlet weak var dateNewOldCell: UITableViewCell!
  
  //MARK:- Properties
  weak var delegate: FilterViewControllerDelegate?
  var selectedSortDescriptor: NSSortDescriptor?
  var selectedPredicate: NSPredicate?
  
  let lastDay = Date().addingTimeInterval(-60 * 60 * 24) as NSDate
  let lastWeek = Date().addingTimeInterval(-60 * 60 * 24 * 7) as NSDate
  let lastMonth = Date().addingTimeInterval(-60 * 60 * 24 * 30) as NSDate
  let lastYear = Date().addingTimeInterval(-60 * 60 * 24 * 365) as NSDate
  let allTime = Date().addingTimeInterval(-60 * 60 * 24 * 365 * 5) as NSDate // 5 year to show all notes.
  
 
  //MARK: keyword predicates
  lazy var goalKeywordPredicate: NSPredicate = {
    return NSPredicate(format: "(#keyPath(Goal.goalTitle) CONTAINS[cd] 'goal') || (noteText CONTAINS[cd] 'goal')")
  }()
  
  lazy var todoKeywordPredicate: NSPredicate = {
    return NSPredicate(format: "(#keyPath(Goal.goalTitle) CONTAINS[cd] 'todo') || (#keyPath(Goal.goalTitle) CONTAINS[cd] 'to do') || (noteText CONTAINS[cd] 'todo') || (noteText CONTAINS[cd] 'to do')")
    // alts to try is above doesn't work:
    // "#keyPath(Goal.goalTitle) CONTAINS[cd] 'todo'")
    // "(noteText CONTAINS[cd] 'todo') || (noteText CONTAINS[cd] 'to do')"
  }()
  
  lazy var fixKeywordPredicate: NSPredicate = {
    return NSPredicate(format: "(#keyPath(Goal.goalTitle) CONTAINS[cd] 'fix') || (noteText CONTAINS[cd] 'fix')")
  }()
  
  //MARK: Date Goal Predicates
  lazy var allGoalPredicate: NSPredicate = {
    return NSPredicate(format: "%K > %@", #keyPath(Goal.goalDateCreated), allTime)
  }()
  
  lazy var pastDayGoalPredicate: NSPredicate = {
    return NSPredicate(format: "%K > %@", #keyPath(Goal.goalDateCreated), lastDay)
  }()

  lazy var pastWeekGoalPredicate: NSPredicate = {
    return NSPredicate(format: "%K > %@", #keyPath(Goal.goalDateCreated), lastWeek)
  }()
  
  lazy var pastMonthGoalPredicate: NSPredicate = {
    return NSPredicate(format: "%K > %@", #keyPath(Goal.goalDateCreated), lastMonth)
  }()

  lazy var pastYearGoalPredicate: NSPredicate = {
    return NSPredicate(format: "%K > %@", #keyPath(Goal.goalDateCreated), lastYear)
  }()
  
  
  //MARK: Date Note Predicates
  lazy var allNotePredicate: NSPredicate = {
    return NSPredicate(format: "%K > %@", #keyPath(Note.noteDateCreated), allTime)
  }()
  
  lazy var pastDayNotePredicate: NSPredicate = {
    return NSPredicate(format: "%K > %@", #keyPath(Note.noteDateCreated), lastDay)
  }()
  
  lazy var pastWeekNotePredicate: NSPredicate = {
    return NSPredicate(format: "%K > %@", #keyPath(Note.noteDateCreated), lastWeek)
  }()
  
  lazy var pastMonthNotePredicate: NSPredicate = {
    return NSPredicate(format: "%K > %@", #keyPath(Note.noteDateCreated), lastMonth)
  }()
  
  lazy var pastYearNotePredicate: NSPredicate = {
    return NSPredicate(format: "%K > %@", #keyPath(Note.noteDateCreated), lastYear)
  }()
  
  //MARK: Sort Predicates
  lazy var nameSortDescriptor: NSSortDescriptor = {
    let compareSelector = #selector(NSString.localizedStandardCompare(_:))
    return NSSortDescriptor(key: #keyPath(Goal.goalTitle), ascending: true, selector: compareSelector)
  }()
  
  lazy var dateSortDescriptor: NSSortDescriptor = {
    let dateSelectror = #selector(NSDate.compare(_:))
    return NSSortDescriptor(key: #keyPath(Goal.goalDateCreated), ascending: true, selector: dateSelectror)
  }()
  

  override func viewDidLoad() {
    super.viewDidLoad()
    
    populateGoalCategoryLabel()
    populateTodoCategoryLabel()
    populateFixCategoryLabel()
    populatePastYearLabel()
    populatePastMonthLabel()
    populatePastWeekLabel()
    populateTodayLabel()
    populateAllLabel()
  }
}
  
  // MARK: - Table view data source
extension FilterViewController {
  
  @IBAction func search(_ sender: UIBarButtonItem) {
    delegate?.filterViewController(filter: self, didSelectPredicate: selectedPredicate, sortDescriptor: selectedSortDescriptor)
    dismiss(animated: true)
  }
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    
    guard let cell = tableView.cellForRow(at: indexPath) else {
      return
    }
    switch cell {
    case goalKeywordCell:
      selectedPredicate = goalKeywordPredicate
    case todoKeywordCell:
      selectedPredicate = todoKeywordPredicate
    case fixKeywordCell:
      selectedPredicate = fixKeywordPredicate
    case yearCell:
      selectedPredicate = pastYearGoalPredicate
    case monthCell:
      selectedPredicate = pastMonthGoalPredicate
    case weekCell:
      selectedPredicate = pastWeekGoalPredicate
    case todayCell:
      selectedPredicate = pastDayGoalPredicate
    case allCell:
      selectedPredicate = allGoalPredicate
    case goalAZSortCell:
      selectedSortDescriptor = nameSortDescriptor
    case goalZASortCell:
      selectedSortDescriptor = nameSortDescriptor.reversedSortDescriptor as? NSSortDescriptor
    case dateOldNewCell:
      selectedSortDescriptor = dateSortDescriptor
    case dateNewOldCell:
      selectedSortDescriptor = dateSortDescriptor.reversedSortDescriptor as? NSSortDescriptor
    default:
      break
    }
    cell.accessoryType = .checkmark
  }
  
  func populateGoalCategoryLabel() {
    let goalFetchRequest = NSFetchRequest<NSNumber>(entityName: "Goal")
    goalFetchRequest.resultType = .countResultType
    goalFetchRequest.predicate = goalKeywordPredicate
    
    do {
      let countResult = try CoreDataController.sharedManager.persistentContainer.viewContext.fetch(goalFetchRequest)
      
      let count = countResult.first!.intValue
      let pluralized = count == 1 ? "item" : "items"
      goalCategoryLabel.text = "\(count) Goal \(pluralized)"
    } catch let error as NSError {
      print("count not fetched \(error), \(error.userInfo)")
    }
  }
  
  func populateTodoCategoryLabel() {
    let goalFetchRequest = NSFetchRequest<NSNumber>(entityName: "Goal")
    goalFetchRequest.resultType = .countResultType
    goalFetchRequest.predicate = todoKeywordPredicate
    
    do {
      let countResult = try CoreDataController.sharedManager.persistentContainer.viewContext.fetch(goalFetchRequest)
      
      let count = countResult.first!.intValue
      let pluralized = count == 1 ? "item" : "items"
      todoCategoryLabel.text = "\(count) To Do \(pluralized)"
    } catch let error as NSError {
      print("count not fetched \(error), \(error.userInfo)")
    }
  }
  
  func populateFixCategoryLabel() {
    let goalFetchRequest = NSFetchRequest<NSNumber>(entityName: "Goal")
    goalFetchRequest.resultType = .countResultType
    goalFetchRequest.predicate = fixKeywordPredicate
    
    do {
      let countResult = try CoreDataController.sharedManager.persistentContainer.viewContext.fetch(goalFetchRequest)
      
      let count = countResult.first!.intValue
      let pluralized = count == 1 ? "item" : "items"
      todoCategoryLabel.text = "\(count) To Do \(pluralized)"
    } catch let error as NSError {
      print("count not fetched \(error), \(error.userInfo)")
    }
  }
  
  func populatePastYearLabel() {
    let goalFetchRequest = NSFetchRequest<NSNumber>(entityName: "Goal")
    goalFetchRequest.resultType = .countResultType
    goalFetchRequest.predicate = pastYearGoalPredicate
    
    do {
      let countResult = try CoreDataController.sharedManager.persistentContainer.viewContext.fetch(goalFetchRequest)
      
      let count = countResult.first!.intValue
      let pluralized = count == 1 ? "Goal" : "Goals"
      todoCategoryLabel.text = "\(count) \(pluralized)"
    } catch let error as NSError {
      print("count not fetched \(error), \(error.userInfo)")
    }
  }
  
  func populatePastMonthLabel() {
    let goalFetchRequest = NSFetchRequest<NSNumber>(entityName: "Goal")
    goalFetchRequest.resultType = .countResultType
    goalFetchRequest.predicate = pastMonthGoalPredicate
    
    do {
      let countResult = try CoreDataController.sharedManager.persistentContainer.viewContext.fetch(goalFetchRequest)
      
      let count = countResult.first!.intValue
      let pluralized = count == 1 ? "Goal" : "Goals"
      todoCategoryLabel.text = "\(count) \(pluralized)"
    } catch let error as NSError {
      print("count not fetched \(error), \(error.userInfo)")
    }
  }
  
  func populatePastWeekLabel() {
    let goalFetchRequest = NSFetchRequest<NSNumber>(entityName: "Goal")
    goalFetchRequest.resultType = .countResultType
    goalFetchRequest.predicate = pastWeekGoalPredicate
    
    do {
      let countResult = try CoreDataController.sharedManager.persistentContainer.viewContext.fetch(goalFetchRequest)
      
      let count = countResult.first!.intValue
      let pluralized = count == 1 ? "Goal" : "Goals"
      todoCategoryLabel.text = "\(count) \(pluralized)"
    } catch let error as NSError {
      print("count not fetched \(error), \(error.userInfo)")
    }
  }
  
  func populateTodayLabel() {
    let goalFetchRequest = NSFetchRequest<NSNumber>(entityName: "Goal")
    let createdAtDescriptor = NSSortDescriptor(keyPath: \Goal.goalDateCreated, ascending: false)
    goalFetchRequest.resultType = .countResultType
    goalFetchRequest.predicate = nil // pastDayGoalPredicate
    goalFetchRequest.sortDescriptors = [createdAtDescriptor]
    goalFetchRequest.fetchLimit = 1
    
    
    do {
      let countResult = try CoreDataController.sharedManager.persistentContainer.viewContext.fetch(goalFetchRequest)
      
      let count = countResult.first!.intValue
      let pluralized = count == 1 ? "Goal" : "Goals"
      todoCategoryLabel.text = "\(count) \(pluralized)"
    } catch let error as NSError {
      print("count not fetched \(error), \(error.userInfo)")
    }
  }
  
  func populateAllLabel() {
    let goalFetchRequest = NSFetchRequest<NSNumber>(entityName: "Goal")
    goalFetchRequest.resultType = .countResultType
    goalFetchRequest.predicate = nil // allGoalPredicate
    goalFetchRequest.fetchLimit = 0
    
    do {
      let countResult = try CoreDataController.sharedManager.persistentContainer.viewContext.fetch(goalFetchRequest)
      
      let count = countResult.first!.intValue
      let pluralized = count == 1 ? "Goal" : "Goals"
      todoCategoryLabel.text = "\(count) \(pluralized)"
    } catch let error as NSError {
      print("count not fetched \(error), \(error.userInfo)")
    }
  }
  
}

