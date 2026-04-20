import Foundation
import Encore

@objc(EncorePlacementBuilder)
public final class EncorePlacementBuilder: NSObject {
    private let builder: any PlacementBuilderProtocol

    internal init(_ builder: any PlacementBuilderProtocol) {
        self.builder = builder
        super.init()
    }

    /// Presents the placement. Obj-C calls the auto-generated
    /// `showWithCompletion:` surfaced via SE-0297.
    @objc public func show() async throws -> EncorePresentationResult {
        let result = try await builder.show()
        return EncorePresentationResult(result)
    }

    /// Fire-and-forget presentation. Obj-C: `[builder showAndForget];`
    @objc(showAndForget)
    public func fireAndForget() {
        builder.show()
    }
}
