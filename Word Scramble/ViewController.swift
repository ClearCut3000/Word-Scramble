//
//  ViewController.swift
//  Word Scramble
//
//  Created by Николай Никитин on 12.12.2021.
//

import UIKit

class ViewController: UITableViewController {

  //MARK: - Properties
  var allWords = [String]()
  var usedWords = [String]()


  //MARK: - ViewController Lifecycle
  override func viewDidLoad() {
    super.viewDidLoad()

    navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(promtForAnswer))
    navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(startGame))

    if let startWordsURL = Bundle.main.url(forResource: "start", withExtension: "txt"){
      if let startWords = try? String (contentsOf: startWordsURL){
        allWords = startWords.components(separatedBy: "\n")
      }
    } else {
      if allWords.isEmpty {
        allWords = ["silkworm"]
      }
    }
    startGame()
  }

  // MARK: - Methods
  @objc func startGame () {
    title = allWords.randomElement()
    usedWords.removeAll(keepingCapacity: true)
    tableView.reloadData()
  }

  @objc func promtForAnswer(){
    let alertController = UIAlertController(title: "Please, enter answer.", message: nil, preferredStyle: .alert)
    alertController.addTextField()
    let submitAction = UIAlertAction(title: "Submit", style: .default) {
      [weak self, weak alertController] action in
      guard let answer = alertController?.textFields?[0].text else { return }
      self?.submit(answer)
    }
    alertController.addAction(submitAction)
    present(alertController, animated: true)
  }

  func showErrorMessage(errorTitle: String, errorMessage: String){
    let alertController = UIAlertController(title: errorTitle, message: errorMessage, preferredStyle: .alert)
    alertController.addAction(UIAlertAction(title: "Ok", style: .default))
    present(alertController, animated: true)
  }

  func submit(_ answer: String) {
    let lowerAnswer = answer.lowercased()
    if isPossible(word: lowerAnswer){
      if isOriginal(word: lowerAnswer){
        if isReal(word: lowerAnswer){
          usedWords.insert(answer.lowercased(), at: 0)
          // animates new cell appirance
          let indexPath = IndexPath(row: 0, section: 0)
          tableView.insertRows(at: [indexPath], with: .automatic)
        } else {
          showErrorMessage(errorTitle: "Слово не распознано", errorMessage: "Ты не можешь просто выдумать их, ты же знаешь!")
        }
      } else {
        showErrorMessage(errorTitle: "Слово уже использовано!", errorMessage: "Будьте оригинальнее!")
      }
    } else {
      showErrorMessage(errorTitle: "Слово невозможно!", errorMessage: "Ты не можешь произнести это слово по буквам с \(title!.lowercased())")
    }
  }

  // Checking for valid answers
  func isPossible(word: String) -> Bool {
    if word.lowercased() == title?.lowercased() {
      return false
    } else {
      guard var tempWord = title?.lowercased() else { return false }
      for letter in word {
        if let position = tempWord.firstIndex(of: letter){
          tempWord.remove(at: position)
        } else{
          return false
        }
      }
      return true
    }
  }

  func isOriginal(word: String) -> Bool {
    return !usedWords.contains(word.lowercased())
  }

  func isReal(word: String) -> Bool {
    if word.utf16.count <= 3 {
      return false
    } else {
      //    class that is designed to spot spelling errors
      let checker = UITextChecker()
      //    used to store a string range, which is a value that holds a start position and a length
      let range = NSRange(location: 0, length: word.utf16.count)
      let misspelledRange = checker.rangeOfMisspelledWord(in : word, range: range, startingAt: 0, wrap: false, language: "ru")
      return misspelledRange.location == NSNotFound
    }
  }

  //MARK: - TableView Methods
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return usedWords.count
  }

  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "Word", for: indexPath)
    cell.textLabel?.text = usedWords[indexPath.row]
    return cell
  }
}

