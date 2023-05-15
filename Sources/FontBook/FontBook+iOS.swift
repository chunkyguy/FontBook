#if canImport(UIKit)
import UIKit

extension FontBook {
  public func font(named fontName: String, size: CGFloat = 12) -> UIFont? {
    return UIFont(name: fontName, size: size)
  }
  
  public func font(named fontName: String, size: CGFloat = 12, completion: @escaping (UIFont) -> Void) {
    if let font = font(named: fontName, size: size) {
      completion(font)
      return
    }
    
    downloadFont(named: fontName) { _ in
      let f = self.font(named: fontName, size: size) ?? UIFont.systemFont(ofSize: size)
      completion(f)
    }
  }

  public func fontNames(forFamilyNamed familyName: String) -> [String] {
    return UIFont.fontNames(forFamilyName: familyName)
  }
}
#endif
