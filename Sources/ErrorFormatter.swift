import Foundation

public struct ErrorFormatter {
    private var providers = [FormatProvider]()
    
    public init() {}
    
    public mutating func addFormat<Failure: Error>(
        for errorType: Failure.Type,
        provider: @escaping (Failure) -> Format?
    ) {
        let wrapper = FormatProvider(provider: provider)
        providers.append(wrapper)
    }
    
    public func addingFormat<Failure: Error>(
        for errorType: Failure.Type,
        provider: @escaping (Failure) -> Format?
    ) -> Self {
        var new = self
        new.addFormat(for: errorType, provider: provider)
        return new
    }
    
    public mutating func addFormatter(_ formatter: ErrorFormatter) {
        providers.append(contentsOf: formatter.providers)
    }
    
    public func addingFormatter(_ formatter: ErrorFormatter) -> Self {
        var new = self
        new.addFormatter(formatter)
        return new
    }
    
    public mutating func removeAllFormats<Failure: Error>(
        for errorType: Failure.Type
    ) {
        for index in (0 ..< providers.count).reversed() {
            if providers[index].errorType == errorType {
                providers.remove(at: index)
            }
        }
    }
    
    public func removingAllFormats<Failure: Error>(
        for errorType: Failure.Type
    ) -> Self {
        var new = self
        new.removeAllFormats(for: errorType)
        return new
    }
    
    public func format(error: Error) -> FormattedError? {
        for provider in providers.reversed() {
            if let format = provider.format(for: error) {
                switch format {
                case let .string(string):
                    return .string(string)
                case let .nested(nested):
                    return self.format(error: nested)
                case .cancelled:
                    return .cancelled
                }
            }
        }
        return nil
    }
    
    public func string(for error: Error) -> String? {
        format(error: error)?.string
    }
}
