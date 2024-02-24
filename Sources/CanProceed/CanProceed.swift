import Foundation

/// An instance of the checker. Usually instantiated via the ``parse(_:)`` static method rather than through its initialiser.
public struct CanProceed {
    /// The host for which this check is made.
    public let host: String?

    /// The paths of various sitemaps that are specified in the robots file.
    public let sitemaps: Set<String>

    /// The agent sections specified in the robots file.
    public var agents: [String: Agent]

    /// Initialise an empty instance. Useful either for tests or manually parsed data. Prefer the static ``parse(_:)`` method instead.
    public init() {
        self.init(host: nil, sitemaps: [], agents: [:])
    }

    /// Initialise an instance with predefined data. Useful either for tests or manually parsed data. Prefer the static ``parse(_:)`` method instead.
    ///
    /// - Parameter host: Optional string with the host of this robots file. Useful for record-keeping, and not used in the parsing logic.
    /// - Parameter sitemaps: A set of strings referring to sitemap XML URLs.
    /// - Parameter agents: A dictionary of Agent objects, keyed by the name of each agent.
    public init(host: String?, sitemaps: Set<String>, agents: [String: Agent]) {
        self.host = host
        self.sitemaps = sitemaps
        self.agents = agents
    }

    /// Create a new instance of ``CanProceed`` based on the contents of a robots.txt file
    ///
    /// This is the recommended way of creating an insteance of ``CanProceed``. After intialisation, the methods ``agent(_:canProceedTo:)``,
    /// ``some(agentsNamed:canProceedTo:)``, and ``all(agentsNamed:canProceedTo:)`` can be used to test paths against the loaded rules.
    ///
    /// - Parameter rawString: The text contents of a robots.txt file.
    public static func parse(_ rawString: String?) -> CanProceed {
        guard let rawString, !rawString.isEmpty else {
            return CanProceed()
        }

        var lines = splitOnLines(cleanSpaces(cleanComments(rawString)))

        // Fallback to the record based split method if we find only one line.
        if lines.count == 1 {
            lines = robustSplit(cleanComments(rawString))
        }

        var agent = ""
        var _agents = [String: Agent]()
        var _sitemaps = Set<String>()
        var _host: String?

        for line in lines {
            guard let record = parseRecord(line) else {
                continue
            }

            switch record.field {
            case "user-agent":
                let recordValue = record.value.lowercased()
                if recordValue != agent, recordValue.isPopulated {
                    agent = recordValue
                    _agents[agent] = Agent()

                } else if recordValue.isEmpty {
                    agent = ""
                }
                // https://developers.google.com/webmasters/control-crawl-index/docs/robots_txt#order-of-precedence-for-group-member-records

            case "allow" where agent.isPopulated && record.value.isPopulated:
                if let r = try? Agent.GroupMemberRecord(record.value), let a = _agents[agent] {
                    a.allow.append(r)
                    _agents[agent] = a
                }

            case "disallow" where agent.isPopulated && record.value.isPopulated:
                if let r = try? Agent.GroupMemberRecord(record.value), let a = _agents[agent] {
                    a.disallow.append(r)
                    _agents[agent] = a
                }

            // Non standard but support by google therefore included.
            case "sitemap" where record.value.isPopulated:
                _sitemaps.insert(record.value)

            case "crawl-delay" where agent.isPopulated:
                let i = Int(record.value) ?? 1
                if var a = _agents[agent] {
                    a.crawlDelay = i
                    _agents[agent] = a
                }

            // Non standard but included for completeness.
            case "host" where _host == nil && record.value.isPopulated:
                _host = record.value

            default:
                break
            }
        }

        return CanProceed(host: _host, sitemaps: _sitemaps, agents: _agents)
    }

    /// Test whether all agents named in the call are allowed down the provided path.
    ///
    /// - Parameter agentNames: An array of names of agents to check.
    /// - Parameter url: The path to test against.
    /// - Returns: `true` if all agents are allowed to enter the provided path, `false` otherwise.
    public func all(agentsNamed agentNames: [String], canProceedTo url: String) -> Bool {
        agentNames.allSatisfy { agent($0, canProceedTo: url) }
    }

    /// Test whether some of the agents named in the call are allowed down the provided path.
    ///
    /// - Parameter agentNames: An array of names of agents to check.
    /// - Parameter url: The path to test against.
    /// - Returns: `true` if one or more of the agents are allowed to enter the provided path, `false` otherwise.
    public func some(agentsNamed agentNames: [String], canProceedTo url: String) -> Bool {
        agentNames.contains { agent($0, canProceedTo: url) }
    }

    /// Test whether an agent with the specified name is allowed down the provided path.
    ///
    /// - Parameter agentNameToCheck: The name of the agent.
    /// - Parameter url: The path to test against.
    /// - Returns: `true` if this agent is allowed to enter the provided path, `false` otherwise.
    public func agent(_ agentNameToCheck: String, canProceedTo url: String) -> Bool {
        guard let path = URL(string: url)?.path else {
            return false
        }

        if let agent = agents[agentNameToCheck.lowercased()] {
            switch agent.canProceedTo(to: path) {
            case .allowed:
                return true
            case .disallowed:
                return false
            case .noComment:
                break
            }
        }

        if let anyAgent = agents["*"] {
            switch anyAgent.canProceedTo(to: path) {
            case .allowed:
                return true
            case .disallowed:
                return false
            case .noComment:
                break
            }
        }

        return true
    }

    private static func cleanComments(_ text: String) -> String {
        text.replacing(#/#.*$/#, with: "")
    }

    private static func cleanSpaces(_ text: String) -> String {
        text.replacing(" ", with: "")
    }

    private static func splitOnLines(_ text: String) -> [String] {
        text.split(separator: #/[\r\n]+/#).map { String($0) }
    }

    private static func robustSplit(_ text: String) -> [String] {
        if text.localizedCaseInsensitiveContains("<html>") {
            []
        } else {
            text.matches(of: #/(\w+-)?\w+:\s\S*/#).map { cleanSpaces(String($0.output.0)) }
        }
    }

    private static func parseRecord(_ line: String) -> (field: String, value: String)? {
        if let firstColonI = line.firstIndex(of: ":") {
            let field = line[line.startIndex ..< firstColonI].trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
            let afterColon = line.index(after: firstColonI)
            let value = line[afterColon ..< line.endIndex]
            return (field: field, value: String(value))
        } else {
            return nil
        }
    }
}
