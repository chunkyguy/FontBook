import Foundation
import CoreText

private extension CFArray {
  func cast<T>() -> [T] {
    (0..<CFArrayGetCount(self))
      .map { CFArrayGetValueAtIndex(self, $0) }
      .map { unsafeBitCast($0, to: T.self) }
  }
}

public class FontBook {
  public private(set) var systemFontFamilyNames: [String] = []
  public private(set) var downloadedFontFamilyNames: [String] = [] {
    didSet { downloadedFontFamilyNames.sort() }
  }

  public init() {
    let cfNames: [CFString] = CTFontManagerCopyAvailableFontFamilyNames().cast()
    systemFontFamilyNames = cfNames.map { $0 as String }.sorted()
  }
  
  private func _font(named fontName: String, size: CGFloat = 12) -> CTFont? {
    let font = CTFontCreateWithName(fontName as CFString, size, nil)
    // CTFontCreateWithName always creates a font with fallback to system fonts
    // so we need to validate if the font is correct
    let name = CTFontCopyPostScriptName(font) as String
    let familyName = CTFontCopyFamilyName(font) as String
    if fontName == name || fontName == familyName {
      return font
    }
    return nil
  }
  
  public func downloadFont(named fontName: String, completion: @escaping (Bool) -> Void) {
    if _font(named: fontName) != nil {
      completion(true)
      return
    }

    let attrs = NSMutableDictionary()
    // Create a dictionary with the font's PostScript name.
    attrs.setObject(fontName, forKey: kCTFontNameAttribute as NSString)

    // Create a new font descriptor reference from the attributes dictionary.
    let desc = CTFontDescriptorCreateWithAttributes(attrs as CFDictionary)
    
    let descs = [desc]

    CTFontDescriptorMatchFontDescriptorsWithProgressHandler(descs as CFArray, nil) { state, _ in
      self.handleState(fontName: fontName, state: state, completion: completion)
      return true
    }
  }
  
  private func handleState(fontName: String, state: CTFontDescriptorMatchingState, completion: @escaping (Bool) -> Void) {
    guard case .didFinish = state else {
      return
    }

    DispatchQueue.main.async {
      if let newFont = self._font(named: fontName) {
        let familyName = CTFontCopyFamilyName(newFont) as String
        self.downloadedFontFamilyNames.append(familyName)
        completion(true)
      } else {
        completion(false)
      }
    }
  }
}
