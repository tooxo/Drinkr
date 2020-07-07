# SaufApp

[![Travis (.com)](https://img.shields.io/travis/com/tooxo/SaufAppFlutter?style=for-the-badge)](https://travis-ci.com/github/tooxo/SaufAppFlutter) [![GitHub release (latest by date)](https://img.shields.io/github/v/release/tooxo/SaufAppFlutter?style=for-the-badge)](https://github.com/tooxo/SaufAppFlutter/releases/latest) [![Codefactor Rating](https://img.shields.io/codefactor/grade/github/tooxo/SaufAppFlutter?style=for-the-badge)](https://www.codefactor.io/repository/github/tooxo/saufappflutter)

## Installing / Testing the app

Download the latest release from the releases tab on the right.



##### Android

###### Not sure what do download?

| File | Requisites |
|--------|--------|
| arm64-v8a-signed.apk | Almost any modern android phone. If this doesn't install, try the one below |
| armeabi-v7a-signed.apk | Any older or low end android phone. Try this if the one above fails to install. |
| x86_64-signed.apk | For android on desktop. Not important for most people |
| bundle-unsigned.aab | Ignore |
| unsigned.zip | Ignore |

1. Downloaded a file according to your device from the releases tab.
2. Install the apk on your phone, if you need help, look [here](https://www.wikihow.tech/Install-APK-Files-on-Android)
3. Have fun

##### iOS
When
1. Download the app.ipa from the Releases.
2. The app is not signed as it is provided here. You need to sign it via your developer keys or external application, for example [`AltStore`](https://altstore.io/) (no Jailbreak required) or [`AppSyncUnified`](https://cydia.akemi.ai/?page/net.angelxwind.appsyncunified) (Jailbreak required).
3. Have fun.

##### Build it yourself

1. Install the flutter sdk on your device, if you are not sure how, look [here](https://flutter.dev/docs/get-started/install)
2. Clone the repository via git or download it via the `Code` button on the top-left of the page.
3. Extract the .zip file and open a terminal there
4. Install
   1. Android: type `flutter build apk`. When the program is done it will return a path to the file built.
   2. iOS (only on mac): type `flutter build ios --no-codesign`. When the program is done it will return a path to the file built.
5. Install it on your device as explained above.
