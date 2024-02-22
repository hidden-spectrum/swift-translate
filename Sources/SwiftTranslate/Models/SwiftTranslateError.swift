//
//  Copyright © 2024 Hidden Spectrum, LLC.
//

import Foundation


enum SwiftTranslateError: Error {
    case couldNotSearchDirectoryAt(URL)
    case noTranslationReturned
    case noTranslatableFilesFoundAt(URL)
}
