import UIKit

class ViewController: UIViewController {
  
  private var isSetUp = false
  lazy var tableVw = UITableView(frame: view.bounds, style: .grouped)

  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    if !isSetUp {
      isSetUp = true
      setUp()
    }
  }
  
  func setUp() {
    view.addSubview(tableVw)
    tableVw.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      tableVw.leftAnchor.constraint(equalTo: view.leftAnchor),
      tableVw.rightAnchor.constraint(equalTo: view.rightAnchor),
      tableVw.bottomAnchor.constraint(equalTo: view.bottomAnchor),
      tableVw.topAnchor.constraint(equalTo: view.topAnchor)
    ])
  }
  
  func showAlert(
    title: String,
    message: String? = nil,
    configure: ((UIAlertController) -> Void)? = nil
  ) {
    let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
    configure?(alert)
    alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
    present(alert, animated: true)
  }
}
