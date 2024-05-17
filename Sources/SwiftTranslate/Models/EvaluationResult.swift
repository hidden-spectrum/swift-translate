//
//  EvaluationResult.swift
//
//
//  Created by Jonas Bromö on 2024-05-17.
//

import Foundation

public struct EvaluationResult {
    let quality: TranslationQuality
    let explanation: String
}

public enum TranslationQuality {
    case good, poor, bad

    var description: String {
        switch self {
        case .good:
            "✅ Good"
        case .poor:
            "⚠️ Poor"
        case .bad:
            "🚨 Bad"
        }
    }
}
