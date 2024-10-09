import Foundation

public extension CanProceed.Agent {
    /// A representation of a single access control line, belonging to an agent section in the robots file.
    struct GroupMemberRecord {
        /// The specificity value of the record represented by this item.
        let specificity: Int

        /// The regular expression that is derived from parsing the record.
        let regex: Regex<Substring>

        /// The original record string as read from the source
        public let originalRecordString: String

        /// Initialise a representation of an access control record from a line of text in the robots file.
        ///
        /// - Parameter recordString: A string representing a line from an agent section.
        /// - Throws: If the line cannot be parsed.
        public init(_ recordString: String) throws {
            originalRecordString = recordString

            let regexSpecialChars = /[\-\[\]\/\{\}\(\)\+\?\.\\\^\$\|]/
            let wildCardPattern = /\*/
            let EOLPattern = /\\\$$/

            var recordString = recordString
            for match in recordString.matches(of: regexSpecialChars).reversed() {
                recordString.replaceSubrange(match.range, with: "\\\(match.output)")
            }
            recordString = recordString
                .replacing(wildCardPattern, with: ".*")
                .replacing(EOLPattern, with: "$")

            regex = try Regex(recordString, as: Substring.self)
            specificity = recordString.count
        }

        /// Test if this record is related to the path provided, based on the matching logic.
        ///
        /// - Returns: `true` if the path matches this record, or `false` otherwise.
        public func matches(_ text: String) -> Bool {
            guard let match = text.prefixMatch(of: regex) else {
                return false
            }
            if text.count <= match.count || text[match.range].hasSuffix("/") {
                // rule was either a directory, or the path was a subset of the rule
                return true
            }
            // text was larger, only match if matched text was a directory component of the rule
            let endOfMatch = text.index(text.startIndex, offsetBy: match.count)
            return text[endOfMatch] == "/"
        }
    }
}
