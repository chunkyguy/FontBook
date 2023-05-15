import UIKit
import FontBook

class FontDetailViewController: ViewController {
  private static let sampleTextKey = "kSampleText"
  private let fontFamilyName: String
  private let fontBook: FontBook
  private let fontNames: [String]
  
  private var sampleText: String {
    let text = UserDefaults.standard.string(forKey: Self.sampleTextKey)
    if let text, !text.isEmpty { return text }
    
    return [
      "The quick brown fox jumps over the lazy dog.".lowercased(),
      "The quick brown fox jumps over the lazy dog.".uppercased()
    ].joined(separator: "\n\n")
  }
  
  init(fontFamilyName: String, fontBook: FontBook) {
    self.fontFamilyName = fontFamilyName
    self.fontBook = fontBook
    self.fontNames = fontBook.fontNames(forFamilyNamed: fontFamilyName)
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError()
  }

  override func setUp() {
    super.setUp()
    title = fontFamilyName
    navigationItem.rightBarButtonItem = UIBarButtonItem(
      image: UIImage(systemName: "square.and.pencil"),
      style: .plain, target: self, action: #selector(onChangeSampleText)
    )
    tableVw.dataSource = self
    tableVw.delegate = self
  }
  
  @objc func onChangeSampleText() {
    showAlert(title: "Change Text") { alert in
      alert.addTextField()
      alert.addAction(UIAlertAction(title: "Save", style: .default, handler: { action in
        UserDefaults.standard.set(alert.textFields?.first?.text, forKey: Self.sampleTextKey)
        self.tableVw.reloadData()
      }))
    }
  }
}

extension FontDetailViewController: UITableViewDataSource {
  func numberOfSections(in tableView: UITableView) -> Int {
    return fontNames.count
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return 1
  }
  
  func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    return fontNames[section]
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell: UITableViewCell
    if let cachedCell = tableView.dequeueReusableCell(withIdentifier: "kDetailCellId") {
      cell = cachedCell
    } else {
      cell = UITableViewCell(style: .default, reuseIdentifier: "kDetailCellId")
    }

    cell.textLabel?.text = "Error loading!"
    cell.textLabel?.numberOfLines = 0
    cell.textLabel?.font = UIFont.systemFont(ofSize: 12)

    if let font = fontBook.font(named: fontNames[indexPath.section]) {
      cell.textLabel?.text = sampleText
      cell.textLabel?.font = font
    }
    
    return cell
  }
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 128
  }
}

extension FontDetailViewController: UITableViewDelegate {
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
  }
}
