//
//  Copyright © 2024-2025 Hidden Spectrum, LLC.
//


public struct TranslationResponse: Codable {
    
    /// The translated text.
    let translation: String
    
    /// For LLM based translators, this indicates whether the input was ambiguous.
    let inputAmbiguous: Bool
    
    /// The reason for the ambiguity, if any.
    let ambiguityReason: String?
    
    // MARK: Lifecycle
    
    init(_ translation: String, inputAmbiguous: Bool = false, ambiguityReason: String? = nil) {
        self.translation = translation
        self.inputAmbiguous = inputAmbiguous
        self.ambiguityReason = ambiguityReason
    }
}
