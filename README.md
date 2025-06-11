![Swift Translate](https://github.com/hidden-spectrum/swift-translate/assets/469799/1cf0355f-429b-4fa4-9fe1-0b8e777db63e)

Swift Translate is a CLI tool and Swift Package Plugin that makes it easy to localize your app. It deconstructs your string catalogs and sends them to OpenAI's GPT-4o / GPT-4.1 series models or Google Cloud Translate (v2) for translation. See it in action:

https://github.com/hidden-spectrum/swift-translate/assets/469799/ae5066fa-336c-4bab-8f80-1ec5659008d9

## 📋 Requirements
- macOS 13+
- Xcode 15+
- Project utilizing [String Catalogs](https://developer.apple.com/videos/play/wwdc2023/10155/) for localization
- [OpenAI API key](https://help.openai.com/en/articles/4936850-where-do-i-find-my-openai-api-key) or [Google Cloud Translate (v2)](https://cloud.google.com/translate/docs/overview) API key

## ⭐️ Features
- ✅ Translate individual string catalogs or all catalogs in a folder
- ✅ Translate from English to ar, ca, zh-HK, zh-Hans, zh-Hant, hr, cs, da, nl, en, fi, fr, de, el, he, hi, hu, id, it, ja, ko, ms, nb, pl, pt-BR, pt-PT, ro, ru, sk, es, sv, th, tr
- ✅ Support for complex string catalogs with plural & device variations or replacements
- ✅ Translate brand new catalogs or fill in missing translations for existing catalogs
- ✅ Supports ChatGPT (4o and 4.1 series models) and Google Translate (v2)
- ✅ Works with String Catalog formats from Xcode 15, 16, and 26 Beta
- 🚧 Documentation ([#2](/../../issues/2))
- 🚧 Unit tests ([#3](/../../issues/3))
- ❌ Translate from non-English source language ([#23](/../../issues/23))
- ❌ Translate text files (useful for fastlane metadata) ([#12](/../../issues/12))
- ❌ "Confidence check": ask GPT to translate text back into source language to compare against the original string ([#14](/../../issues/14))

## 🛑 Stop Here
Before continuing, please read the following:
- This project is still in development 🚧. While we use it in production for [Dextr](https://dextr.app), exercise caution when using it with your own projects.
- Like any tool built on ChatGPT, responses may be inaccurate or broken completely. 🤪 
- Hidden Spectrum is not liable for loss of data, file corruption, or inaccurate/offensive translations (or any subsequent bad app reviews due to aforementioned inaccuracies) 🙅🏻‍♂️
    
**👉 Note:** By default, your catalogs *WILL NOT* be overwritten, instead a copy will be made with `.loc` extension.
If you wish to overwrite your catalogs, be sure they are checked into your repository or backed up, then use the `--overwrite` CLI argument.

Ok, with that out of the way let's get into the fun stuff...

## 🧑‍💻 Usage

### Option 1: Via Repo Clone
**👉 Note:** While this plugin is still in development, this is the recommended way of trying it with your projects.

1. Clone this repository or download a zip from GitHub.
2. Open terminal and `cd` to the Swift Translate repo on your machine.
3. Test your OpenAI API key with a basic text translation:
    ```shell
    swift run swift-translate --verbose -k <your OpenAI key> --text "This is a test" --lang de
    ``` 
4. You should see the following output:

    ```shell
    Building for debugging...
    Build complete! (0.59s)

    Translating `This is a test`:
    de:      Dies ist ein Test
    ✅ Translated 1 key(s) (0.384 seconds)
    ```
5. Next, run the `--help` command to learn more:
    ```shell
    swift run swift-translate --help
    ```
    
### Option 2: Via Package Plugin

1. Add the depedency to your `Package.swift` file.
    ```swift
    dependencies: [
        .package(url: "https://github.com/hidden-spectrum/swift-translate", .upToNextMajor(from: "0.1.0"))
    ]
    ```
2. Add the plugin to your target:
    ```swift
    .target(
        name: "App",
        // ...
        plugins: [
            .plugin(name: "SwiftTranslate", package: "swift-translate")
        ]
    )
    ```
3. Open terminal and `cd` to your package directory.
4. Try translating a catalog in your package:
    ```shell
    swift package plugin swift-translate -k <your key here> <path/to/some/localization.xcstrings> --lang de --verbose 
    ```
5. Enter `Y` when prompted for write access to your package folder and for outgoing network connections.
6. After translation is finished, check for a new `YourFile.loc.xcstrings` file in the same directory as the original file.

### Option 3: Inside Xcode
🚧 *Not yet supported*


## 🙏 Help Wanted
If you're a GPT Guru, we'd love to hear from you about how we can improve our use of the OpenAI API. Open a ticket with your suggestions or [contact us](https://hiddenspectrum.io/contact) to get involved directly.

## 🤝 Contributing
We're still working out a proper process for contributing to this project. In the meantime, check out [open issues](https://github.com/hidden-spectrum/swift-translate/issues) to see where you may be able to help. If something isn't listed, feel free to open a ticket or PR and we'll take a look!
