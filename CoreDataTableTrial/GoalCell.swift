//
//  GoalCell.swift
//  CoreDataTableTrial
//
//  Created by Scott Bolin on 5/30/20.
//  Copyright © 2020 Scott Bolin. All rights reserved.
//

import UIKit

class GoalCell: UITableViewCell {
  
  public static let reuseIdentifier = "GoalCell"
  
  //MARK: - IBOutlets
  @IBOutlet weak var goalTitleLabel: UILabel!
  @IBOutlet weak var dayCreatedLabel: UILabel!
  @IBOutlet weak var monthCreatedLabel: UILabel!
  @IBOutlet weak var completedButton: UIButton!
  
  
  //MaRK: - View lifecycle
  override func awakeFromNib() {
    super.awakeFromNib()
    completedButton.isEnabled = false
  }
  //MARK: - Helper function
  func configureGoalCell(at indexPath: IndexPath, for goal: Goal) {
    
    let dayFormatter = DateFormatter()
    let monthFormatter = DateFormatter()
    dayFormatter.dateFormat = "dd"
    monthFormatter.dateFormat = "MMM"
    goalTitleLabel.text = goal.goalTitle + " (\(indexPath.section) / \(indexPath.row))"
    dayCreatedLabel.text = dayFormatter.string(from: goal.goalDateCreated)
    monthCreatedLabel.text = monthFormatter.string(from: goal.goalDateCreated)
    completedButton.isSelected = goal.goalCompleted
    
    toggleButtonColor()
  }
  
  func toggleButtonColor() {
    completedButton.isSelected ? (completedButton.tintColor = .systemGreen) :
      (completedButton.tintColor = .systemGray6)
  }
}
