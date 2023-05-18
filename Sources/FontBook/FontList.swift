import Foundation
import CoreText

private struct Typeface: Codable {
  let name: String?
  let copyProtected: String?
  let copyright: String?
  let designer: String?
  let duplicate: String?
  let embeddable: String?
  let enabled: String?
  let family: String?
  let fullname: String?
  let outline: String?
  let style: String?
  let unique: String?
  let valid: String?
  let vendor: String?
  let version: String?
  
  enum CodingKeys: String, CodingKey {
    case name = "_name"
    case copyProtected = "copy_protected"
    case copyright
    case designer
    case duplicate
    case embeddable
    case enabled
    case family
    case fullname
    case outline
    case style
    case unique
    case valid
    case vendor
    case version
  }
}

private struct SPFontsDataType: Codable {
  let name: String?
  let enabled: String?
  let path: String?
  let type: String?
  let typefaces: [Typeface]
  let valid: String?

  enum CodingKeys: String, CodingKey {
    case name = "_name"
    case enabled
    case path
    case type
    case typefaces
    case valid
  }
}

private struct SPFontsDataTypeList: Codable {
  let fonts: [SPFontsDataType]
  
  enum CodingKeys: String, CodingKey {
    case fonts = "SPFontsDataType"
  }
}

struct FontList {
  static var allKnownFonts: [FontInfo] {
    guard let fontsURL = Bundle.module.url(forResource: "fonts", withExtension: "json") else {
      return []
    }

    do {
      let fileContent = try String(contentsOf: fontsURL)
      guard let fileData = fileContent.data(using: .utf8) else { return [] }
      let list = try JSONDecoder().decode(SPFontsDataTypeList.self, from: fileData)
      
      var infoList: [FontInfo] = []
      for font in list.fonts {
        for typeface in font.typefaces {
          if let name = typeface.name, let family = typeface.family {
            let info = FontInfo(name: name, family: family, isInstalled: false)
            infoList.append(info)
          }
        }
      }
      return infoList
    } catch {
      return []
    }
  }
}
