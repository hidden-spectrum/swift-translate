//
//  Copyright © 2024 Hidden Spectrum, LLC.
//

import Foundation


public struct Language: Codable, Equatable, Hashable, RawRepresentable {
    
    // MARK: Public
    
    public let code: String
    
    public var rawValue: String {
        return code
    }
    
    // MARK: Lifecycle
    
    public init(rawValue: String) {
        self.code = rawValue
    }
    
    init(_ code: StringLiteralType) {
        self.code = code
    }
    
    // MARK: Hash
}

// MARK: - Common Languages

public extension Language {

    static var allCommon: [Language] {
        return [
//            .arabic,
//            .catalan,
//            .chineseHongKong,
//            .croatian,
//            .czech,
//            .danish,
//            .dutch,
            .english,
//            .finnish,
//            .french,
            .german,
//            .greek,
//            .hebrew,
//            .hindi,
//            .hungarian,
//            .indonesian,
//            .italian,
//            .japanese,
//            .korean,
//            .malay,
//            .norwegianBokmal,
//            .polish,
//            .portugueseBrazil,
//            .portuguesePortugal,
//            .romanian,
//            .russian,
//            .slovak,
//            .spanish,
//            .swedish,
//            .thai,
//            .turkish
        ]
    }
    
    static let arabic = Self("ar")
    static let catalan = Self("ca")
    static let chineseHongKong = Self("zh-HK")
    static let croatian = Self("hr")
    static let czech = Self("cs")
    static let danish = Self("da")
    static let dutch = Self("nl")
    static let english = Self("en")
    static let finnish = Self("fi")
    static let french = Self("fr")
    static let german = Self("de")
    static let greek = Self("el")
    static let hebrew = Self("he")
    static let hindi = Self("hi")
    static let hungarian = Self("hu")
    static let indonesian = Self("id")
    static let italian = Self("it")
    static let japanese = Self("ja")
    static let korean = Self("ko")
    static let malay = Self("ms")
    static let norwegianBokmal = Self("nb")
    static let polish = Self("pl")
    static let portugueseBrazil = Self("pt-BR")
    static let portuguesePortugal = Self("pt-PT")
    static let romanian = Self("ro")
    static let russian = Self("ru")
    static let slovak = Self("sk")
    static let spanish = Self("es")
    static let swedish = Self("sv")
    static let thai = Self("th")
    static let turkish = Self("tr")
    static let ukrainian = Self("uk")
    static let vietnamese = Self("vi")
}
