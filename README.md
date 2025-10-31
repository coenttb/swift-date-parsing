# swift-date-parsing

[![CI](https://github.com/coenttb/swift-date-parsing/workflows/CI/badge.svg)](https://github.com/coenttb/swift-date-parsing/actions/workflows/ci.yml)
![Development Status](https://img.shields.io/badge/status-active--development-blue.svg)

A Swift package providing parsers for RFC 2822, RFC 5322 date formats, and Unix epoch timestamps, built on top of swift-parsing.

## Overview

swift-date-parsing provides type-safe date parsing and formatting for common date standards used in web protocols and APIs. It leverages the swift-parsing library to offer composable, bidirectional parsers for RFC 2822 and RFC 5322 date formats, as well as Unix epoch timestamps.

## Features

- RFC 2822 date parser with timezone abbreviations (GMT, UTC, EST, PST)
- RFC 5322 date parser with numeric timezone offsets
- Unix epoch timestamp parser supporting integer, floating-point, and negative values
- Bidirectional conversion: parse strings to Date and format Date back to strings
- Built on swift-parsing for type-safe, composable parsing
- Error handling with descriptive error messages

## Installation

Add swift-date-parsing to your Swift package dependencies in `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/coenttb/swift-date-parsing.git", from: "0.1.0")
]
```

## Quick Start

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

## Usage Examples

### Supported RFC 2822 Formats

RFC 2822 supports various timezone formats:

```swift
import DateParsing

let parser = RFC_2822.Date.Parser()

// Standard format with GMT
let date1 = try parser.parse("Mon, 01 Jan 2024 12:00:00 GMT"[...])

// With numeric timezone offset
let date2 = try parser.parse("Tue, 15 Mar 2024 14:30:15 +0100"[...])

// With negative timezone offset
let date3 = try parser.parse("Wed, 20 Jun 2024 09:45:30 -0500"[...])
```

### Supported RFC 5322 Formats

RFC 5322 requires numeric timezone offsets:

```swift
import DateParsing

let parser = RFC_5322.Date.Parser()

// Standard format
let date1 = try parser.parse("Mon, 01 Jan 2024 12:00:00 +0000"[...])

// With positive timezone offset
let date2 = try parser.parse("Fri, 15 Mar 2024 14:30:15 +0100"[...])

// With negative timezone offset
let date3 = try parser.parse("Thu, 20 Jun 2024 09:45:30 -0500"[...])
```

### Unix Epoch Timestamp Formats

Unix epoch parser supports multiple formats:

```swift
import UnixEpochParsing

let parser = Date.UnixEpoch.Parser()

// Integer timestamps
let date1 = try parser.parse("1234567890"[...])

// Floating-point timestamps
let date2 = try parser.parse("1234567890.5"[...])

// Negative timestamps (pre-1970)
let date3 = try parser.parse("-86400"[...])

// Zero (Unix epoch start: 1970-01-01 00:00:00 UTC)
let date4 = try parser.parse("0"[...])
```

## Related Packages

- [swift-parsing](https://github.com/pointfreeco/swift-parsing) - A library for turning nebulous data into well-structured data, with a focus on composition, performance, generality, and ergonomics.
- [swift-rfc-2822](https://github.com/swift-web-standards/swift-rfc-2822) - Swift implementation of RFC 2822: Internet Message Format
- [swift-rfc-5322](https://github.com/swift-web-standards/swift-rfc-5322) - Swift implementation of RFC 5322: Internet Message Format

## License

This project is licensed under the Apache 2.0 License. See the [LICENSE](LICENSE) file for details.

## Contributing

Contributions are welcome! Feel free to open an issue or submit a pull request.
