//
//  Copyright © 2024 Hidden Spectrum, LLC.
//

import Foundation
import Rainbow


struct Log {
    
    enum Level: String {
        case unimportant
        case info
        case warning
        case error
        case success
        
        func format(_ message: String) -> String {
            switch self {
            case .unimportant: message.dim
            case .info: message
            case .warning: "⚠️ " + message.yellow
            case .error: "❗️ " + message.red
            case .success: "✅ " + message.green
            }
        }
    }
    
    enum Newline {
        case none
        case before
        case after
        case both
        
        var prefix: String {
            switch self {
            case .none, .after: return ""
            case .before, .both: return "\n"
            }
        }
        var suffix: String {
            switch self {
            case .none, .before: return ""
            case .after, .both: return "\n"
            }
        }
    }
    
    // MARK: Basic
    
    static func unimportant(newline: Newline = .none, _ message: String...) {
        _log(newline, .unimportant, message.joined())
    }
    
    static func info(newline: Newline = .none, _ message: String...) {
        _log(newline, .info, message.joined())
    }
    
    static func warning(newline: Newline = .none, _ message: String...) {
        _log(newline, .warning, message.joined())
    }
    
    static func error(newline: Newline = .none, _ message: String...) {
        _log(newline, .error, message.joined())
    }
    
    static func success(newline: Newline = .none, startDate: Date? = nil, _ message: String...) {
        if let startDate {
            timedResult(newline: newline, level: .success, startDate: startDate, message.joined())
        } else {
            _log(newline, .success, message.joined())
        }
    }
    
    private static func _log(_ newline: Newline = .none, _ level: Level, _ message: String) {
        print(newline.prefix + level.format(message) + newline.suffix)
    }
    
    // MARK: Error
    
    static func error(newline: Newline = .none, error: LocalizedError) {
        Log.error(newline: newline, error.localizedDescription)
    }
    
    // MARK: Timed
    
    static func timed(newline: Newline = .none, level: Level = .info, _ message: String...) -> Date {
        _log(newline, level, message.joined())
        return Date()
    }
    
    static func timedResult(newline: Newline = .none, level: Level = .info, startDate: Date, _ message: String...) {
        let timeString = " (" + String(format: "%.3f seconds", startDate.timeIntervalSinceNow * -1) + ")"
        _log(newline, level, message.joined() + timeString)
    }
    
    // MARK: Structured
    
    struct Column {
        
        // MARK: Internal
    
        let width: Int?
        let message: String
        
        // MARK: Lifecycle
        
        init(width: Int? = nil, _ message: String) {
            self.width = width
            self.message = message
        }
    }
    
    static func structured(level: Level = .info, _ columns: Column...) {
        var formattedMessage = ""
        for column in columns {
            let message = column.message
            if let width = column.width {
                let padding = String(repeating: " ", count: max(0, width - message.count))
                formattedMessage += message + padding
            } else {
                formattedMessage += message
            }
            formattedMessage += " " // add space between columns
        }
        _log(.none, level, formattedMessage.trimmingCharacters(in: .whitespaces))
    }
}
