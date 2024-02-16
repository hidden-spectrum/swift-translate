//
//  Copyright © 2024 Hidden Spectrum, LLC.
//

import Foundation


extension Array where Element == LocalizableString {
    func sourceKeyLookup(matchingKind kind: LocalizableString.Kind) throws -> String {
        let filteredResults = filter { $0.kind == kind }
        guard let sourceLocalizableString = filteredResults.first else {
            throw SourceKeyLookupError.notFound
        }
        guard filteredResults.count == 1 else {
            throw SourceKeyLookupError.multipleFound
        }
        return sourceLocalizableString.sourceKey
    }
}

enum SourceKeyLookupError: Error {
    case notFound
    case multipleFound
}
