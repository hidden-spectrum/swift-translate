//
//  EvaluationService.swift
//
//
//  Created by Jonas Bromö on 2024-05-17.
//

import Foundation
import SwiftStringCatalog


public protocol EvaluationService {

    func evaluateQuality(
        _ string: String,
        translation: String,
        in targetLanguage: Language,
        comment: String?
    ) async throws -> EvaluationResult

}
