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
    return NSPredicate(format: "%K CONTAINS[cd] %@", #keyPath(Goal.goalTitle), "goal")
  }()
  
  lazy var noteKeywordPredicate: NSPredicate = {
    return NSPredicate(format: "%K CONTAINS[cd] %@", #keyPath(Note.noteText), "goal")
  }()
  
  lazy var todoGoalKeywordPredicate: NSPredicate = {
    let goalPredicate1 = NSPredicate(format: "%K CONTAINS[cd] %@", #keyPath(Goal.goalTitle),"todo")
    let goalPredicate2 = NSPredicate(format: "%K CONTAINS[cd] %@", #keyPath(Goal.goalTitle),"to do")
    return NSCompoundPredicate(type: .or, subpredicates: [goalPredicate1, goalPredicate2]) as NSPredicate
  }()
  
  lazy var todoNoteKeywordPredicate: NSPredicate = {
    let notePredicate1 = NSPredicate(format: "%K CONTAINS[cd] %@", #keyPath(Note.noteText),"todo")
    let notePredicate2 = NSPredicate(format: "%K CONTAINS[cd] %@", #keyPath(Note.noteText),"to do")
    return NSCompoundPredicate(type: .or, subpredicates: [notePredicate1, notePredicate2]) as NSPredicate
  }()
  
  lazy var fixGoalKeywordPredicate: NSPredicate = {
    return NSPredicate(format: "%K CONTAINS[cd] %@", #keyPath(Goal.goalTitle), "fix")
  }()
  
  lazy var fixNoteKeywordPredicate: NSPredicate = {
    return NSPredicate(format: "%K CONTAINS[cd] %@", #keyPath(Note.noteText), "fix")
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

// MARK: - IBActions
extension FilterViewController {
  
  @IBAction func search(_ sender: UIBarButtonItem) {
    delegate?.filterViewController(filter: self, didSelectPredicate: selectedPredicate, sortDescriptor: selectedSortDescriptor)
    dismiss(animated: true)
  }
  
  @IBAction func unwindToVenueListViewController(_ segue: UIStoryboardSegue) {
  }
}
 
// MARK - UITableViewDelegate
extension FilterViewController {
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    
    guard let cell = tableView.cellForRow(at: indexPath) else {
      return
    }
    switch cell {
    case goalKeywordCell:
      selectedPredicate = goalKeywordPredicate
    case todoKeywordCell:
      selectedPredicate = todoGoalKeywordPredicate
    case fixKeywordCell:
      selectedPredicate = fixGoalKeywordPredicate
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
    var labelText: String = ""
    
    let goalFetchRequest = NSFetchRequest<NSNumber>(entityName: "Goal")
    goalFetchRequest.resultType = .countResultType
    goalFetchRequest.predicate = goalKeywordPredicate
    
    do {
      let goalCountResult = try CoreDataController.shared.managedContext.fetch(goalFetchRequest)
      let goalCount = goalCountResult.first!.intValue
      let goalPluralized = goalCount == 1 ? "Goal" : "Goals"
      labelText = "\(goalCount) \(goalPluralized) / "
    } catch let error as NSError {
      print("count not fetched \(error), \(error.userInfo)")
    }
    
    let noteFetchRequest = NSFetchRequest<NSNumber>(entityName: "Note")
    noteFetchRequest.resultType = .countResultType
    noteFetchRequest.predicate = noteKeywordPredicate
    
    do {
      let noteCountResult = try CoreDataController.shared.managedContext.fetch(noteFetchRequest)
      let noteCount = noteCountResult.first!.intValue
      let notePluralized = noteCount == 1 ? "Item" : "Items"
      labelText += "\(noteCount) \(notePluralized)"
    } catch let error as NSError {
      print("count not fetched \(error), \(error.userInfo)")
    }
    goalCategoryLabel.text = labelText
  }
  
  func populateTodoCategoryLabel() {
    var labelText: String = ""
    
    let goalFetchRequest = NSFetchRequest<NSNumber>(entityName: "Goal")
    goalFetchRequest.resultType = .countResultType
    goalFetchRequest.predicate = todoGoalKeywordPredicate
    
    do {
      let goalCountResult = try CoreDataController.shared.managedContext.fetch(goalFetchRequest)
      let goalCount = goalCountResult.first!.intValue
      let goalPluralized = goalCount == 1 ? "Goal" : "Goals"
      labelText = "\(goalCount) \(goalPluralized) / "
    } catch let error as NSError {
      print("count not fetched \(error), \(error.userInfo)")
    }
    
    let noteFetchRequest = NSFetchRequest<NSNumber>(entityName: "Note")
    noteFetchRequest.resultType = .countResultType
    noteFetchRequest.predicate = todoNoteKeywordPredicate
    
    do {
      let noteCountResult = try CoreDataController.shared.managedContext.fetch(noteFetchRequest)
      let noteCount = noteCountResult.first!.intValue
      let notePluralized = noteCount == 1 ? "Item" : "Items"
      labelText += "\(noteCount) \(notePluralized)"
    } catch let error as NSError {
      print("count not fetched \(error), \(error.userInfo)")
    }
    todoCategoryLabel.text = labelText
  }
  
  func populateFixCategoryLabel() {
    var labelText: String = ""

    let goalFetchRequest = NSFetchRequest<NSNumber>(entityName: "Goal")
    goalFetchRequest.resultType = .countResultType
    goalFetchRequest.predicate = fixGoalKeywordPredicate
    
    do {
      let goalCountResult = try CoreDataController.shared.managedContext.fetch(goalFetchRequest)
      let goalCount = goalCountResult.first!.intValue
      let goalPluralized = goalCount == 1 ? "Goal" : "Goals"
      labelText = "\(goalCount) \(goalPluralized) / "
    } catch let error as NSError {
      print("count not fetched \(error), \(error.userInfo)")
    }
    
    let noteFetchRequest = NSFetchRequest<NSNumber>(entityName: "Note")
    noteFetchRequest.resultType = .countResultType
    noteFetchRequest.predicate = fixNoteKeywordPredicate
    
    do {
      let noteCountResult = try CoreDataController.shared.managedContext.fetch(noteFetchRequest)
      let noteCount = noteCountResult.first!.intValue
      let notePluralized = noteCount == 1 ? "Item" : "Items"
      labelText += "\(noteCount) \(notePluralized)"
    } catch let error as NSError {
      print("count not fetched \(error), \(error.userInfo)")
    }
    fixCategoryLabel.text = labelText
  }
  
  func populatePastYearLabel() {
    var labelText: String = ""
    
    let goalFetchRequest = NSFetchRequest<NSNumber>(entityName: "Goal")
    goalFetchRequest.resultType = .countResultType
    goalFetchRequest.predicate = pastYearGoalPredicate
    
    do {
      let goalCountResult = try CoreDataController.shared.managedContext.fetch(goalFetchRequest)
      let goalCount = goalCountResult.first!.intValue
      let goalPluralized = goalCount == 1 ? "Goal" : "Goals"
      labelText = "\(goalCount) \(goalPluralized) / "
    } catch let error as NSError {
      print("count not fetched \(error), \(error.userInfo)")
    }
    
    let noteFetchRequest = NSFetchRequest<NSNumber>(entityName: "Note")
    noteFetchRequest.resultType = .countResultType
    noteFetchRequest.predicate = pastYearNotePredicate
    
    do {
      let noteCountResult = try CoreDataController.shared.managedContext.fetch(noteFetchRequest)
      let noteCount = noteCountResult.first!.intValue
      let notePluralized = noteCount == 1 ? "Item" : "Items"
      labelText += "\(noteCount) \(notePluralized)"
    } catch let error as NSError {
      print("count not fetched \(error), \(error.userInfo)")
    }
    pastYearLabel.text = labelText
  }
  
  func populatePastMonthLabel() {
    var labelText: String = ""

    let goalFetchRequest = NSFetchRequest<NSNumber>(entityName: "Goal")
    goalFetchRequest.resultType = .countResultType
    goalFetchRequest.predicate = pastMonthGoalPredicate
    
    do {
      let goalCountResult = try CoreDataController.shared.managedContext.fetch(goalFetchRequest)
      let goalCount = goalCountResult.first!.intValue
      let goalPluralized = goalCount == 1 ? "Goal" : "Goals"
      labelText = "\(goalCount) \(goalPluralized) / "
    } catch let error as NSError {
      print("count not fetched \(error), \(error.userInfo)")
    }
      
    let noteFetchRequest = NSFetchRequest<NSNumber>(entityName: "Note")
    noteFetchRequest.resultType = .countResultType
    noteFetchRequest.predicate = pastMonthNotePredicate
      
    do {
      let noteCountResult = try CoreDataController.shared.managedContext.fetch(noteFetchRequest)
      let noteCount = noteCountResult.first!.intValue
      let notePluralized = noteCount == 1 ? "Item" : "Items"
      labelText += "\(noteCount) \(notePluralized)"
    } catch let error as NSError {
      print("count not fetched \(error), \(error.userInfo)")
    }
    pastMonthLabel.text = labelText
  }
  
  func populatePastWeekLabel() {
    var labelText: String = ""
    
    let goalFetchRequest = NSFetchRequest<NSNumber>(entityName: "Goal")
    goalFetchRequest.resultType = .countResultType
    goalFetchRequest.predicate = pastWeekGoalPredicate
    
    do {
      let goalCountResult = try CoreDataController.shared.managedContext.fetch(goalFetchRequest)
      let goalCount = goalCountResult.first!.intValue
      let goalPluralized = goalCount == 1 ? "Goal" : "Goals"
      labelText = "\(goalCount) \(goalPluralized) / "
    } catch let error as NSError {
      print("count not fetched \(error), \(error.userInfo)")
    }
    
    let noteFetchRequest = NSFetchRequest<NSNumber>(entityName: "Note")
    noteFetchRequest.resultType = .countResultType
    noteFetchRequest.predicate = pastWeekNotePredicate
    
    do {
      let noteCountResult = try CoreDataController.shared.managedContext.fetch(noteFetchRequest)
      let noteCount = noteCountResult.first!.intValue
      let notePluralized = noteCount == 1 ? "Item" : "Items"
      labelText += "\(noteCount) \(notePluralized)"
    } catch let error as NSError {
      print("count not fetched \(error), \(error.userInfo)")
    }
    pastWeekLabel.text = labelText
  }
  
  func populateTodayLabel() {
    let goalFetchRequest = NSFetchRequest<Goal>(entityName: "Goal")
    let createdAtDescriptor = NSSortDescriptor(keyPath: \Goal.goalDateCreated, ascending: false)
    goalFetchRequest.predicate = nil // pastDayGoalPredicate
    goalFetchRequest.sortDescriptors = [createdAtDescriptor]
    goalFetchRequest.fetchLimit = 1
    
    do {
      let result = try CoreDataController.shared.managedContext.fetch(goalFetchRequest)
      let count = result.first!.notes.count
      let pluralized = count == 1 ? "Item" : "Items"
      todoCategoryLabel.text = "1 Goal / \(count) \(pluralized)"
    } catch let error as NSError {
      print("count not fetched \(error), \(error.userInfo)")
    }
  }
  
  func populateAllLabel() {
    var labelText: String = ""
    
    let goalFetchRequest = NSFetchRequest<NSNumber>(entityName: "Goal")
    goalFetchRequest.resultType = .countResultType
    goalFetchRequest.predicate = nil // allGoalPredicate
    goalFetchRequest.fetchLimit = 0
    
    do {
      let goalCountResult = try CoreDataController.shared.managedContext.fetch(goalFetchRequest)
      let goalCount = goalCountResult.first!.intValue
      let goalPluralized = goalCount == 1 ? "Goal" : "Goals"
      labelText = "\(goalCount) \(goalPluralized) / "
    } catch let error as NSError {
      print("count not fetched \(error), \(error.userInfo)")
    }
    
    let noteFetchRequest = NSFetchRequest<NSNumber>(entityName: "Note")
    noteFetchRequest.resultType = .countResultType
    noteFetchRequest.predicate = nil // allGoalPredicate
    noteFetchRequest.fetchLimit = 0
    
    do {
      let noteCountResult = try CoreDataController.shared.managedContext.fetch(noteFetchRequest)
      let noteCount = noteCountResult.first!.intValue
      let notePluralized = noteCount == 1 ? "Item" : "Items"
      labelText += "\(noteCount) \(notePluralized)"
    } catch let error as NSError {
      print("count not fetched \(error), \(error.userInfo)")
    }
    allLabel.text = labelText
  }
  
}

