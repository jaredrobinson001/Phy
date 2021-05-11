//  Created by dasdom on 26.07.19.
//  
//

import UIKit

class SolverDetailViewController: UITableViewController, UITextFieldDelegate {

  let tool: SolverTool
  var results: [String] = []
  var inputs: [String]
  var buttonEnabled = false
  var currentTextField: UITextField?
  
  init(tool: SolverTool) {
    
    self.tool = tool
    
    inputs = Array(repeating: "", count: tool.inputs.count)
    
    super.init(style: .grouped)
  }
  
  required init?(coder aDecoder: NSCoder) { fatalError() }

  override func viewDidLoad() {
    super.viewDidLoad()

    title = tool.title?.localized
    
    tableView.register(SolverDetailImageCell.self, forCellReuseIdentifier: SolverDetailImageCell.identifier)
    tableView.register(SolverDetailInputCell.self, forCellReuseIdentifier: SolverDetailInputCell.identifier)
    tableView.register(SolverDetailButtonCell.self, forCellReuseIdentifier: SolverDetailButtonCell.identifier)
    tableView.register(SolverDetailResultCell.self, forCellReuseIdentifier: SolverDetailResultCell.identifier)
  }
  
  // MARK: UITableViewDataSource
  override func numberOfSections(in tableView: UITableView) -> Int {
    return 4
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    
    switch section {
    case 0, 2: return 1
    case 1: return tool.inputs.count
    case 3: return tool.results.count
    default: return 0
    }
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
    let cell: UITableViewCell
    switch indexPath.section {
    case 0:
      let imageCell = SolverDetailImageCell(style: .default, reuseIdentifier: nil)
      
      imageCell.update(with: tool)
      
      cell = imageCell
      
    case 1:
      let inputCell = SolverDetailInputCell(style: .default, reuseIdentifier: nil)
      
      inputCell.update(with: tool.inputs[indexPath.row])
      inputCell.textField.tag = indexPath.row
      inputCell.textField.delegate = self
      inputCell.textField.text = inputs[indexPath.row]
      inputCell.textField.returnKeyType = .next
      
      if 0 == indexPath.row {
        inputCell.textField.becomeFirstResponder()
      } else if tool.inputs.count - 1 == indexPath.row {
        inputCell.textField.returnKeyType = .done
      }
      
      cell = inputCell
      
    case 2:
      let buttonCell = SolverDetailButtonCell(style: .default, reuseIdentifier: nil)
      
      buttonCell.button.addTarget(self, action: #selector(SolverDetailViewController.calculate), for: .touchUpInside)
      buttonCell.button.isEnabled = buttonEnabled
      
      cell = buttonCell
      
    case 3:
      let resultCell = SolverDetailResultCell(style: .default, reuseIdentifier: nil)
      
      resultCell.update(with: tool.results[indexPath.row])
      
      if indexPath.row < results.count {
        let toolResult = tool.results[indexPath.row]
        var formulaString = toolResult.formula
        
        for (idx, input) in tool.inputs.enumerated() {
          let userInput = inputs[idx]
          formulaString = formulaString.replacingOccurrences(of: "#\(input.id)", with: userInput)
        }
        resultCell.resultLabel.text = "= \(formulaString)\n= " + results[indexPath.row]
      }
      
      cell = resultCell
      
    default:
      cell = UITableViewCell()
    }
    
    return cell
  }
  
  override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    let title: String?
    switch section {
    case 0:
      title = "Formel".localized
    case 1:
      title = "Eingabe".localized
    case 3:
      title = "Ergebnis".localized
    default:
      title = nil
    }
    return title
  }
  
  // MARK: - UITextFieldDelegate
  func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
    
    currentTextField = textField

    return true
  }
  
  func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {

    currentTextField = textField
    
    if let text = textField.text {
      let newString = (text as NSString).replacingCharacters(in: range, with: string)
      
      inputs[textField.tag] = newString
      
      buttonEnabled = inputs.reduce(true, { result, input -> Bool in
        return result && (input.count > 0)
      })
      tableView.reloadSections([2], with: .none)
    }
    return true
  }
  
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    
    let numberOfRowsInInputSection = tableView.numberOfRows(inSection: 1)
    var textFieldFound = false
    for i in 0..<numberOfRowsInInputSection {
      guard let cell = tableView.cellForRow(at: IndexPath(row: i, section: 1)) as? SolverDetailInputCell else { return false }
      
      if true == textFieldFound {
        cell.textField.becomeFirstResponder()
        return false
      } else if cell.textField == textField {
        textFieldFound = true
      }
    }
    
    if true == textFieldFound {
      textField.resignFirstResponder()
      calculate()
    }
    
    return false
  }
  
  // MARK: -
  @objc func calculate() {
    
    currentTextField?.resignFirstResponder()
    
    let calculatable = inputs.reduce(true, { result, input -> Bool in
      return result && (input.count > 0)
    })
    if false == calculatable {
      return
    }
    
    results = []

    for result in tool.results {

      var formulaString = result.formula

      for (idx, input) in tool.inputs.enumerated() {
        let userInput = inputs[idx]
        formulaString = formulaString.replacingOccurrences(of: "#\(input.id)", with: userInput)
      }

      print("formulaString: \(formulaString)")
      let result = Legacy_Calculator().calculate(formulaString)
      results.append(Legacy_Calculator.string(fromResult: result))
    }
    
    tableView.reloadSections([3], with: .fade)
  }
}

extension SolverDetailViewController: SolverInputAccessoryViewProtocol {
  func addE() {
    addStringIfPossible("e")
  }
  
  func togglePlusMinus() {
    if let textField = currentTextField, let text = textField.text {
      if text.first == "-" {
        textField.text = String(text.dropFirst())
      } else {
        textField.text = "-" + text
      }
    }
  }
  
  func next() {
    let numberOfRowsInInputSection = tableView.numberOfRows(inSection: 1)
    var textFieldFound = false
    for i in 0..<numberOfRowsInInputSection {
      guard let cell = tableView.cellForRow(at: IndexPath(row: i, section: 1)) as? SolverDetailInputCell else { return }
      
      if true == textFieldFound {
        cell.textField.becomeFirstResponder()
        return
      } else if cell.textField == currentTextField {
        textFieldFound = true
      }
    }
    
    if true == textFieldFound {
      currentTextField?.resignFirstResponder()
      calculate()
    }
  }
  
  private func addStringIfPossible(_ string: String) {
    if let textField = currentTextField, let text = textField.text {
      textField.text = text + string
    }
  }
}
