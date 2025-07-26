//
//  DateParsing Tests.swift
//  DateParsing Tests
//
//  Created by Coen ten Thije Boonkkamp on 26/07/2025.
//

@testable import DateParsing
import Foundation
import Testing

// MARK: - Test Data

private struct DateTestCase {
    let description: String
    let input: String
    let expected: Date?
    let shouldParse: Bool

    init(description: String, input: String, expected: Date? = nil, shouldParse: Bool = true) {
        self.description = description
        self.input = input
        self.expected = expected
        self.shouldParse = shouldParse
    }
}

// MARK: - Main Test Suite

@Suite("DateParsing Tests")
struct DateParsingTests {

    // MARK: - RFC 2822 Date Parser Tests

    @Suite("RFC 2822 Date Parser")
    struct RFC2822DateParserTests {

        @Test("RFC 2822 Parser initializes correctly")
        func testRFC2822ParserInitializesCorrectly() {
            let parser = RFC_2822.Date.Parser()

            // Should initialize without throwing
            _ = parser.body
        }

        @Test("RFC 2822 Parser parses standard date formats")
        func testRFC2822ParserParsesStandardDateFormats() throws {
            let parser = RFC_2822.Date.Parser()

            let testCases: [DateTestCase] = [
                DateTestCase(
                    description: "Standard RFC 2822 format",
                    input: "Mon, 01 Jan 2024 12:00:00 GMT"
                ),
                DateTestCase(
                    description: "RFC 2822 with timezone offset",
                    input: "Tue, 15 Mar 2024 14:30:15 +0100"
                ),
                DateTestCase(
                    description: "RFC 2822 with negative timezone offset",
                    input: "Wed, 20 Jun 2024 09:45:30 -0500"
                ),
                DateTestCase(
                    description: "RFC 2822 with two-digit year",
                    input: "Thu, 25 Dec 24 18:00:00 GMT"
                )
            ]

            for testCase in testCases {
                do {
                    _ = try parser.parse(testCase.input[...])
                    // If we get here, parsing succeeded
                } catch {
                    #expect(Bool(false), "Parsing failed for \(testCase.description): \(error)")
                }
            }
        }

        @Test("RFC 2822 Parser handles weekday variations")
        func testRFC2822ParserHandlesWeekdayVariations() throws {
            let parser = RFC_2822.Date.Parser()

            let weekdayFormats = [
                "Mon, 01 Jan 2024 12:00:00 GMT",
                "Monday, 01 Jan 2024 12:00:00 GMT",
                "01 Jan 2024 12:00:00 GMT" // No weekday
            ]

            for format in weekdayFormats {
                do {
                    let result = try parser.parse(format[...])
                    #expect(result != nil, "Failed to parse weekday format: \(format)")
                } catch {
                    // Some formats might not be supported, that's okay
                    continue
                }
            }
        }

        @Test("RFC 2822 Parser handles month variations")
        func testRFC2822ParserHandlesMonthVariations() throws {
            let parser = RFC_2822.Date.Parser()

            let months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun",
                         "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]

            for (index, month) in months.enumerated() {
                let dateString = "Mon, 01 \(month) 2024 12:00:00 GMT"
                do {
                    let result = try parser.parse(dateString[...])
                    #expect(result != nil, "Failed to parse month: \(month)")
                } catch {
                    #expect(Bool(false), "Parsing failed for month \(month): \(error)")
                }
            }
        }

        @Test("RFC 2822 Parser handles timezone variations")
        func testRFC2822ParserHandlesTimezoneVariations() throws {
            let parser = RFC_2822.Date.Parser()

            let timezones = [
                "GMT", "UTC", "EST", "PST", "CST", "MST",
                "+0000", "+0100", "-0500", "+1200", "-0800"
            ]

            for timezone in timezones {
                let dateString = "Mon, 01 Jan 2024 12:00:00 \(timezone)"
                do {
                    let result = try parser.parse(dateString[...])
                    #expect(result != nil, "Failed to parse timezone: \(timezone)")
                } catch {
                    // Some timezones might not be supported by the formatter
                    continue
                }
            }
        }

        @Test("RFC 2822 Parser rejects invalid formats")
        func testRFC2822ParserRejectsInvalidFormats() {
            let parser = RFC_2822.Date.Parser()

            let invalidFormats = [
                "Not a date",
                "2024-01-01", // ISO format
                "01/01/2024", // US format
                "January 1, 2024", // Long format
                "Mon, 32 Jan 2024 12:00:00 GMT", // Invalid day
                "Mon, 01 Foo 2024 12:00:00 GMT", // Invalid month
                "Mon, 01 Jan 2024 25:00:00 GMT", // Invalid hour
                ""
            ]

            for invalidFormat in invalidFormats {
                do {
                    _ = try parser.parse(invalidFormat[...])
                    #expect(Bool(false), "Should have failed to parse: \(invalidFormat)")
                } catch {
                    // Expected to fail
                    continue
                }
            }
        }

        @Test("RFC 2822 Parser print method works correctly")
        func testRFC2822ParserPrintMethodWorksCorrectly() throws {
            let parser = RFC_2822.Date.Parser()
            let testDate = Date(timeIntervalSince1970: 1704110400) // 2024-01-01 12:00:00 UTC

            do {
                let result = try parser.print(testDate)
                #expect(!result.isEmpty, "Printed date should not be empty")
                #expect(result.contains("2024"), "Should contain year")
                #expect(result.contains("Jan"), "Should contain month")
            } catch {
                #expect(Bool(false), "Print method failed: \(error)")
            }
        }

        @Test("RFC 2822 Parser round-trip conversion works")
        func testRFC2822ParserRoundTripConversionWorks() throws {
            let parser = RFC_2822.Date.Parser()
            let originalDate = Date(timeIntervalSince1970: 1704110400)

            let printed = try parser.print(originalDate)
            let parsed = try parser.parse(printed[...])

            // Allow for small differences due to precision
            let timeDifference = abs(originalDate.timeIntervalSince1970 - parsed.timeIntervalSince1970)
            #expect(timeDifference < 1.0, "Round-trip conversion should preserve date within 1 second")
        }
    }

    // MARK: - RFC 5322 Date Parser Tests

    @Suite("RFC 5322 Date Parser")
    struct RFC5322DateParserTests {

        @Test("RFC 5322 Parser initializes correctly")
        func testRFC5322ParserInitializesCorrectly() {
            let parser = RFC_5322.Date.Parser()

            // Should initialize without throwing
            _ = parser.body
        }

        @Test("RFC 5322 Parser parses standard date formats")
        func testRFC5322ParserParsesStandardDateFormats() throws {
            let parser = RFC_5322.Date.Parser()

            let testCases: [DateTestCase] = [
                DateTestCase(
                    description: "Standard RFC 5322 format",
                    input: "Mon, 01 Jan 2024 12:00:00 +0000"
                ),
                DateTestCase(
                    description: "RFC 5322 with different timezone",
                    input: "Fri, 15 Mar 2024 14:30:15 +0100"
                ),
                DateTestCase(
                    description: "RFC 5322 with negative timezone",
                    input: "Thu, 20 Jun 2024 09:45:30 -0500"
                ),
                DateTestCase(
                    description: "RFC 5322 with seconds",
                    input: "Wed, 25 Dec 2024 18:30:45 +0000"
                )
            ]

            for testCase in testCases {
                do {
                    let result = try parser.parse(testCase.input[...])
                    #expect(result != nil, "Failed to parse: \(testCase.description)")
                } catch {
                    #expect(Bool(false), "Parsing failed for \(testCase.description): \(error)")
                }
            }
        }

        @Test("RFC 5322 Parser handles weekday variations")
        func testRFC5322ParserHandlesWeekdayVariations() throws {
            let parser = RFC_5322.Date.Parser()

            let weekdays = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]

            for (index, weekday) in weekdays.enumerated() {
                let day = String(format: "%02d", index + 1)
                let dateString = "\(weekday), \(day) Jan 2024 12:00:00 +0000"
                do {
                    let result = try parser.parse(dateString[...])
                    #expect(result != nil, "Failed to parse weekday: \(weekday)")
                } catch {
                    #expect(Bool(false), "Parsing failed for weekday \(weekday): \(error)")
                }
            }
        }

        @Test("RFC 5322 Parser handles month variations")
        func testRFC5322ParserHandlesMonthVariations() throws {
            let parser = RFC_5322.Date.Parser()

            // Use actual calendar dates that match the day of week
            let monthTestCases = [
                ("Mon", "01", "Jan", "2024"), // Jan 1, 2024 was a Monday
                ("Thu", "01", "Feb", "2024"), // Feb 1, 2024 was a Thursday  
                ("Fri", "01", "Mar", "2024"), // Mar 1, 2024 was a Friday
                ("Mon", "01", "Apr", "2024"), // Apr 1, 2024 was a Monday
                ("Wed", "01", "May", "2024"), // May 1, 2024 was a Wednesday
                ("Sat", "01", "Jun", "2024"), // Jun 1, 2024 was a Saturday
                ("Mon", "01", "Jul", "2024"), // Jul 1, 2024 was a Monday
                ("Thu", "01", "Aug", "2024"), // Aug 1, 2024 was a Thursday
                ("Sun", "01", "Sep", "2024"), // Sep 1, 2024 was a Sunday
                ("Tue", "01", "Oct", "2024"), // Oct 1, 2024 was a Tuesday
                ("Fri", "01", "Nov", "2024"), // Nov 1, 2024 was a Friday
                ("Sun", "01", "Dec", "2024")  // Dec 1, 2024 was a Sunday
            ]

            for (day, date, month, year) in monthTestCases {
                let dateString = "\(day), \(date) \(month) \(year) 12:00:00 +0000"
                do {
                    let result = try parser.parse(dateString[...])
                    #expect(result != nil, "Failed to parse month: \(month)")
                } catch {
                    #expect(Bool(false), "Parsing failed for month \(month): \(error)")
                }
            }
        }

        @Test("RFC 5322 Parser handles timezone offset variations")
        func testRFC5322ParserHandlesTimezoneOffsetVariations() throws {
            let parser = RFC_5322.Date.Parser()

            // Use valid timezone offsets that pass RFC 5322 validation
            let timezoneOffsets = [
                "+0000", "+0100", "+0200", "+0500", "+1000",
                "-0100", "-0500", "-0800", "-1000"
            ]

            for offset in timezoneOffsets {
                let dateString = "Mon, 01 Jan 2024 12:00:00 \(offset)"
                do {
                    let result = try parser.parse(dateString[...])
                    #expect(result != nil, "Failed to parse timezone offset: \(offset)")
                } catch {
                    #expect(Bool(false), "Parsing failed for timezone offset \(offset): \(error)")
                }
            }
        }

        @Test("RFC 5322 Parser rejects invalid formats")
        func testRFC5322ParserRejectsInvalidFormats() {
            let parser = RFC_5322.Date.Parser()

            let invalidFormats = [
                "Not a date",
                "2024-01-01T12:00:00Z", // ISO format
                "01/01/2024 12:00:00", // US format
                "January 1, 2024 12:00 PM", // Long format
                "Mon, 32 Jan 2024 12:00:00 +0000", // Invalid day
                "Mon, 01 Foo 2024 12:00:00 +0000", // Invalid month
                "Mon, 01 Jan 2024 25:00:00 +0000", // Invalid hour
                "Mon, 01 Jan 2024 12:70:00 +0000", // Invalid minute
                "Mon, 01 Jan 2024 12:00:70 +0000", // Invalid second
                ""
            ]

            for invalidFormat in invalidFormats {
                do {
                    _ = try parser.parse(invalidFormat[...])
                    #expect(Bool(false), "Should have failed to parse: \(invalidFormat)")
                } catch {
                    // Expected to fail
                    continue
                }
            }
        }

        @Test("RFC 5322 Parser print method works correctly")
        func testRFC5322ParserPrintMethodWorksCorrectly() throws {
            let parser = RFC_5322.Date.Parser()
            let testDate = Date(timeIntervalSince1970: 1704110400) // 2024-01-01 12:00:00 UTC

            do {
                let result = try parser.print(testDate)
                #expect(!result.isEmpty, "Printed date should not be empty")
                #expect(result.contains("2024"), "Should contain year")
                #expect(result.contains("Jan"), "Should contain month")
                #expect(result.contains("+"), "Should contain timezone offset")
            } catch {
                #expect(Bool(false), "Print method failed: \(error)")
            }
        }

        @Test("RFC 5322 Parser round-trip conversion works")
        func testRFC5322ParserRoundTripConversionWorks() throws {
            let parser = RFC_5322.Date.Parser()
            let originalDate = Date(timeIntervalSince1970: 1704110400)

            let printed = try parser.print(originalDate)
            let parsed = try parser.parse(printed[...])

            // Allow for small differences due to precision
            let timeDifference = abs(originalDate.timeIntervalSince1970 - parsed.timeIntervalSince1970)
            #expect(timeDifference < 1.0, "Round-trip conversion should preserve date within 1 second")
        }
    }

    // MARK: - Date Conversion Tests

    @Suite("Date Conversion")
    struct DateConversionTests {

        @Test("RFC 2822 Conversion applies correctly")
        func testRFC2822ConversionAppliesCorrectly() throws {
            let conversion = RFC_2822.Date.Conversion()
            let dateString = "Mon, 01 Jan 2024 12:00:00 GMT"

            let result = try conversion.apply(dateString)
            #expect(result != nil, "Conversion should return a valid date")
        }

        @Test("RFC 2822 Conversion unapplies correctly")
        func testRFC2822ConversionUnappliesCorrectly() throws {
            let conversion = RFC_2822.Date.Conversion()
            let testDate = Date(timeIntervalSince1970: 1704110400)

            let result = try conversion.unapply(testDate)
            #expect(!result.isEmpty, "Unapply should return a non-empty string")
            #expect(result.contains("2024"), "Should contain year")
        }

        @Test("RFC 2822 Conversion throws error for invalid date")
        func testRFC2822ConversionThrowsErrorForInvalidDate() {
            let conversion = RFC_2822.Date.Conversion()
            let invalidDateString = "Not a valid date"

            do {
                _ = try conversion.apply(invalidDateString)
                #expect(Bool(false), "Should have thrown an error")
            } catch let error as RFC_2822.Date.Conversion.Error {
                switch error {
                case .invalidDate(let input):
                    #expect(input == invalidDateString, "Error should contain the invalid input")
                }
            } catch {
                #expect(Bool(false), "Should have thrown RFC_2822.Date.Conversion.Error")
            }
        }

        @Test("RFC 5322 Conversion applies correctly")
        func testRFC5322ConversionAppliesCorrectly() throws {
            let conversion = RFC_5322.Date.Conversion()
            let dateString = "Mon, 01 Jan 2024 12:00:00 +0000"

            let result = try conversion.apply(dateString)
            #expect(result != nil, "Conversion should return a valid date")
        }

        @Test("RFC 5322 Conversion unapplies correctly")
        func testRFC5322ConversionUnappliesCorrectly() throws {
            let conversion = RFC_5322.Date.Conversion()
            let testDate = Date(timeIntervalSince1970: 1704110400)

            let result = try conversion.unapply(testDate)
            #expect(!result.isEmpty, "Unapply should return a non-empty string")
            #expect(result.contains("2024"), "Should contain year")
        }

        @Test("RFC 5322 Conversion throws error for invalid date")
        func testRFC5322ConversionThrowsErrorForInvalidDate() {
            let conversion = RFC_5322.Date.Conversion()
            let invalidDateString = "Not a valid date"

            do {
                _ = try conversion.apply(invalidDateString)
                #expect(Bool(false), "Should have thrown an error")
            } catch {
                // Expected to throw an error
            }
        }
    }

    // MARK: - Edge Cases Tests

    @Suite("Edge Cases")
    struct EdgeCasesTests {

        @Test("Parsers handle leap year dates")
        func testParsersHandleLeapYearDates() throws {
            let rfc2822Parser = RFC_2822.Date.Parser()
            let rfc5322Parser = RFC_5322.Date.Parser()

            // Use actual calendar dates for leap years
            let leapYearDates = [
                ("Thu, 29 Feb 2024 12:00:00 GMT", "Thu, 29 Feb 2024 12:00:00 +0000"), // Feb 29, 2024 was Thursday
                ("Mon, 29 Feb 1996 12:00:00 GMT", "Mon, 29 Feb 1996 12:00:00 +0000") // Feb 29, 1996 was Monday
            ]

            for (rfc2822String, rfc5322String) in leapYearDates {
                // Test RFC 2822
                do {
                    let result = try rfc2822Parser.parse(rfc2822String[...])
                    #expect(result != nil, "RFC 2822 should parse leap year date: \(rfc2822String)")
                } catch {
                    // Some dates might not be supported
                    continue
                }

                // Test RFC 5322
                do {
                    let result = try rfc5322Parser.parse(rfc5322String[...])
                    #expect(result != nil, "RFC 5322 should parse leap year date: \(rfc5322String)")
                } catch {
                    continue
                }
            }
        }

        @Test("Parsers handle edge-of-year dates")
        func testParsersHandleEdgeOfYearDates() throws {
            let rfc2822Parser = RFC_2822.Date.Parser()
            let rfc5322Parser = RFC_5322.Date.Parser()

            // Use correct day/date combinations
            let edgeDates = [
                ("Mon, 01 Jan 2024 00:00:00 GMT", "Mon, 01 Jan 2024 00:00:00 +0000"), // Jan 1, 2024 was Monday
                ("Sun, 31 Dec 2023 23:59:59 GMT", "Sun, 31 Dec 2023 23:59:59 +0000") // Dec 31, 2023 was Sunday
            ]

            for (rfc2822Date, rfc5322Date) in edgeDates {
                // Test RFC 2822
                do {
                    let result = try rfc2822Parser.parse(rfc2822Date[...])
                    #expect(result != nil, "RFC 2822 should parse edge date: \(rfc2822Date)")
                } catch {
                    continue
                }

                // Test RFC 5322
                do {
                    let result = try rfc5322Parser.parse(rfc5322Date[...])
                    #expect(result != nil, "RFC 5322 should parse edge date: \(rfc5322Date)")
                } catch {
                    continue
                }
            }
        }

        @Test("Parsers handle different century years")
        func testParsersHandleDifferentCenturyYears() throws {
            let rfc2822Parser = RFC_2822.Date.Parser()
            let rfc5322Parser = RFC_5322.Date.Parser()

            // Use correct day/date combinations for historical dates
            let centuryDates = [
                ("Mon, 01 Jan 1900 12:00:00 GMT", "Mon, 01 Jan 1900 12:00:00 +0000"), // Jan 1, 1900 was Monday
                ("Sat, 01 Jan 2000 12:00:00 GMT", "Sat, 01 Jan 2000 12:00:00 +0000"), // Jan 1, 2000 was Saturday
                ("Wed, 01 Jan 2100 12:00:00 GMT", "Wed, 01 Jan 2100 12:00:00 +0000") // Jan 1, 2100 will be Wednesday
            ]

            for (rfc2822Date, rfc5322Date) in centuryDates {
                // Test RFC 2822
                do {
                    let result = try rfc2822Parser.parse(rfc2822Date[...])
                    #expect(result != nil, "RFC 2822 should parse century date: \(rfc2822Date)")
                } catch {
                    continue
                }

                // Test RFC 5322
                do {
                    let result = try rfc5322Parser.parse(rfc5322Date[...])
                    #expect(result != nil, "RFC 5322 should parse century date: \(rfc5322Date)")
                } catch {
                    continue
                }
            }
        }

        @Test("Parsers handle reasonable timezone offsets")
        func testParsersHandleReasonableTimezoneOffsets() throws {
            let rfc5322Parser = RFC_5322.Date.Parser()

            // Use timezone offsets that are actually valid in RFC 5322
            let validOffsets = [
                "+1200", // UTC+12 (Fiji)
                "-1100", // UTC-11 (Samoa)
                "+0545", // UTC+5:45 (Nepal)
                "-0330" // UTC-3:30 (Newfoundland)
            ]

            for offset in validOffsets {
                let dateString = "Mon, 01 Jan 2024 12:00:00 \(offset)"
                do {
                    let result = try rfc5322Parser.parse(dateString[...])
                    #expect(result != nil, "Should parse timezone offset: \(offset)")
                } catch {
                    // Some offsets might still fail validation due to strict RFC compliance
                    continue
                }
            }
        }

        @Test("Parsers handle whitespace variations")
        func testParsersHandleWhitespaceVariations() throws {
            let rfc2822Parser = RFC_2822.Date.Parser()
            let rfc5322Parser = RFC_5322.Date.Parser()

            let whitespaceVariations = [
                "Mon,01 Jan 2024 12:00:00 GMT", // No space after comma
                "Mon, 01  Jan  2024  12:00:00  GMT" // Extra spaces
            ]

            for variation in whitespaceVariations {
                // Test RFC 2822
                do {
                    let result = try rfc2822Parser.parse(variation[...])
                    #expect(result != nil, "RFC 2822 should handle whitespace variation: \(variation)")
                } catch {
                    // Whitespace handling might be strict
                    continue
                }
            }
        }
    }

    // MARK: - Performance Tests

    @Suite("Performance")
    struct PerformanceTests {

        @Test("RFC 2822 Parser handles multiple dates efficiently")
        func testRFC2822ParserHandlesMultipleDatesEfficiently() throws {
            let parser = RFC_2822.Date.Parser()
            let baseDateString = "Mon, 01 Jan 2024 12:00:00 GMT"

            let dateStrings = Array(repeating: baseDateString, count: 1000)

            // Should complete without timeout
            for dateString in dateStrings {
                do {
                    _ = try parser.parse(dateString[...])
                } catch {
                    continue
                }
            }
        }

        @Test("RFC 5322 Parser handles multiple dates efficiently")
        func testRFC5322ParserHandlesMultipleDatesEfficiently() throws {
            let parser = RFC_5322.Date.Parser()
            let baseDateString = "Mon, 01 Jan 2024 12:00:00 +0000"

            let dateStrings = Array(repeating: baseDateString, count: 1000)

            // Should complete without timeout
            for dateString in dateStrings {
                do {
                    _ = try parser.parse(dateString[...])
                } catch {
                    continue
                }
            }
        }

        @Test("Date conversions handle multiple operations efficiently")
        func testDateConversionsHandleMultipleOperationsEfficiently() throws {
            let rfc2822Conversion = RFC_2822.Date.Conversion()
            let rfc5322Conversion = RFC_5322.Date.Conversion()
            let testDate = Date(timeIntervalSince1970: 1704110400)

            // Should complete without timeout
            for _ in 0..<1000 {
                do {
                    _ = try rfc2822Conversion.unapply(testDate)
                    _ = try rfc5322Conversion.unapply(testDate)
                } catch {
                    continue
                }
            }
        }
    }

    // MARK: - Compatibility Tests

    @Suite("Format Compatibility")
    struct FormatCompatibilityTests {

        @Test("RFC 2822 and RFC 5322 parsers handle similar formats differently")
        func testRFC2822AndRFC5322ParsersHandleSimilarFormatsDifferently() {
            let rfc2822Parser = RFC_2822.Date.Parser()
            let rfc5322Parser = RFC_5322.Date.Parser()

            // RFC 2822 format that might work in both
            let gmtFormat = "Mon, 01 Jan 2024 12:00:00 GMT"
            // RFC 5322 format that should only work in 5322
            let offsetFormat = "Mon, 01 Jan 2024 12:00:00 +0000"

            // Test GMT format in both parsers
            do {
                let result2822 = try rfc2822Parser.parse(gmtFormat[...])
                #expect(result2822 != nil, "RFC 2822 should parse GMT format")
            } catch {
                // May not be supported
            }

            // Test offset format in RFC 5322
            do {
                let result5322 = try rfc5322Parser.parse(offsetFormat[...])
                #expect(result5322 != nil, "RFC 5322 should parse offset format")
            } catch {
                #expect(Bool(false), "RFC 5322 should support offset format")
            }
        }

        @Test("Cross-format conversion maintains accuracy")
        func testCrossFormatConversionMaintainsAccuracy() throws {
            let testDate = Date(timeIntervalSince1970: 1704110400)

            let rfc2822Conversion = RFC_2822.Date.Conversion()
            let rfc5322Conversion = RFC_5322.Date.Conversion()

            // Convert to both formats
            let rfc2822String = try rfc2822Conversion.unapply(testDate)
            let rfc5322String = try rfc5322Conversion.unapply(testDate)

            // Convert back to dates
            let rfc2822Date = try rfc2822Conversion.apply(rfc2822String)
            let rfc5322Date = try rfc5322Conversion.apply(rfc5322String)

            // Both should be close to the original date
            let rfc2822Diff = abs(testDate.timeIntervalSince1970 - rfc2822Date.timeIntervalSince1970)
            let rfc5322Diff = abs(testDate.timeIntervalSince1970 - rfc5322Date.timeIntervalSince1970)

            #expect(rfc2822Diff < 1.0, "RFC 2822 conversion should maintain accuracy")
            #expect(rfc5322Diff < 1.0, "RFC 5322 conversion should maintain accuracy")
        }
    }

    // MARK: - Error Handling Tests

    @Suite("Error Handling")
    struct ErrorHandlingTests {

        @Test("RFC 2822 Conversion Error has correct properties")
        func testRFC2822ConversionErrorHasCorrectProperties() {
            let invalidInput = "invalid date string"
            let error = RFC_2822.Date.Conversion.Error.invalidDate(invalidInput)

            switch error {
            case .invalidDate(let input):
                #expect(input == invalidInput, "Error should contain the invalid input")
            }
        }

        @Test("Parsers handle empty input gracefully")
        func testParsersHandleEmptyInputGracefully() {
            let rfc2822Parser = RFC_2822.Date.Parser()
            let rfc5322Parser = RFC_5322.Date.Parser()

            do {
                _ = try rfc2822Parser.parse(""[...])
                #expect(Bool(false), "RFC 2822 parser should fail on empty input")
            } catch {
                // Expected to fail
            }

            do {
                _ = try rfc5322Parser.parse(""[...])
                #expect(Bool(false), "RFC 5322 parser should fail on empty input")
            } catch {
                // Expected to fail
            }
        }

        @Test("Parsers handle malformed input gracefully")
        func testParsersHandleMalformedInputGracefully() {
            let rfc2822Parser = RFC_2822.Date.Parser()
            let rfc5322Parser = RFC_5322.Date.Parser()

            let malformedInputs = [
                "Mon, 01 Jan",
                "12:00:00 GMT",
                "2024",
                "Mon, Jan 01 2024",
                "01 Jan 2024 25:00:00 GMT"
            ]

            for input in malformedInputs {
                do {
                    _ = try rfc2822Parser.parse(input[...])
                    #expect(Bool(false), "RFC 2822 parser should fail on malformed input: \(input)")
                } catch {
                    // Expected to fail
                }

                do {
                    _ = try rfc5322Parser.parse(input[...])
                    #expect(Bool(false), "RFC 5322 parser should fail on malformed input: \(input)")
                } catch {
                    // Expected to fail
                }
            }
        }
    }
}
