//  Created by dasdom on 08.08.19.
//  
//

import UIKit

class FormulaDetailViewController: UITableViewController {
  
  let formula: Formula
  
  init(formula: Formula) {
    
    self.formula = formula
    
    super.init(style: .grouped)
  }
  
  required init?(coder aDecoder: NSCoder) { fatalError() }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    tableView.register(FormulaDetailCell.self, forCellReuseIdentifier: FormulaDetailCell.identifier)
    tableView.register(FormulaDetailWithTextCell.self, forCellReuseIdentifier: FormulaDetailWithTextCell.identifier)
  }
  
  // MARK: - Table view data source
  
  override func numberOfSections(in tableView: UITableView) -> Int {
    return formula.details?.count ?? 0
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return formula.details?[section].detailItems.count ?? 0
  }
  
  override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    
    guard let title = formula.details?[section].title else {
      return nil
    }
    return NSLocalizedString(title, comment: "")
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
    guard let detailItem = formula.details?[indexPath.section].detailItems[indexPath.row] else {
      return UITableViewCell()
    }
    
    let cell: DDHBaseTableViewCell<FormulaDetailItem>?
    if detailItem.title?.contains("Abk") ?? false {
      cell = tableView.dequeueReusableCell(withIdentifier: FormulaDetailWithTextCell.identifier, for: indexPath) as? DDHBaseTableViewCell<FormulaDetailItem>
    } else {
      cell = tableView.dequeueReusableCell(withIdentifier: FormulaDetailCell.identifier, for: indexPath) as? DDHBaseTableViewCell<FormulaDetailItem>
    }
    
    cell?.update(with: detailItem)
    
    if let inputs = detailItem.inputs, let results = detailItem.results, inputs.count > 0, results.count > 0 {
      cell?.accessoryType = .disclosureIndicator
    }
    
    return cell ?? UITableViewCell()
  }
  
  // MARK: - UITableViewDelegate
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    
    guard let detailItem = formula.details?[indexPath.section].detailItems[indexPath.row] else {
      return
    }
    
    guard let inputs = detailItem.inputs else { return }
    guard let results = detailItem.results else { return }
    
    let solver = SolverTool(title: detailItem.title, imageName: detailItem.imageName, inputs: inputs, results: results)
    let next = SolverDetailViewController(tool: solver)
    
    navigationController?.pushViewController(next, animated: true)
  }
}
