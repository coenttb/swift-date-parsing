//
//  RFC 2822 Date Parser.swift
//  swift-date-parsing
//
//  Created by Coen ten Thije Boonkkamp on 03/02/2025.
//

import Foundation
import Parsing
import RFC_2822

extension RFC_2822.Date {
    /// A parser that can parse and print RFC 2822 date strings.
    ///
    /// RFC 2822 defines the standard format for date and time stamps in Internet message headers.
    /// This parser supports various timezone formats including named zones (GMT, UTC, EST, PST, etc.)
    /// and numeric offsets (+0100, -0500, etc.).
    ///
    /// ## Supported Formats
    ///
    /// The parser supports these RFC 2822 date formats:
    /// - `Mon, 01 Jan 2024 12:00:00 GMT`
    /// - `Tue, 15 Mar 2024 14:30:15 +0100`
    /// - `Wed, 20 Jun 2024 09:45:30 -0500`
    /// - `Thu, 25 Dec 24 18:00:00 GMT` (two-digit year)
    ///
    /// ## Example Usage
    ///
    /// ```swift
    /// let parser = RFC_2822.Date.Parser()
    ///
    /// // Parse an RFC 2822 date string
    /// let dateString = "Mon, 01 Jan 2024 12:00:00 GMT"
    /// let date = try parser.parse(dateString[...])
    ///
    /// // Format a Date as RFC 2822 string
    /// let backToString = try parser.print(date)
    /// ```
    ///
    /// ## Error Handling
    ///
    /// The parser will throw errors for invalid date formats:
    /// - Invalid date components (e.g., day 32, month 13)
    /// - Malformed time values (e.g., 25:00:00)
    /// - Unrecognized timezone formats
    /// - Empty or completely invalid input
    public struct Parser: ParserPrinter {

        /// Creates a new RFC 2822 date parser.
        ///
        /// The parser is stateless and can be reused for multiple parsing operations.
        public init() {}

        let conversion = RFC_2822.Date.Conversion()

        /// The parser body that handles the actual parsing and printing logic.
        ///
        /// This property defines the parsing behavior using the swift-parsing framework,
        /// converting between string representations and Foundation.Date objects.
        public var body: some ParserPrinter<Substring, Foundation.Date> {
            Parse(.string).map(conversion)
        }
    }
}

extension RFC_2822.Date {
    /// A conversion type that handles bidirectional transformation between RFC 2822 date strings and Foundation.Date objects.
    ///
    /// This conversion is used internally by the RFC 2822 date parser to transform between
    /// string representations and typed Date objects, providing error handling for invalid formats.
    struct Conversion: Parsing.Conversion {
        public typealias Input = String
        public typealias Output = Foundation.Date

        /// Converts an RFC 2822 date string to a Foundation.Date.
        ///
        /// - Parameter input: An RFC 2822 formatted date string
        /// - Returns: A Foundation.Date representing the parsed date
        /// - Throws: `RFC_2822.Date.Conversion.Error.invalidDate` if the input string cannot be parsed
        ///
        /// ## Example
        /// ```swift
        /// let conversion = RFC_2822.Date.Conversion()
        /// let date = try conversion.apply("Mon, 01 Jan 2024 12:00:00 GMT")
        /// ```
        public func apply(_ input: String) throws -> Foundation.Date {

            guard let date = RFC_2822.Date.formatter.date(from: input) else {
                throw RFC_2822.Date.Conversion.Error.invalidDate(input)
            }
            return date
        }

        /// Converts a Foundation.Date to an RFC 2822 formatted string.
        ///
        /// - Parameter output: A Foundation.Date to be formatted
        /// - Returns: An RFC 2822 formatted date string
        /// - Throws: This method currently does not throw, but is marked as throwing for protocol conformance
        ///
        /// ## Example
        /// ```swift
        /// let conversion = RFC_2822.Date.Conversion()
        /// let dateString = try conversion.unapply(Date())
        /// ```
        public func unapply(_ output: Foundation.Date) throws -> String {
            output.formatted(.rfc2822)
        }

        /// Errors that can occur during RFC 2822 date conversion.
        public enum Error: Swift.Error {
            /// Thrown when an input string cannot be parsed as a valid RFC 2822 date.
            ///
            /// - Parameter String: The invalid input string that failed to parse
            case invalidDate(String)
        }
    }
}
