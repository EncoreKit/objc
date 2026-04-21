import Foundation
import Encore

@objc(EncorePlacementBuilder)
public final class EncorePlacementBuilder: NSObject {
    private let builder: any PlacementBuilderProtocol

    internal init(_ builder: any PlacementBuilderProtocol) {
        self.builder = builder
        super.init()
    }

    /// Presents the placement. Completion fires on the main thread with
    /// either a non-nil `result` or a non-nil `NSError`.
    @objc public func show(completion: @escaping (EncorePresentationResult?, NSError?) -> Void) {
        Task {
            do {
                let result = try await builder.show()
                let wrapped = EncorePresentationResult(result)
                await MainActor.run { completion(wrapped, nil) }
            } catch {
                let nsError = bridgedNSError(error)
                await MainActor.run { completion(nil, nsError) }
            }
        }
    }

    /// Fire-and-forget presentation. Obj-C: `[builder showAndForget];`
    @objc(showAndForget)
    public func fireAndForget() {
        builder.show()
    }
}
