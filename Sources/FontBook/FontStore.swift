import Foundation
import CoreText

extension CFArray {
  func asStrings() -> [String] {
    (0..<CFArrayGetCount(self))
      .map { CFArrayGetValueAtIndex(self, $0) }
      .map { unsafeBitCast($0, to: CFString.self) }
      .map { $0 as String }
  }
}

public struct FontInfoResponse {
  public let request: String
  public let info: FontInfo
  public let isMatching: Bool
}

class FontStore {

  var registeredFamilyNames: [String] {
    let families = Set(fonts.map({ $0.family }))
    return Array(families).sorted()
  }

  private(set) var fonts: [FontInfo]
  
  init() {
    self.fonts = FontList.allKnownFonts
    // update list for pre-installed fonts
    let preInstalledFontFamilies = CTFontManagerCopyAvailableFontFamilyNames().asStrings()
    for family in preInstalledFontFamilies {
      for font in fonts where font.family == family {
        font.isInstalled = true
      }
    }
  }
  
  func installFont(name: String, family: String) {
    if let font = findFontInfo(name: name, family: family) {
      font.isInstalled = true
    } else {
      fonts.append(FontInfo(name: name, family: family, isInstalled: true))
    }
  }
  
  private func findFontInfo(name: String, family: String) -> FontInfo? {
    return fonts.first { $0.name == name && $0.family == family }
  }
  
  func findFont(named fontName: String, completion: @escaping (FontInfoResponse) -> Void) {
    let attrs = NSDictionary(object: fontName, forKey: kCTFontNameAttribute as NSString)
    let desc = CTFontDescriptorCreateWithAttributes(attrs as CFDictionary)
    let descs = [desc]
    CTFontDescriptorMatchFontDescriptorsWithProgressHandler(descs as CFArray, nil) { state, info in
      if state == .didFailWithError {
        print("FontStore::findFont error: \(info as NSDictionary)")
      }
      else if state == .didFinish {
        DispatchQueue.main.async {
          completion(self.findFontMatchingName(fontName))
        }
      }
      return true
    }
  }
  
  private func findFontMatchingName(_ fontOrFamily: String) -> FontInfoResponse {
    let font = CTFontCreateWithName(fontOrFamily as CFString, 0, nil)
    let name = CTFontCopyPostScriptName(font) as String
    let family = CTFontCopyFamilyName(font) as String

//    if let fontURL = CTFontCopyAttribute(font, kCTFontURLAttribute) as? NSURL {
//      print("FontStore::findFontMatchingName: \(fontURL)")
//    }
    
    // CTFontCreateWithName always creates a font with fallback to system fonts
    // so we need to validate if the font is correct
    let isMatching = fontOrFamily == name || fontOrFamily == family
    let info = FontInfo(name: name, family: family, isInstalled: true)
    if isMatching {
      installFont(name: name, family: family)
    }
    return FontInfoResponse(request: fontOrFamily, info: info, isMatching: isMatching)
  }
}
