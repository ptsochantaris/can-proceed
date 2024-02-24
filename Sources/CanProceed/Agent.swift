import Foundation
import Lista

public extension CanProceed {
    /// A representation of an Agent section in a robots file.
    struct Agent {
        /// A list of records should allow a path, if it matches.
        public let allow = Lista<GroupMemberRecord>()

        /// A list of records that should block the path, if it matches.
        public let disallow = Lista<GroupMemberRecord>()

        /// The crawl delay specified in the robots file. Does not affect any other logic here, but useful to have it for convenience.
        public var crawlDelay = 0

        /// Tests whether the agent named in this section is allowed to proceed or not down the suplied path, record specicifity into account.
        ///
        /// - Parameter path: The path to test against
        /// - Returns: The decision based on the logic of each record, weighed by their specicifity. The decision can be an explicit yes,
        /// an explicit no, or the path may not be affected at all by this agent section.
        public func canProceedTo(to: String) -> Decision {
            let allowingRecords = allow.filter { $0.matches(to) }
            let maxAllow = allowingRecords.max { $0.specificity < $1.specificity }
            let disallowingRecords = disallow.filter { $0.matches(to) }
            let maxDisallow = disallowingRecords.max { $0.specificity < $1.specificity }

            if let maxAllow, let maxDisallow {
                if maxAllow.specificity > maxDisallow.specificity {
                    return .allowed
                } else {
                    return .disallowed
                }
            } else if maxDisallow != nil {
                return .disallowed
            } else if maxAllow != nil {
                return .allowed
            } else {
                return .noComment
            }
        }
    }
}
