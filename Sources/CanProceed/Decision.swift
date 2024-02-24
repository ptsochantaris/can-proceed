import Foundation

public extension CanProceed.Agent {
    /// The result of a check to proceed.
    enum Decision {
        // This agent is explicitly allowed to proceed down this path
        case allowed

        // This agent is explicitly blocked from proceeding down this path
        case disallowed

        // Nothing in the specific check affects this agent
        case noComment
    }
}
