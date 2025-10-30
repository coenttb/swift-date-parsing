//
//  ReadmeVerificationTests.swift
//  swift-date-parsing
//
//  Created by README standardization process
//

import Testing
import Foundation
@testable import DateParsing
@testable import UnixEpochParsing

@Suite("README Verification")
struct ReadmeVerificationTests {

    // MARK: - Quick Start Examples

    @Test("RFC 2822 Quick Start Example (README lines 35-46)")
    func rfc2822QuickStart() throws {
        let parser = RFC_2822.Date.Parser()

        // Parse an RFC 2822 date string
        let dateString = "Mon, 01 Jan 2024 12:00:00 GMT"
        let date = try parser.parse(dateString[...])

        // Format a Date as RFC 2822 string
        let formattedString = try parser.print(date)

        // Verify we got a date
        #expect(date.timeIntervalSince1970 > 0)
        #expect(!formattedString.isEmpty)
    }

    @Test("RFC 5322 Quick Start Example (README lines 50-61)")
    func rfc5322QuickStart() throws {
        let parser = RFC_5322.Date.Parser()

        // Parse an RFC 5322 date string
        let dateString = "Mon, 01 Jan 2024 12:00:00 +0000"
        let date = try parser.parse(dateString[...])

        // Format a Date as RFC 5322 string
        let formattedString = try parser.print(date)

        // Verify we got a date
        #expect(date.timeIntervalSince1970 > 0)
        #expect(!formattedString.isEmpty)
    }

    @Test("Unix Epoch Quick Start Example (README lines 65-84)")
    func unixEpochQuickStart() throws {
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

        // Verify we got dates
        #expect(date.timeIntervalSince1970 == 1234567890)
        #expect(preciseDate.timeIntervalSince1970 == 1234567890.5)
        #expect(preEpochDate.timeIntervalSince1970 == -86400)
        #expect(timestampString == "1234567890")
    }

    // MARK: - RFC 2822 Format Examples

    @Test("RFC 2822 Supported Formats (README lines 93-105)")
    func rfc2822SupportedFormats() throws {
        let parser = RFC_2822.Date.Parser()

        // Standard format with GMT
        let date1 = try parser.parse("Mon, 01 Jan 2024 12:00:00 GMT"[...])

        // With numeric timezone offset
        let date2 = try parser.parse("Tue, 15 Mar 2024 14:30:15 +0100"[...])

        // With negative timezone offset
        let date3 = try parser.parse("Wed, 20 Jun 2024 09:45:30 -0500"[...])

        // Verify we got valid dates
        #expect(date1.timeIntervalSince1970 > 0)
        #expect(date2.timeIntervalSince1970 > 0)
        #expect(date3.timeIntervalSince1970 > 0)
    }

    // MARK: - RFC 5322 Format Examples

    @Test("RFC 5322 Supported Formats (README lines 111-124)")
    func rfc5322SupportedFormats() throws {
        let parser = RFC_5322.Date.Parser()

        // Standard format
        let date1 = try parser.parse("Mon, 01 Jan 2024 12:00:00 +0000"[...])

        // With positive timezone offset
        let date2 = try parser.parse("Fri, 15 Mar 2024 14:30:15 +0100"[...])

        // With negative timezone offset
        let date3 = try parser.parse("Thu, 20 Jun 2024 09:45:30 -0500"[...])

        // Verify we got valid dates
        #expect(date1.timeIntervalSince1970 > 0)
        #expect(date2.timeIntervalSince1970 > 0)
        #expect(date3.timeIntervalSince1970 > 0)
    }

    // MARK: - Unix Epoch Format Examples

    @Test("Unix Epoch Timestamp Formats (README lines 130-146)")
    func unixEpochTimestampFormats() throws {
        let parser = Date.UnixEpoch.Parser()

        // Integer timestamps
        let date1 = try parser.parse("1234567890"[...])

        // Floating-point timestamps
        let date2 = try parser.parse("1234567890.5"[...])

        // Negative timestamps (pre-1970)
        let date3 = try parser.parse("-86400"[...])

        // Zero (Unix epoch start: 1970-01-01 00:00:00 UTC)
        let date4 = try parser.parse("0"[...])

        // Verify we got correct dates
        #expect(date1.timeIntervalSince1970 == 1234567890)
        #expect(date2.timeIntervalSince1970 == 1234567890.5)
        #expect(date3.timeIntervalSince1970 == -86400)
        #expect(date4.timeIntervalSince1970 == 0)
    }
}
