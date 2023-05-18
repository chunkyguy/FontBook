import Foundation

public class FontInfo {
  public let name: String
  public let family: String
  public internal(set) var isInstalled: Bool
  
  public init(name: String, family: String, isInstalled: Bool) {
    self.name = name
    self.family = family
    self.isInstalled = isInstalled
  }
}

public class FontBook {
  
  private let store = FontStore()
  
  public var fonts: [FontInfo] { store.fonts }
  
  public init() {}
  
  public var allFamilyNames: [String] {
    return store.registeredFamilyNames
  }
}

#if canImport(UIKit)
import UIKit

public struct FontResponse {
  public let request: String
  public let font: UIFont
  public let isMatching: Bool
}

extension FontBook {
  public var installedFamilyNames: [String] {
    return UIFont.familyNames
  }

  public func font(named name: String, size: CGFloat = 12) -> UIFont? {
    guard let font = UIFont(name: name, size: size) else {
      return nil
    }
    store.installFont(name: font.fontName, family: font.familyName)
    return font
  }
  
  public func font(named fontName: String, size: CGFloat = 12, completion: @escaping (FontResponse) -> Void) {
    if let font = font(named: fontName, size: size) {
      print("FontBook::font: found \(fontName)")
      completion(FontResponse(request: fontName, font: font, isMatching: true))
      return
    }
    
    print("FontBook::font: fetching \(fontName) ...")
    store.findFont(named: fontName) { response in
      completion(self.fontResponseWithInfo(response: response, size: size))
    }
  }

  private func fontResponseWithInfo(response: FontInfoResponse, size: CGFloat) -> FontResponse {
    guard let font = UIFont(name: response.request, size: size) else {
      print("FontBook::fontResponseWithInfo: \(response.request) => Missing")
      return FontResponse(
        request: response.request,
        font: UIFont.systemFont(ofSize: size),
        isMatching: false
      )
    }
    
    print("FontBook::fontResponseWithInfo: \(response.request) => \(font.fontName) \(font.familyName)")
    return FontResponse(request: response.request, font: font, isMatching: response.isMatching)
  }

  public func fontNames(forFamilyNamed family: String) -> [String] {
    let names = UIFont.fontNames(forFamilyName: family)
    names.forEach { name in
      store.installFont(name: name, family: family)
    }
    return names
  }
}
#endif
