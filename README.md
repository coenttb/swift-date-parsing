# swift-date-parsing

A Swift package providing parsers for RFC 2822, RFC 5322 date formats, and Unix epoch timestamps, built on top of [swift-parsing](https://github.com/pointfreeco/swift-parsing).

## Features

- **RFC 2822 Date Parser**: Parse and format dates according to RFC 2822 specification
- **RFC 5322 Date Parser**: Parse and format dates according to RFC 5322 specification
- **Unix Epoch Parsing**: Parse Unix timestamps (integer and floating-point) to Date objects
- **Type-safe parsing**: Built on swift-parsing for composable, type-safe date parsing
- **Bidirectional conversion**: Both parsing and printing capabilities
- **Comprehensive error handling**: Clear error messages for invalid date formats

## Installation

Add `swift-date-parsing` to your Swift package dependencies in `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/coenttb/swift-date-parsing.git", from: "0.1.0")
]
```

## Usage

### RFC 2822 Date Parsing

```swift
import DateParsing

let parser = RFC_2822.Date.Parser()

// Parse an RFC 2822 date string
let dateString = "Mon, 01 Jan 2024 12:00:00 GMT"
let date = try parser.parse(dateString[...])

// Format a Date as RFC 2822 string
let formattedString = try parser.print(date)
```

### RFC 5322 Date Parsing

```swift
import DateParsing

let parser = RFC_5322.Date.Parser()

// Parse an RFC 5322 date string
let dateString = "Mon, 01 Jan 2024 12:00:00 +0000"
let date = try parser.parse(dateString[...])

// Format a Date as RFC 5322 string
let formattedString = try parser.print(date)
```

### Unix Epoch Parsing

```swift
import UnixEpochParsing

let parser = Date.UnixEpoch.Parser()

// Parse Unix timestamp to Date
let timestamp = "1234567890"
let date = try parser.parse(timestamp[...])

// Parse floating-point timestamp
let floatTimestamp = "1234567890.5"
let preciseDate = try parser.parse(floatTimestamp[...])

// Parse negative timestamp (pre-1970)
let negativeTimestamp = "-86400"
let preEpochDate = try parser.parse(negativeTimestamp[...])

// Convert Date back to Unix timestamp string
let timestampString = try parser.print(date)
```

## Supported Formats

### RFC 2822
- Standard format: `Mon, 01 Jan 2024 12:00:00 GMT`
- With timezone offsets: `Tue, 15 Mar 2024 14:30:15 +0100`
- Various timezone abbreviations (GMT, UTC, EST, PST, etc.)

### RFC 5322
- Standard format: `Mon, 01 Jan 2024 12:00:00 +0000`
- Timezone offsets: `+0000`, `+0100`, `-0500`, etc.
- Full weekday and month names supported

### Unix Epoch
- Integer timestamps: `1234567890`
- Floating-point timestamps: `1234567890.5`
- Negative timestamps (pre-1970): `-86400`
- Large timestamps: `9223372036854775807`
- Zero (Unix epoch start): `0`

## Requirements

- Swift 6.0+
- macOS 13.0+ / iOS 16.0+

## Dependencies

This package depends on:
- [swift-parsing](https://github.com/pointfreeco/swift-parsing) - Composable parsing library
- [swift-rfc-2822](https://github.com/swift-web-standards/swift-rfc-2822) - RFC 2822 implementations
- [swift-rfc-5322](https://github.com/swift-web-standards/swift-rfc-5322) - RFC 5322 implementations

## Related Projects

### The coenttb stack

* [swift-html](https://www.github.com/coenttb/swift-html): A Swift DSL for type-safe HTML & CSS
* [coenttb-web](https://www.github.com/coenttb/coenttb-web): Web development tools and utilities
* [coenttb-server](https://www.github.com/coenttb/coenttb-server): Server development framework

## License

This project is licensed under the **Apache 2.0 License**. See the [LICENSE](LICENSE) file for details.

## Feedback

If you're working on your own Swift project involving date parsing, feel free to learn, fork, and contribute.

Got thoughts? Found something you love? Something you hate? Let me know! Your feedback helps make this project better for everyone. Open an issue or start a discussion—I'm all ears.

> [Subscribe to my newsletter](http://coenttb.com/en/newsletter/subscribe)
>
> [Follow me on X](http://x.com/coenttb)
> 
> [Link on Linkedin](https://www.linkedin.com/in/tenthijeboonkkamp)
