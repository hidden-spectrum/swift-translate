//
//  Copyright © 2024 Hidden Spectrum, LLC.
//

import Foundation


extension Array where Element == LocalizableString {
    func sourceValueLookup(matchingKind kind: LocalizableString.Kind) throws -> String {
        let filteredResults = filter { $0.kind == kind }
        guard let sourceLocalizableString = filteredResults.first else {
            throw SourceValueLookupError.notFound
        }
        guard filteredResults.count == 1 else {
            throw SourceValueLookupError.multipleFound
        }
        return sourceLocalizableString.sourceValue
    }
}

enum SourceValueLookupError: Error {
    case notFound
    case multipleFound
}
