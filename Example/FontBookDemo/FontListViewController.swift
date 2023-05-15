import UIKit
import FontBook

class FontListViewController: ViewController {
  let fontBook = FontBook()
  
  override func setUp() {
    super.setUp()
    title = "Font Book"
    navigationItem.leftBarButtonItem = UIBarButtonItem(
      image: UIImage(systemName: "info.circle"),
      style: .plain, target: self, action: #selector(onAbout)
    )
    
    navigationItem.rightBarButtonItem = UIBarButtonItem(
      image: UIImage(systemName: "square.and.arrow.down"),
      style: .plain, target: self, action: #selector(onAddFont)
    )
    tableVw.dataSource = self
    tableVw.delegate = self
  }
  
  @objc func onAddFont() {
    showAlert(title: "Enter font name") { alert in
      alert.addTextField()
      alert.addAction(UIAlertAction(title: "Download", style: .default, handler: { action in
        if let fontName = alert.textFields?.first?.text {
          self.addFont(named: fontName)
        }
      }))
    }
  }
  
  @objc func onAbout() {
    showHelp(
      title: "About",
      message: "View and download fonts.\n\nNot all fonts provided by Apple are available on iOS."
    )
  }
  
  private func showHelp(title: String, message: String) {
    let urlStr = "https://developer.apple.com/fonts/system-fonts/"
    showAlert(
      title: title,
      message: "\(message)\n\nTo see all possible values use the Font Book.app on Mac or visit this link \(urlStr)"
    ) { alert in
      alert.addAction(UIAlertAction(title: "Visit link", style: .default, handler: { _ in
        if let url = URL(string: urlStr) {
          UIApplication.shared.open(url)
        }
      }))
    }
  }
  
  private func addFont(named fontName: String) {
    fontBook.downloadFont(named: fontName) { isSaved in
      if isSaved {
        self.tableVw.reloadData()
      } else {
        self.showHelp(
          title: "\(fontName) not found!",
          message: "Note font display name is not always the font name.\n\nFor example, 'Al Bayan' is 'AlBayan'"
        )
      }
    }
  }
  
  private var allfontFamilyNames: [[String]] {
    return [fontBook.downloadedFontFamilyNames, fontBook.systemFontFamilyNames]
  }
}

extension FontListViewController: UITableViewDataSource {
  func numberOfSections(in tableView: UITableView) -> Int {
    return 2
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return allfontFamilyNames[section].count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell: UITableViewCell
    if let cachedCell = tableView.dequeueReusableCell(withIdentifier: "kCellId") {
      cell = cachedCell
    } else {
      cell = UITableViewCell(style: .subtitle, reuseIdentifier: "kCellId")
    }

    let fontFamilyName = allfontFamilyNames[indexPath.section][indexPath.row]
    cell.textLabel?.text = fontFamilyName
    cell.detailTextLabel?.font = fontBook.fontNames(forFamilyNamed: fontFamilyName).first.flatMap { fontBook.font(named: $0) }
    cell.detailTextLabel?.text = "\(fontBook.fontNames(forFamilyNamed: fontFamilyName).count) styles"
    cell.accessoryType = .disclosureIndicator
    return cell
  }
  
  func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    return ["Downloaded Fonts", "System Fonts"][section]
  }
}

extension FontListViewController: UITableViewDelegate {
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let fontFamilyName = allfontFamilyNames[indexPath.section][indexPath.row]
    let detailVwCtrl = FontDetailViewController(fontFamilyName: fontFamilyName, fontBook: fontBook)
    navigationController?.pushViewController(detailVwCtrl, animated: true)
    tableView.deselectRow(at: indexPath, animated: true)
  }
}

