import Foundation

struct FormatProvider {
    let errorType: Error.Type
    private let provider: (Error) -> ErrorFormatter.Format?
    
    init<Failure: Error>(
        provider: @escaping (Failure) -> ErrorFormatter.Format?
    ) {
        self.errorType = Failure.self
        self.provider = { error in
            if let error = error as? Failure {
                return provider(error)
            } else {
                return nil
            }
        }
    }
    
    func format(for error: Error) -> ErrorFormatter.Format? {
        provider(error)
    }
}
