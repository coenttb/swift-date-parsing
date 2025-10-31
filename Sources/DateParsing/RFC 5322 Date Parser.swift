//
//  RFC 5322 Date Parser.swift
//  swift-date-parsing
//
//  Created by Coen ten Thije Boonkkamp on 03/02/2025.
//

import Foundation
import Parsing
import RFC_5322

extension RFC_5322.Date {
  /// A parser that can parse and print RFC 5322 date strings.
  ///
  /// RFC 5322 defines the Internet Message Format standard, which includes specifications
  /// for date and time stamps. This parser handles the stricter format requirements of
  /// RFC 5322, particularly around timezone offsets which must be numeric (+/-HHMM format).
  ///
  /// ## Supported Formats
  ///
  /// The parser supports these RFC 5322 date formats:
  /// - `Mon, 01 Jan 2024 12:00:00 +0000`
  /// - `Fri, 15 Mar 2024 14:30:15 +0100`
  /// - `Thu, 20 Jun 2024 09:45:30 -0500`
  /// - `Wed, 25 Dec 2024 18:30:45 +1200`
  ///
  /// ## Example Usage
  ///
  /// ```swift
  /// let parser = RFC_5322.Date.Parser()
  ///
  /// // Parse an RFC 5322 date string
  /// let dateString = "Mon, 01 Jan 2024 12:00:00 +0000"
  /// let date = try parser.parse(dateString[...])
  ///
  /// // Format a Date as RFC 5322 string
  /// let backToString = try parser.print(date)
  /// ```
  ///
  /// ## Key Differences from RFC 2822
  ///
  /// - **Timezone Format**: RFC 5322 requires numeric timezone offsets (+/-HHMM)
  /// - **Stricter Validation**: More rigorous format validation
  /// - **Standard Compliance**: Follows the newer Internet Message Format standard
  ///
  /// ## Error Handling
  ///
  /// The parser will throw errors for invalid date formats:
  /// - Invalid date components (e.g., day 32, month 13)
  /// - Malformed time values (e.g., 25:00:00)
  /// - Invalid timezone offset formats
  /// - Empty or completely invalid input
  public struct Parser: ParserPrinter {

    /// Creates a new RFC 5322 date parser.
    ///
    /// The parser is stateless and can be reused for multiple parsing operations.
    public init() {}

    /// The parser body that handles the actual parsing and printing logic.
    ///
    /// This property defines the parsing behavior using the swift-parsing framework,
    /// converting between string representations and Foundation.Date objects.
    public var body: some ParserPrinter<Substring, Foundation.Date> {
      Parse(.string).map(Conversion())
    }
  }

  /// A conversion type that handles bidirectional transformation between RFC 5322 date strings and Foundation.Date objects.
  ///
  /// This conversion is used internally by the RFC 5322 date parser to transform between
  /// string representations and typed Date objects, providing error handling for invalid formats.
  struct Conversion: Parsing.Conversion {
    public typealias Input = String
    public typealias Output = Foundation.Date

    /// Converts an RFC 5322 date string to a Foundation.Date.
    ///
    /// - Parameter input: An RFC 5322 formatted date string
    /// - Returns: A Foundation.Date representing the parsed date
    /// - Throws: An error if the input string cannot be parsed as a valid RFC 5322 date
    ///
    /// ## Example
    /// ```swift
    /// let conversion = RFC_5322.Date.Conversion()
    /// let date = try conversion.apply("Mon, 01 Jan 2024 12:00:00 +0000")
    /// ```
    public func apply(_ input: String) throws -> Foundation.Date {
      try RFC_5322.Date.date(from: input)
    }

    /// Converts a Foundation.Date to an RFC 5322 formatted string.
    ///
    /// - Parameter output: A Foundation.Date to be formatted
    /// - Returns: An RFC 5322 formatted date string
    /// - Throws: This method currently does not throw, but is marked as throwing for protocol conformance
    ///
    /// ## Example
    /// ```swift
    /// let conversion = RFC_5322.Date.Conversion()
    /// let dateString = try conversion.unapply(Date())
    /// ```
    public func unapply(_ output: Foundation.Date) throws -> String {
      output.formatted(.rfc5322)
    }
  }
}
