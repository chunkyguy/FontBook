import UIKit
import FontBook

class FontListViewController: ListViewController, UITableViewDataSource, UITableViewDelegate  {
  private static let cellId = "kFontListViewCellId"
  
  let fontBook: FontBook
  private var downloadedFontFamilyNames: [String]
  private let systemFontFamilyNames: [String]
  
  init(fontBook: FontBook) {
    self.fontBook = fontBook
    self.systemFontFamilyNames = fontBook.installedFamilyNames
    self.downloadedFontFamilyNames = []
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError()
  }
  
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
    let fontInstallListVwCtrl = FontInstallerViewController(fontBook: fontBook)
    fontInstallListVwCtrl.delegate = self
    let navCtrl = UINavigationController(rootViewController: fontInstallListVwCtrl)
    present(navCtrl, animated: true)
    
  }
  
  @objc func onAbout() {
    showHelp(
      title: "About",
      message: "View and download fonts.\n\nNot all fonts provided by Apple are available on iOS."
    )
  }
  
  private var allfontFamilyNames: [[String]] {
    return [downloadedFontFamilyNames, systemFontFamilyNames]
  }

  // MARK: - UITableViewDataSource -
  func numberOfSections(in tableView: UITableView) -> Int {
    return 2
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return allfontFamilyNames[section].count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell: UITableViewCell
    if let cachedCell = tableView.dequeueReusableCell(withIdentifier: Self.cellId) {
      cell = cachedCell
    } else {
      cell = UITableViewCell(style: .subtitle, reuseIdentifier: Self.cellId)
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

  // MARK: - UITableViewDelegate -
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let fontFamilyName = allfontFamilyNames[indexPath.section][indexPath.row]
    let detailVwCtrl = FontDetailViewController(fontFamilyName: fontFamilyName, fontBook: fontBook)
    navigationController?.pushViewController(detailVwCtrl, animated: true)
    tableView.deselectRow(at: indexPath, animated: true)
  }
}

extension FontListViewController: FontInstallerViewControllerDelegate {
  func fontInstallerViewController(
    vwCtrl: FontInstallerViewController,
    didInstallFontNamed fontName: String, family: String) {
      downloadedFontFamilyNames.append(family)
      tableVw.reloadData()
      vwCtrl.dismiss(animated: true)
  }
}
