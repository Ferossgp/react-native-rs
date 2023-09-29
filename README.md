# react-native-awesome-rs-library

Example Rust into React Native integration

Before getting started please make sure that you have your React Native and Rust env configured.

## Build

`./rust/build_android.sh` - will generate the so binary and Kotlin interface

`./rust/build_ios.sh` - will generate the binary and Swift interface

or use the npm script:

`yarn build-rust`


Test with the example app:

`yarn install` - install all necessary dependencies
`yarn example ios` - run the example app on iOS
`yarn example android` - run the example app on Android

## Usage

```js
import { multiply } from 'react-native-awesome-rs-library';

// ...

const result = await multiply(3, 7);
```

## Contributing

See the [contributing guide](CONTRIBUTING.md) to learn how to contribute to the repository and the development workflow.

## License

MIT

---

Made with [create-react-native-library](https://github.com/callstack/react-native-builder-bob)
