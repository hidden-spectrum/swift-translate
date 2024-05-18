//
//  CatalogTranslationOptions.swift
//
//
//  Created by Jonas Bromö on 2024-05-17.
//

import ArgumentParser

struct CatalogTranslationOptions: ParsableArguments {

    @Flag(
        name: [.customLong("overwrite")],
        help: "Overwrite string catalog files instead of creating a new file"
    )
    var overwriteExisting: Bool = false

    @Flag(
        name: [.customLong("set-needs-review")],
        help: "Mark strings that are translated as NEEDS REVIEW. E.g. to allow reviewing their quality."
    )
    var setNeedsReviewAfterTranslating: Bool = false

    @Argument(
        parsing: .remaining,
        help: "File or directory containing string catalogs to translate"
    )
    var fileOrDirectory: [String] = []
}
