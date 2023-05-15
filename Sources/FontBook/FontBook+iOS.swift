#if canImport(UIKit)
import UIKit

extension FontBook {
  public func font(named fontName: String, size: CGFloat = 12) -> UIFont? {
    return UIFont(name: fontName, size: size)
  }

  public func fontNames(forFamilyNamed familyName: String) -> [String] {
    return UIFont.fontNames(forFamilyName: familyName)
  }
}
#endif
