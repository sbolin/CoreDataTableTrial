//
//  GoalViewDelegate.swift
//  CoreDataTableTrial
//
//  Created by Scott Bolin on 6/1/20.
//  Copyright © 2020 Scott Bolin. All rights reserved.
//

import UIKit

class GoalViewDelegate: NSObject, UITableViewDelegate {
  
  let fetchController = CoreDataController.sharedManager.fetchedGoalResultsController
  
  //MARK: - UITableViewDelegate Methods
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 56
  }
  
  func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    return 36
  }


}
