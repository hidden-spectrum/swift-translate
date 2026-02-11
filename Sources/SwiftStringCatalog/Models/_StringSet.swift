//
//  Copyright © 2024 Hidden Spectrum, LLC.
//

import Foundation


struct _StringSet: Codable {
    
    // MARK: Internal
    
    var state: TranslationState
    var values: [String]
}

extension _StringSet: LocalizableStringConstructor {
    func constructLocalizableStrings(with context: LocalizableStringConstructionContext) throws -> [LocalizableString] {
        let sourceKeyLookup: [Int: String] = {
            let sourceValues = context.sourceLanguageStrings.compactMap { localizableString -> (Int, String)? in
                guard case .stringSet(let index) = localizableString.kind else {
                    return nil
                }
                return (index, localizableString.sourceKey)
            }
            return Dictionary(uniqueKeysWithValues: sourceValues)
        }()
        
        return values.enumerated().map { index, value in
            let kind = LocalizableString.Kind.stringSet(index: index)
            let sourceKey = context.isSource ? value : (sourceKeyLookup[index] ?? value)
            return LocalizableString(
                kind: kind,
                sourceKey: sourceKey,
                targetLanguage: context.targetLanguage,
                translatedValue: value,
                state: state
            )
        }
    }
}

extension _StringSet {
    mutating func addValue(_ value: String, at index: Int, state: TranslationState) {
        if values.count <= index {
            values.append(contentsOf: Array(repeating: "", count: index - values.count + 1))
        }
        values[index] = value
        self.state = _StringSet.mergeState(current: self.state, next: state)
    }
    
    private static func mergeState(current: TranslationState, next: TranslationState) -> TranslationState {
        let priority: [TranslationState] = [.needsReview, .new, .stale, .translated]
        let currentIndex = priority.firstIndex(of: current) ?? priority.count
        let nextIndex = priority.firstIndex(of: next) ?? priority.count
        return currentIndex <= nextIndex ? current : next
    }
}
