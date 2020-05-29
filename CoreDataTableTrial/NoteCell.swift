//
//  NoteCell.swift
//  CoreDataTableTrial
//
//  Created by Scott Bolin on 5/27/20.
//  Copyright © 2020 Scott Bolin. All rights reserved.
//

import UIKit

protocol NoteCellDelegate {
  func noteCell(_ cell: NoteCell, completionChanged completion: Bool)
}

class NoteCell: UITableViewCell {
  
  //MARK:- Properties
  public static let reuseIdentifier = "NoteCell"
  var delegate: NoteCellDelegate?
  
  //MARK: - IBOutlets
  @IBOutlet weak var goalTitleLabel: UILabel!
  @IBOutlet weak var noteTextLabel: UILabel!
  @IBOutlet weak var dayCreatedLabel: UILabel!
  @IBOutlet weak var monthCreatedLabel: UILabel!
  @IBOutlet weak var completedButton: UIButton!
  
  
  //MARK: - View lifecycle
  override func awakeFromNib() {
    super.awakeFromNib()
  }
  
  //MARK: - Helper function
  func configure(for goal: Goal) {
    let dayFormatter = DateFormatter()
    let monthFormatter = DateFormatter()
    dayFormatter.dateFormat = "dd"
    monthFormatter.dateFormat = "MMM"
    
    goalTitleLabel.text = goal.goalTitle
    noteTextLabel.text = goal.value(forKeyPath: #keyPath(Goal.notes.noteText)) as? String
    dayCreatedLabel.text = dayFormatter.string(from: goal.goalDateCreated)
    monthCreatedLabel.text = monthFormatter.string(from: goal.goalDateCreated)
    handleCompletionCheck(is: goal.goalCompleted)
  }
  
  func handleCompletionCheck(is completed: Bool) {
    if completed {
      completedButton.tintColor = .systemGreen
    } else {
      completedButton.tintColor = .systemGray6
    }
  }
  
  //MARK: - IBAction
  @IBAction func completedTapped(_ sender: UIButton) {
    completedButton.isSelected.toggle()
    let completion = completedButton.isSelected
    handleCompletionCheck(is: completion)
    delegate?.noteCell(self, completionChanged: completion)
  }
}
