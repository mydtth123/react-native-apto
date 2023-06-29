# react-native-apto

This brigde for support React Native, base on Apto Sdk
Apto provides SDKs that wrap the Apto Mobile API so that you don’t need to deal with network requests. Convenient classes are exposed in these mobile SDKs, available for iOS (Swift and Objective-C) and Android (Kotlin and Java).

## Installation

```sh
yarn add @mydtth123/react-native-apto
```

## Usage

```js
import { completeSercondaryVerificataion, completeVerificataion, createUser, init, startCardFlow, startPhoneVerification } from 'react-native-apto';

// ...
const phoneNumber  = "988522212"
const result  = await startPhoneVerification(phoneNumber)
```

## Contributing


## License

MIT

---

Made with [create-react-native-library](https://github.com/callstack/react-native-builder-bob)
