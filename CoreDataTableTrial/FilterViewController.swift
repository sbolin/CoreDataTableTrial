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
  let last6Month = Date().addingTimeInterval(-60 * 60 * 24 * 183) as NSDate
  let lastYear = Date().addingTimeInterval(-60 * 60 * 24 * 365) as NSDate
  let allTime = Date().addingTimeInterval(-60 * 60 * 24 * 365 * 10) as NSDate // 10 year to show all notes.
  
  
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
  
  lazy var todoKeywordPredicate: NSPredicate = {
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
  
  lazy var past6MonthGoalPredicate: NSPredicate = {
    return NSPredicate(format: "%K > %@", #keyPath(Goal.goalDateCreated), last6Month)
  }()
  
  lazy var pastYearGoalPredicate: NSPredicate = {
    return NSPredicate(format: "%K > %@", #keyPath(Goal.goalDateCreated), lastYear)
  }()
  
  lazy var goalCompletedPredicate: NSPredicate = {
    return NSPredicate(format: "%K = %d", #keyPath(Goal.goalCompleted), true)
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
  
  lazy var past6MonthNotePredicate: NSPredicate = {
    return NSPredicate(format: "%K > %@", #keyPath(Note.noteDateCreated), last6Month)
  }()
  
  lazy var pastYearNotePredicate: NSPredicate = {
    return NSPredicate(format: "%K > %@", #keyPath(Note.noteDateCreated), lastYear)
  }()
  
  lazy var noteCompletedPredicate: NSPredicate = {
    return NSPredicate(format: "%K = %d", #keyPath(Note.noteCompleted), true)
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
    populateLabels()

  }
  func populateLabels() {
    var firstLabel: String = ""
    var secondLabel: String = ""
    var thirdLabel: String = ""
    var fourthLabel: String = ""
    
//    populateGoalCategoryLabel()
    guard let goalGoalCount = getEntityCount(for: "Goal", with: goalKeywordPredicate) else { return }
    guard let goalItemCount = getEntityCount(for: "Note", with: noteKeywordPredicate) else { return }
    firstLabel = makeLabel(count: goalGoalCount, quantifier: "Goal")
    secondLabel = makeContinuingLabel(firstLabel: firstLabel, count: goalItemCount, quantifier: "Item")
    goalCategoryLabel.text = secondLabel
    
//    populateTodoCategoryLabel()
    guard let todoGoalCount = getEntityCount(for: "Goal", with: todoGoalKeywordPredicate) else { return }
    guard let todoItemCount = getEntityCount(for: "Note", with: todoKeywordPredicate) else { return }
    firstLabel = makeLabel(count: todoGoalCount, quantifier: "Goal")
    secondLabel = makeContinuingLabel(firstLabel: firstLabel, count: todoItemCount, quantifier: "Item")
    todoCategoryLabel.text = secondLabel
    
//    populateFixCategoryLabel()
    guard let fixGoalCount = getEntityCount(for: "Goal", with: fixGoalKeywordPredicate) else { return }
    guard let fixItemCount = getEntityCount(for: "Note", with: fixNoteKeywordPredicate) else { return }
    firstLabel = makeLabel(count: fixGoalCount, quantifier: "Goal")
    secondLabel = makeContinuingLabel(firstLabel: firstLabel, count: fixItemCount, quantifier: "Item")
    fixCategoryLabel.text = secondLabel
    
//    populatePastYearLabel()
    guard let yearGoalCount = getEntityCount(for: "Goal", with: pastYearGoalPredicate) else { return }
    guard let yearItemCount = getEntityCount(for: "Note", with: pastYearNotePredicate) else { return }
    firstLabel = makeLabel(count: yearGoalCount, quantifier: "Goal")
    secondLabel = makeContinuingLabel(firstLabel: firstLabel, count: yearItemCount, quantifier: "Item")
    
    let yearGoalCompletedPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [pastYearGoalPredicate, goalCompletedPredicate])
    let yearItemCompletedPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [pastYearNotePredicate, noteCompletedPredicate])
    
    guard let doneYearGoalCount = getEntityCount(for: "Goal", with: yearGoalCompletedPredicate) else { return }
    guard let doneYearItemCount = getEntityCount(for: "Note", with: yearItemCompletedPredicate) else { return }
    thirdLabel = makeLabel(count: doneYearGoalCount, quantifier: "Goal")
    fourthLabel = makeContinuingLabel(firstLabel: thirdLabel, count: doneYearItemCount, quantifier: "Item")
    pastYearLabel.text = secondLabel + " " + fourthLabel + " Completed"
    
 //   populatePastMonthLabel()
    guard let monthGoalCount = getEntityCount(for: "Goal", with: pastMonthGoalPredicate) else { return }
    guard let monthItemCount = getEntityCount(for: "Note", with: pastMonthNotePredicate) else { return }
    firstLabel = makeLabel(count: monthGoalCount, quantifier: "Goal")
    secondLabel = makeContinuingLabel(firstLabel: firstLabel, count: monthItemCount, quantifier: "Item")
    
    let monthGoalCompletedPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [pastMonthGoalPredicate, goalCompletedPredicate])
    let monthItemCompletedPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [pastMonthNotePredicate, noteCompletedPredicate])
    
    guard let doneMonthGoalCount = getEntityCount(for: "Goal", with: monthGoalCompletedPredicate) else { return }
    guard let doneMonthItemCount = getEntityCount(for: "Note", with: monthItemCompletedPredicate) else { return }
    thirdLabel = makeLabel(count: doneMonthGoalCount, quantifier: "Goal")
    fourthLabel = makeContinuingLabel(firstLabel: thirdLabel, count: doneMonthItemCount, quantifier: "Item")
    pastMonthLabel.text = secondLabel + " " + fourthLabel + " Completed"
    
//    populatePastWeekLabel()
    guard let weekGoalCount = getEntityCount(for: "Goal", with: pastWeekGoalPredicate) else { return }
    guard let weekItemCount = getEntityCount(for: "Note", with: pastWeekNotePredicate) else { return }
    firstLabel = makeLabel(count: weekGoalCount, quantifier: "Goal")
    secondLabel = makeContinuingLabel(firstLabel: firstLabel, count: weekItemCount, quantifier: "Item")
    
    let weekGoalCompletedPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [pastWeekGoalPredicate, goalCompletedPredicate])
    let weekItemCompletedPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [pastWeekNotePredicate, noteCompletedPredicate])
    
    guard let doneWeekGoalCount = getEntityCount(for: "Goal", with: weekGoalCompletedPredicate) else { return }
    guard let doneWeekItemCount = getEntityCount(for: "Note", with: weekItemCompletedPredicate) else { return }
    thirdLabel = makeLabel(count: doneWeekGoalCount, quantifier: "Goal")
    fourthLabel = makeContinuingLabel(firstLabel: thirdLabel, count: doneWeekItemCount, quantifier: "Item")
    pastWeekLabel.text = secondLabel + " " + fourthLabel + " Completed"
    
    populateTodayLabel()

    //    populateAllLabel()
    guard let allGoalCount = getEntityCount(for: "Goal", with: allGoalPredicate) else { return }
    guard let allItemCount = getEntityCount(for: "Note", with: allNotePredicate) else { return }
    firstLabel = makeLabel(count: allGoalCount, quantifier: "Goal")
    secondLabel = makeContinuingLabel(firstLabel: firstLabel, count: allItemCount, quantifier: "Item")

    guard let doneGoalCount = getEntityCount(for: "Goal", with: goalCompletedPredicate) else { return }
    guard let doneItemCount = getEntityCount(for: "Note", with: noteCompletedPredicate) else { return }
    thirdLabel = makeLabel(count: doneGoalCount, quantifier: "Goal")
    fourthLabel = makeContinuingLabel(firstLabel: thirdLabel, count: doneItemCount, quantifier: "Item")
    allLabel.text = secondLabel + " " + fourthLabel + " Completed"
  }
}

// MARK: - IBActions
extension FilterViewController {
  
  @IBAction func search(_ sender: UIBarButtonItem) {
    delegate?.filterViewController(filter: self, didSelectPredicate: selectedPredicate, sortDescriptor: selectedSortDescriptor)
    dismiss(animated: true)
  }
  
  @IBAction func unwindToGoalViewController(_ segue: UIStoryboardSegue) {

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
  
  // Typically Count Case
  func getEntityCount(for entityName: String, with predicate: NSPredicate) -> Int? {
    let goalFetchRequest = NSFetchRequest<NSNumber>(entityName: entityName)
    
    goalFetchRequest.predicate = nil
    goalFetchRequest.fetchLimit = 0
    
    goalFetchRequest.resultType = .countResultType
    goalFetchRequest.predicate = predicate
    
    do {
      let countResult = try CoreDataController.shared.managedContext.fetch(goalFetchRequest)
      return countResult.first!.intValue
    } catch let error as NSError {
      print("count not fetched \(error), \(error.userInfo)")
      return nil
    }
  }
  
  // Goal count label
  func makeLabel(count: Int, quantifier: String) -> String {
    let quantifierPluralized = count == 1 ? quantifier : "\(quantifier)s"
    return "\(count) \(quantifierPluralized)"
  }
  
  // Note count label
  func makeContinuingLabel(firstLabel: String, count: Int, quantifier: String) -> String {
    let quantifierPluralized = count == 1 ? quantifier : "\(quantifier)s"
    return firstLabel + " / \(count) \(quantifierPluralized)"
  }
  
  // Special Case Labels
  func populateTodayLabel() {
    let goalFetchRequest = NSFetchRequest<Goal>(entityName: "Goal")
    let createdAtDescriptor = NSSortDescriptor(keyPath: \Goal.goalDateCreated, ascending: false)
    goalFetchRequest.predicate = nil // pastDayGoalPredicate
    goalFetchRequest.sortDescriptors = [createdAtDescriptor]
    goalFetchRequest.fetchLimit = 1
    
    do {
      let result = try CoreDataController.shared.managedContext.fetch(goalFetchRequest)
      let count = result.first!.notes.count
      let pluralized = count == 1 ? "Task" : "Tasks"
      todayLabel.text = "1 Goal / \(count) \(pluralized)"
    } catch let error as NSError {
      print("count not fetched \(error), \(error.userInfo)")
    }
  }
  
}

