//
//  Copyright © 2026 Hidden Spectrum, LLC.
//

@testable import SwiftStringCatalog

import Foundation

enum TestResources {
    static let appShortcutsCatalog = Bundle.module.url(forResource: "AppShortcutsCatalog", withExtension: "json")!
    static let basicCatalog = Bundle.module.url(forResource: "BasicCatalog", withExtension: "json")!
    static let deviceCatalog = Bundle.module.url(forResource: "DeviceCatalog", withExtension: "json")!
    static let metadataCatalog = Bundle.module.url(forResource: "MetadataCatalog", withExtension: "json")!
    static let pluralCatalog = Bundle.module.url(forResource: "PluralCatalog", withExtension: "json")!
}

struct TemporaryDirectory {
    let url: URL
    
    init(prefix: String = "SwiftStringCatalogTests") throws {
        url = FileManager.default.temporaryDirectory
            .appendingPathComponent("\(prefix)-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
    }
    
    func file(named name: String, pathExtension: String) -> URL {
        url.appendingPathComponent(name).appendingPathExtension(pathExtension)
    }
    
    func cleanup() {
        try? FileManager.default.removeItem(at: url)
    }
}

struct LocalizableStringSnapshot: Comparable, Equatable {
    let kind: String
    let sourceKey: String
    let targetLanguage: String
    let translatedValue: String?
    let state: TranslationState
    
    init(_ localizableString: LocalizableString) {
        self.kind = Self.describe(localizableString.kind)
        self.sourceKey = localizableString.sourceKey
        self.targetLanguage = localizableString.targetLanguage.rawValue
        self.translatedValue = localizableString.translatedValue
        self.state = localizableString.state
    }
    
    static func < (lhs: LocalizableStringSnapshot, rhs: LocalizableStringSnapshot) -> Bool {
        let lhsTuple = (lhs.targetLanguage, lhs.kind, lhs.sourceKey, lhs.translatedValue ?? "", lhs.state.rawValue)
        let rhsTuple = (rhs.targetLanguage, rhs.kind, rhs.sourceKey, rhs.translatedValue ?? "", rhs.state.rawValue)
        return lhsTuple < rhsTuple
    }
    
    private static func describe(_ kind: LocalizableString.Kind) -> String {
        switch kind {
        case .standalone:
            return "standalone"
        case .stringSet(let index):
            return "stringSet:\(index)"
        case .variation(.device(let deviceCategory)):
            return "variation:device:\(deviceCategory.rawValue)"
        case .variation(.plural(let pluralQualifier)):
            return "variation:plural:\(pluralQualifier.rawValue)"
        case .replacement(let replacement):
            let variationDescription: String
            if let variation = replacement.variation {
                switch variation {
                case .device(let deviceCategory):
                    variationDescription = "device:\(deviceCategory.rawValue)"
                case .plural(let pluralQualifier):
                    variationDescription = "plural:\(pluralQualifier.rawValue)"
                }
            } else {
                variationDescription = "none"
            }
            return "replacement:\(replacement.argNumber):\(replacement.formatSpecifier):\(variationDescription)"
        }
    }
}

func snapshots(_ localizableStrings: [LocalizableString]) -> [LocalizableStringSnapshot] {
    localizableStrings.map(LocalizableStringSnapshot.init).sorted()
}
