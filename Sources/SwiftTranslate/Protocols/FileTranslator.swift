//
//  Copyright © 2024 Hidden Spectrum, LLC.
//

import Foundation
import SwiftStringCatalog


protocol FileTranslator {
    var service: TranslationService { get }
    var targetLanguages: Set<Language>? { get }
    var overwrite: Bool { get }
    var skipConfirmations: Bool { get }
    var verbose: Bool { get }
    
    func translate(fileAt fileUrl: URL) async throws
}
