![Swift Translate](https://github.com/hidden-spectrum/swift-translate/assets/469799/1cf0355f-429b-4fa4-9fe1-0b8e777db63e)

![CodeRabbit Pull Request Reviews](https://img.shields.io/coderabbit/prs/github/hidden-spectrum/swift-translate?utm_source=oss&utm_medium=github&utm_campaign=hidden-spectrum%2Fswift-translate&labelColor=171717&color=FF570A&link=https%3A%2F%2Fcoderabbit.ai&label=CodeRabbit+Reviews)

Swift Translate is a CLI tool and Swift Package Plugin that makes it easy to localize your app. It deconstructs your string catalogs and sends them to OpenAI's GPT models, Google Cloud Translate (v2), or Gemini for translation. See it in action:

https://github.com/hidden-spectrum/swift-translate/assets/469799/ae5066fa-336c-4bab-8f80-1ec5659008d9

## 📋 Requirements
- macOS 13+
- Xcode 15+
- Project utilizing [String Catalogs](https://developer.apple.com/videos/play/wwdc2023/10155/) for localization
- [OpenAI API key](https://help.openai.com/en/articles/4936850-where-do-i-find-my-openai-api-key), [Google Cloud Translate (v2)](https://cloud.google.com/translate/docs/overview) API key, or [Gemini API key](https://ai.google.dev/gemini-api/docs)

## ⭐️ Features
- ✅ Translate individual string catalogs or all catalogs in a folder
- ✅ Translate from English to ar, ca, zh-HK, zh-Hans, zh-Hant, hr, cs, da, nl, en, fi, fr, de, el, he, hi, hu, id, it, ja, ko, ms, nb, pl, pt-BR, pt-PT, ro, ru, sk, es, sv, th, tr
- ✅ Support for complex string catalogs with plural & device variations or replacements
- ✅ Translate brand new catalogs or fill in missing translations for existing catalogs
- ✅ Supports ChatGPT (5.4 series models), Google Translate (v2), and Gemini (`gemini-2.5-flash` and `gemini-3-flash-preview`)
- ✅ Works with String Catalog formats from Xcode 15, 16, and 26
- 🚧 Documentation ([#2](/../../issues/2))
- 🚧 Unit tests ([#3](/../../issues/3))
- ❌ Translate from non-English source language ([#23](/../../issues/23))
- ❌ Translate text files (useful for fastlane metadata) ([#12](/../../issues/12))

## 🛑 Stop Here
Before continuing, please read the following:
- This project is still in development 🚧. While we use it in production for [Dextr](https://get.dextr.app/st), exercise caution when using it with your own projects.
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


## Our Apps Using Swift Translate

<table>
  <tr>
    <td>
      <a href="https://get.dextr.app/st">
        <img src="https://is1-ssl.mzstatic.com/image/thumb/PurpleSource221/v4/68/41/e8/6841e857-0eca-22da-7722-140bb2fd30d7/Placeholder.mill/400x400bb-75.webp" width="60" />
      </a>
    </td>
    <td>
      <a href="https://apps.apple.com/us/app/dextr-personal-social-crm/id6462423477">
        <strong>Dextr</strong>
      </a>
      <br />
      Personal and social CRM for tagging & organizing contacts, remembering who you've met, setting reminders to stay in touch, and more.
    </td>
    <td>iOS / iPadOS</td>
  </tr>
  <tr>
    <td>
      <a href="https://apps.apple.com/us/app/producer-toolkit/id6453160947">
        <img src="https://is1-ssl.mzstatic.com/image/thumb/Purple211/v4/0e/7f/25/0e7f2531-5037-dfac-77b7-add9bc394823/AppIcon-0-85-220-6-0-0-2x-0-0.png/100x100bb.png" width="80" style="margin-left: -6px;" />
      </a>
    </td>
    <td>
      <a href="https://apps.apple.com/us/app/producer-toolkit/id6453160947">
        <strong>Producer Toolkit</strong>
      </a>
      <br />
      FREE toolkit for music producers and DJs with set time calculator, converters, reference charts, and more.
    </td>
    <td>macOS</td>
  </tr>
</table>
