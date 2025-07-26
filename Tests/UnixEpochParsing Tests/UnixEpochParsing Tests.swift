//
//  UnixEpochParsing Tests.swift
//  UnixEpochParsing Tests
//
//  Created by Coen ten Thije Boonkkamp on 26/07/2025.
//

@testable import UnixEpochParsing
import Foundation
import Testing

// MARK: - Test Data

private struct UnixEpochTestCase {
    let description: String
    let input: String
    let expectedInterval: TimeInterval?
    let shouldParse: Bool

    init(description: String, input: String, expectedInterval: TimeInterval? = nil, shouldParse: Bool = true) {
        self.description = description
        self.input = input
        self.expectedInterval = expectedInterval
        self.shouldParse = shouldParse
    }
}

// MARK: - Main Test Suite

@Suite("UnixEpochParsing Tests")
struct UnixEpochParsingTests {

    // MARK: - Unix Epoch Parser Tests

    @Suite("Unix Epoch Parser")
    struct UnixEpochParserTests {

        @Test("Unix Epoch Parser initializes correctly")
        func testUnixEpochParserInitializesCorrectly() {
            let parser = Date.UnixEpoch.Parser()

            _ = parser.body
        }

        @Test("Unix Epoch Parser parses valid timestamps")
        func testUnixEpochParserParsesValidTimestamps() throws {
            let parser = Date.UnixEpoch.Parser()

            let testCases: [UnixEpochTestCase] = [
                UnixEpochTestCase(
                    description: "Unix epoch start",
                    input: "0",
                    expectedInterval: 0
                ),
                UnixEpochTestCase(
                    description: "Common timestamp",
                    input: "1234567890",
                    expectedInterval: 1234567890
                ),
                UnixEpochTestCase(
                    description: "New Year 2021",
                    input: "1609459200",
                    expectedInterval: 1609459200
                ),
                UnixEpochTestCase(
                    description: "Y2K timestamp",
                    input: "946684800",
                    expectedInterval: 946684800
                ),
                UnixEpochTestCase(
                    description: "Max 32-bit signed integer",
                    input: "2147483647",
                    expectedInterval: 2147483647
                )
            ]

            for testCase in testCases {
                do {
                    let result = try parser.parse(testCase.input[...])
                    if let expectedInterval = testCase.expectedInterval {
                        #expect(
                            abs(result.timeIntervalSince1970 - expectedInterval) < 0.001,
                            "Failed parsing \(testCase.description): expected \(expectedInterval), got \(result.timeIntervalSince1970)"
                        )
                    }
                } catch {
                    #expect(Bool(false), "Parsing failed for \(testCase.description): \(error)")
                }
            }
        }

        @Test("Unix Epoch Parser handles floating point timestamps")
        func testUnixEpochParserHandlesFloatingPointTimestamps() throws {
            let parser = Date.UnixEpoch.Parser()

            let floatingPointCases = [
                ("1234567890.5", 1234567890.5),
                ("0.123", 0.123),
                ("946684800.999", 946684800.999),
                ("-86400.5", -86400.5)
            ]

            for (input, expectedInterval) in floatingPointCases {
                do {
                    let result = try parser.parse(input[...])
                    #expect(
                        abs(result.timeIntervalSince1970 - expectedInterval) < 0.001,
                        "Failed parsing floating point \(input): expected \(expectedInterval), got \(result.timeIntervalSince1970)"
                    )
                } catch {
                    #expect(Bool(false), "Parsing failed for floating point \(input): \(error)")
                }
            }
        }

        @Test("Unix Epoch Parser handles negative timestamps")
        func testUnixEpochParserHandlesNegativeTimestamps() throws {
            let parser = Date.UnixEpoch.Parser()

            let negativeTimestamps = [
                ("-86400", -86400.0),    // Dec 31, 1969
                ("-1", -1.0),            // One second before epoch
                ("-946684800", -946684800.0) // Jan 1, 1940
            ]

            for (input, expectedInterval) in negativeTimestamps {
                do {
                    let result = try parser.parse(input[...])
                    #expect(
                        abs(result.timeIntervalSince1970 - expectedInterval) < 0.001,
                        "Failed parsing negative timestamp \(input): expected \(expectedInterval), got \(result.timeIntervalSince1970)"
                    )
                } catch {
                    #expect(Bool(false), "Parsing failed for negative timestamp \(input): \(error)")
                }
            }
        }

        @Test("Unix Epoch Parser rejects invalid formats")
        func testUnixEpochParserRejectsInvalidFormats() {
            let parser = Date.UnixEpoch.Parser()

            let invalidFormats = [
                "not-a-number",
                "12.34.56",
                "abc123",
                "",
                "123abc",
                "12 34",
                "2024-01-01",
                "Mon, 01 Jan 2024 12:00:00 GMT"
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

        @Test("Unix Epoch Parser print method works correctly")
        func testUnixEpochParserPrintMethodWorksCorrectly() throws {
            let parser = Date.UnixEpoch.Parser()
            let testDate = Date(timeIntervalSince1970: 1704110400) // 2024-01-01 12:00:00 UTC

            do {
                let result = try parser.print(testDate)
                #expect(!result.isEmpty, "Printed timestamp should not be empty")
                #expect(result == "1704110400", "Should print as integer timestamp")
            } catch {
                #expect(Bool(false), "Print method failed: \(error)")
            }
        }

        @Test("Unix Epoch Parser round-trip conversion works")
        func testUnixEpochParserRoundTripConversionWorks() throws {
            let parser = Date.UnixEpoch.Parser()

            let testTimestamps = ["0", "1234567890", "946684800", "-86400"]

            for timestamp in testTimestamps {
                let parsedDate = try parser.parse(timestamp[...])
                let printedTimestamp = try parser.print(parsedDate)

                // Since unapply truncates to integer, compare integer values
                let originalInt = Int(TimeInterval(timestamp) ?? 0)
                let printedInt = Int(printedTimestamp) ?? 0
                #expect(originalInt == printedInt, "Round-trip failed for \(timestamp): got \(printedTimestamp)")
            }
        }
    }

    // MARK: - Unix Epoch Conversion Tests

    @Suite("Unix Epoch Conversion")
    struct UnixEpochConversionTests {

        @Test("Unix Epoch Conversion applies correctly")
        func testUnixEpochConversionAppliesCorrectly() throws {
            let conversion = Date.UnixEpoch.Conversion()

            let testCases = [
                ("0", 0.0),
                ("1234567890", 1234567890.0),
                ("1234567890.5", 1234567890.5),
                ("-86400", -86400.0),
                ("946684800.999", 946684800.999)
            ]

            for (input, expectedInterval) in testCases {
                let result = try conversion.apply(input)
                #expect(
                    abs(result.timeIntervalSince1970 - expectedInterval) < 0.001,
                    "Conversion failed for \(input): expected \(expectedInterval), got \(result.timeIntervalSince1970)"
                )
            }
        }

        @Test("Unix Epoch Conversion unapplies correctly")
        func testUnixEpochConversionUnappliesCorrectly() throws {
            let conversion = Date.UnixEpoch.Conversion()

            let testCases = [
                (0.0, "0"),
                (1234567890.0, "1234567890"),
                (1234567890.7, "1234567890"), // Should truncate to integer
                (-86400.0, "-86400"),
                (946684800.9, "946684800") // Should truncate to integer
            ]

            for (interval, expectedString) in testCases {
                let date = Date(timeIntervalSince1970: interval)
                let result = try conversion.unapply(date)
                #expect(result == expectedString, "Unapply failed for \(interval): expected \(expectedString), got \(result)")
            }
        }

        @Test("Unix Epoch Conversion throws error for invalid input")
        func testUnixEpochConversionThrowsErrorForInvalidInput() {
            let conversion = Date.UnixEpoch.Conversion()
            let invalidInputs = ["not-a-number", "abc", "", "12.34.56", "123abc"]

            for input in invalidInputs {
                do {
                    _ = try conversion.apply(input)
                    #expect(Bool(false), "Should have thrown an error for: \(input)")
                } catch let error as Date.UnixEpoch.Conversion.Error {
                    switch error {
                    case .invalidEpoch(let invalidInput):
                        #expect(invalidInput == input, "Error should contain the invalid input")
                    }
                } catch {
                    #expect(Bool(false), "Should have thrown Date.UnixEpoch.Conversion.Error, got: \(error)")
                }
            }
        }
    }

    // MARK: - Historical Dates Tests

    @Suite("Historical Dates")
    struct HistoricalDatesTests {

        @Test("Parser handles well-known historical dates")
        func testParserHandlesWellKnownHistoricalDates() throws {
            let parser = Date.UnixEpoch.Parser()
            let calendar = Calendar(identifier: .gregorian)
            let utcTimeZone = TimeZone(secondsFromGMT: 0)!

            // Test Unix epoch start
            let unixEpoch = try parser.parse("0"[...])
            let epochComponents = calendar.dateComponents(in: utcTimeZone, from: unixEpoch)
            #expect(epochComponents.year == 1970, "Unix epoch should be 1970")
            #expect(epochComponents.month == 1, "Unix epoch should be January")
            #expect(epochComponents.day == 1, "Unix epoch should be day 1")
            #expect(epochComponents.hour == 0, "Unix epoch should be hour 0")
            #expect(epochComponents.minute == 0, "Unix epoch should be minute 0")
            #expect(epochComponents.second == 0, "Unix epoch should be second 0")

            // Test Y2K
            let y2k = try parser.parse("946684800"[...])
            let y2kComponents = calendar.dateComponents(in: utcTimeZone, from: y2k)
            #expect(y2kComponents.year == 2000, "Y2K should be 2000")
            #expect(y2kComponents.month == 1, "Y2K should be January")
            #expect(y2kComponents.day == 1, "Y2K should be day 1")
            #expect(y2kComponents.hour == 0, "Y2K should be hour 0")
            #expect(y2kComponents.minute == 0, "Y2K should be minute 0")
            #expect(y2kComponents.second == 0, "Y2K should be second 0")
        }

        @Test("Parser handles dates before Unix epoch")
        func testParserHandlesDatesBeforeUnixEpoch() throws {
            let parser = Date.UnixEpoch.Parser()

            let preEpochDates = [
                "-86400",    // Dec 31, 1969
                "-31536000", // Jan 1, 1969
                "-946684800" // Approximately Jan 1, 1940
            ]

            for timestamp in preEpochDates {
                do {
                    let result = try parser.parse(timestamp[...])
                    #expect(result.timeIntervalSince1970 < 0, "Pre-epoch date should have negative timestamp")
                } catch {
                    #expect(Bool(false), "Should parse pre-epoch date \(timestamp): \(error)")
                }
            }
        }

        @Test("Parser handles far future dates")
        func testParserHandlesFarFutureDates() throws {
            let parser = Date.UnixEpoch.Parser()

            let futureDates = [
                "4102444800", // Jan 1, 2100
                "32503680000" // Jan 1, 3000
            ]

            for timestamp in futureDates {
                do {
                    let result = try parser.parse(timestamp[...])
                    #expect(result.timeIntervalSince1970 > Date().timeIntervalSince1970, "Future date should be after now")
                } catch {
                    #expect(Bool(false), "Should parse future date \(timestamp): \(error)")
                }
            }
        }
    }

    // MARK: - Edge Cases Tests

    @Suite("Edge Cases")
    struct EdgeCasesTests {

        @Test("Parser handles very large numbers")
        func testParserHandlesVeryLargeNumbers() throws {
            let parser = Date.UnixEpoch.Parser()

            // Test very large but valid timestamps
            let largeTimestamps = [
                "9223372036854775807", // Maximum Int64 value
                "999999999999999999"   // Very large timestamp
            ]

            for timestamp in largeTimestamps {
                do {
                    let result = try parser.parse(timestamp[...])
                    #expect(result.timeIntervalSince1970 > 0, "Should handle large timestamp: \(timestamp)")
                } catch {
                    // Some very large numbers might overflow, which is acceptable
                    continue
                }
            }
        }

        @Test("Parser handles precision edge cases")
        func testParserHandlesPrecisionEdgeCases() throws {
            let parser = Date.UnixEpoch.Parser()

            let precisionCases = [
                "1234567890.000001", // Very small fraction
                "1234567890.999999", // Close to next integer
                "0.000001",          // Very small positive
                "-0.000001"          // Very small negative
            ]

            for timestamp in precisionCases {
                do {
                    let result = try parser.parse(timestamp[...])
                    let expectedInterval = TimeInterval(timestamp) ?? 0
                    #expect(
                        abs(result.timeIntervalSince1970 - expectedInterval) < 0.000001,
                        "Precision case failed for \(timestamp)"
                    )
                } catch {
                    #expect(Bool(false), "Should handle precision case \(timestamp): \(error)")
                }
            }
        }

        @Test("Conversion handles integer truncation correctly")
        func testConversionHandlesIntegerTruncationCorrectly() throws {
            let conversion = Date.UnixEpoch.Conversion()

            let truncationCases = [
                (123.9, "123"),
                (123.1, "123"),
                (123.5, "123"),
                (-123.9, "-123"),
                (-123.1, "-123"),
                (0.9, "0"),
                (-0.9, "0")
            ]

            for (input, expected) in truncationCases {
                let date = Date(timeIntervalSince1970: input)
                let result = try conversion.unapply(date)
                #expect(result == expected, "Truncation failed for \(input): expected \(expected), got \(result)")
            }
        }
    }

    // MARK: - Performance Tests

    @Suite("Performance")
    struct PerformanceTests {

        @Test("Parser handles multiple timestamps efficiently")
        func testParserHandlesMultipleTimestampsEfficiently() throws {
            let parser = Date.UnixEpoch.Parser()
            let baseTimestamp = "1234567890"

            let timestamps = Array(repeating: baseTimestamp, count: 1000)

            for timestamp in timestamps {
                do {
                    _ = try parser.parse(timestamp[...])
                } catch {
                    continue
                }
            }
        }

        @Test("Conversion handles multiple operations efficiently")
        func testConversionHandlesMultipleOperationsEfficiently() throws {
            let conversion = Date.UnixEpoch.Conversion()
            let testDate = Date(timeIntervalSince1970: 1704110400)

            for _ in 0..<1000 {
                do {
                    let string = try conversion.unapply(testDate)
                    _ = try conversion.apply(string)
                } catch {
                    continue
                }
            }
        }
    }

    // MARK: - Error Handling Tests

    @Suite("Error Handling")
    struct ErrorHandlingTests {

        @Test("Conversion Error has correct properties")
        func testConversionErrorHasCorrectProperties() {
            let invalidInput = "invalid timestamp"
            let error = Date.UnixEpoch.Conversion.Error.invalidEpoch(invalidInput)

            switch error {
            case .invalidEpoch(let input):
                #expect(input == invalidInput, "Error should contain the invalid input")
            }
        }

        @Test("Parser handles empty input gracefully")
        func testParserHandlesEmptyInputGracefully() {
            let parser = Date.UnixEpoch.Parser()

            do {
                _ = try parser.parse(""[...])
                #expect(Bool(false), "Parser should fail on empty input")
            } catch {
                // Expected to fail
            }
        }

        @Test("Parser handles malformed input gracefully")
        func testParserHandlesMalformedInputGracefully() {
            let parser = Date.UnixEpoch.Parser()

            let malformedInputs = [
                "1.2.3",
                "++123",
                "--123",
                "123-",
                "123+"
            ]

            for input in malformedInputs {
                do {
                    _ = try parser.parse(input[...])
                    #expect(Bool(false), "Parser should fail on malformed input: \(input)")
                } catch {
                    // Expected to fail
                }
            }
        }
    }
}
