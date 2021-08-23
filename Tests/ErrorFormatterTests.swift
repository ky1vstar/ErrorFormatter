@testable import ErrorFormatter
import Foundation
import XCTest

enum Errors {
    #if canImport(Darwin)
    enum URL {
        static let notConnectedToInternet = NSError(
            domain: NSURLErrorDomain,
            code: NSURLErrorNotConnectedToInternet,
            userInfo: [
                NSLocalizedDescriptionKey: "The Internet connection appears to be offline.",
                NSURLErrorFailingURLStringErrorKey: "https://google.com/",
                NSURLErrorFailingURLErrorKey: Foundation.URL(string: "https://google.com/")!,
            ]
        )
        
        static let cancelled = NSError(
            domain: NSURLErrorDomain,
            code: NSURLErrorCancelled,
            userInfo: [
                NSLocalizedDescriptionKey: "cancelled",
                NSURLErrorFailingURLStringErrorKey: "https://google.com/",
                NSURLErrorFailingURLErrorKey: Foundation.URL(string: "https://google.com/")!,
            ]
        )
        
        static let timedOut = NSError(
            domain: NSURLErrorDomain,
            code: NSURLErrorTimedOut,
            userInfo: [
                NSLocalizedDescriptionKey: "The request timed out.",
                NSURLErrorFailingURLStringErrorKey: "https://google.com/",
                NSURLErrorFailingURLErrorKey: Foundation.URL(string: "https://google.com/")!,
            ]
        )
    }
    #endif
    
    enum WrappingError: Error {
        case generic
        case nested(Error)
    }
    
    enum CustomError: Error {
        case fileNotFound
        case wrongArgument
        case indexOutOfRange
    }
}

enum Reasons {
    static let notConnectedToInternet = "No internet connection"
    static let timedOut = "Timed out"
    static let wrappingGeneric = "WrappingError.generic"
    static let fileNotFound = "File not found"
    static let wrongArgument = "Wrong argument"
    static let customGeneric = "CustomError.generic"
}

class ErrorFormatterTests: XCTestCase {
    let formatter: ErrorFormatter = ErrorFormatter()
        .addingFormat(for: URLError.self) { error in
            switch error.code {
            case .notConnectedToInternet:
                return .string(Reasons.notConnectedToInternet)
            case .cancelled:
                return .cancelled
            default:
                return nil
            }
        }
        .addingFormat(for: Errors.WrappingError.self) { error in
            switch error {
            case .generic:
                return .string(Reasons.wrappingGeneric)
            case let .nested(error):
                return .nested(error)
            }
        }
        .addingFormat(for: Errors.CustomError.self) { error in
            switch error {
            case .fileNotFound:
                return .string(Reasons.fileNotFound)
            default:
                return .string(Reasons.customGeneric)
            }
        }
    
    #if canImport(Darwin)
    func testBridgedStoredNSError() {
        XCTAssertEqual(
            formatter.format(error: Errors.URL.notConnectedToInternet)?.string,
            Reasons.notConnectedToInternet
        )
        XCTAssertTrue(formatter.format(error: Errors.URL.cancelled)?.isCancelled ?? false)
        XCTAssertNil(formatter.format(error: Errors.URL.timedOut))
    }
    #endif
    
    func testClarification() {
        XCTAssertEqual(
            formatter.format(error: Errors.CustomError.wrongArgument)?.string,
            Reasons.customGeneric
        )
        
        let formatter = self.formatter.addingFormat(for: Errors.CustomError.self) { error in
            switch error {
            case .wrongArgument:
                return .string(Reasons.wrongArgument)
            default:
                return nil
            }
        }
        
        XCTAssertEqual(
            formatter.format(error: Errors.CustomError.wrongArgument)?.string,
            Reasons.wrongArgument
        )
        XCTAssertEqual(
            formatter.format(error: Errors.CustomError.indexOutOfRange)?.string,
            Reasons.customGeneric
        )
    }
    
    func testNestedError() {
        XCTAssertEqual(
            formatter.format(error: Errors.WrappingError.nested(Errors.WrappingError.generic))?.string,
            Reasons.wrappingGeneric
        )
    }
    
    func testConcatenation() {
        let secondFormatter = ErrorFormatter()
            .addingFormat(for: Errors.CustomError.self) { error in
                switch error {
                case .wrongArgument:
                    return .string(Reasons.wrongArgument)
                default:
                    return nil
                }
            }
        let formatter = self.formatter.addingFormatter(secondFormatter)
        
        XCTAssertEqual(
            formatter.format(error: Errors.CustomError.wrongArgument)?.string,
            Reasons.wrongArgument
        )
    }
}
