import Foundation

extension ErrorFormatter {
    public enum FormattedError {
        case string(String)
        case cancelled
        
        public var string: String? {
            if case let .string(string) = self {
                return string
            } else {
                return nil
            }
        }
        
        public var isCancelled: Bool {
            if case .cancelled = self {
                return true
            } else {
                return false
            }
        }
    }
}
