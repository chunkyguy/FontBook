import UIKit
import FontBook

protocol FontInstallerViewControllerDelegate: AnyObject {
  func fontInstallerViewController(
    vwCtrl: FontInstallerViewController,
    didInstallFontNamed fontName: String,
    family: String
  )
}

class FontInstallerViewController: ListViewController, UITableViewDataSource, UITableViewDelegate  {
  private static let cellId = "kInstallerViewCellId"

  let fontBook: FontBook
  weak var delegate: FontInstallerViewControllerDelegate?
  
  private var list: [FontInfo]
  
  init(fontBook: FontBook) {
    self.fontBook = fontBook
    self.list = fontBook.fonts.sorted(by: { l, r in l.name < r.name })
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError()
  }
  
  override func setUp() {
    super.setUp()
    self.title = "Fonts"
    navigationItem.rightBarButtonItem = UIBarButtonItem(
      image: UIImage(systemName: "keyboard"),
      style: .plain, target: self, action: #selector(onShowKeyboard)
    )

    tableVw.dataSource = self
    tableVw.delegate = self
  }
  
  @objc func onShowKeyboard() {
    showAlert(title: "Enter font name") { alert in
      alert.addTextField()
      alert.addAction(UIAlertAction(title: "Download", style: .default, handler: { action in
        if let fontName = alert.textFields?.first?.text {
          self.addFont(named: fontName)
        }
      }))
    }
  }
  
  private func addFont(named fontName: String) {
    fontBook.font(named: fontName) {
      self.handleResponse($0)
    }
  }
  
  private func handleResponse(_ response: FontResponse) {
    guard response.isMatching else {
      showHelp(
        title: "\(response.request) not found!",
        message: "Note font display name is not always the font name.\n\nFor example, 'Al Bayan' is 'AlBayan'"
      )
      return
    }
    
    self.list = fontBook.fonts.sorted(by: { l, r in l.name < r.name })
    tableVw.reloadData()
    
    delegate?.fontInstallerViewController(
      vwCtrl: self,
      didInstallFontNamed: response.font.fontName,
      family: response.font.familyName
    )
  }
  
  // MARK: - UITableViewDataSource -
  func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return list.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell: UITableViewCell
    if let cachedCell = tableView.dequeueReusableCell(withIdentifier: Self.cellId) {
      cell = cachedCell
    } else {
      cell = UITableViewCell(style: .subtitle, reuseIdentifier: Self.cellId)
    }

    let info = list[indexPath.row]
    cell.textLabel?.text = info.name
    cell.detailTextLabel?.text = info.family
    cell.accessoryType = info.isInstalled ? .checkmark : .none
    
    return cell
  }

  // MARK: - UITableViewDelegate -
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let info = list[indexPath.row]
    if !info.isInstalled {
      addFont(named: info.name)
    }
    
    tableView.deselectRow(at: indexPath, animated: true)
  }
}
