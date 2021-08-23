import Foundation

extension ErrorFormatter {
    public enum Format {
        case string(String)
        case nested(Error)
        case cancelled
    }
}
