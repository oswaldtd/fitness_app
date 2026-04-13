import Foundation

// MARK: - Claude API envelope

struct ClaudeMessagesResponse: Decodable {
    let id: String
    let content: [ContentBlock]

    struct ContentBlock: Decodable {
        let type: String
        let text: String?
    }

    var firstText: String? { content.first(where: { $0.type == "text" })?.text }
}

// MARK: - Audit response (structured output from Claude)

struct AuditResponse: Codable {
    let diagnosis: String
    let recommendation: String
    let coachingNote: String?
    let planDiff: PlanDiffPayload
    let flags: AuditFlags

    struct PlanDiffPayload: Codable {
        let targetCal: Int?
        let targetProteinG: Double?
        let shakeTiming: String?
        let noteForUser: String?

        var hasChanges: Bool {
            targetCal != nil || targetProteinG != nil ||
            shakeTiming != nil || noteForUser != nil
        }
    }

    struct AuditFlags: Codable {
        let stallDetected: Bool
        let sleepCortisolWarning: Bool
        let adherenceConcern: Bool
    }
}

// MARK: - Parser

enum AuditResponseParser {
    /// Extracts and decodes the JSON block from Claude's text response
    static func parse(from text: String) throws -> AuditResponse {
        // Claude may wrap JSON in a code fence; strip it if present
        let cleaned = stripCodeFence(text)
        guard let data = cleaned.data(using: .utf8) else {
            throw ParserError.invalidUTF8
        }
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return try decoder.decode(AuditResponse.self, from: data)
    }

    private static func stripCodeFence(_ text: String) -> String {
        var result = text.trimmingCharacters(in: .whitespacesAndNewlines)
        if result.hasPrefix("```json") { result = String(result.dropFirst(7)) }
        else if result.hasPrefix("```") { result = String(result.dropFirst(3)) }
        if result.hasSuffix("```") { result = String(result.dropLast(3)) }
        return result.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    enum ParserError: Error, LocalizedError {
        case invalidUTF8
        case noTextContent

        var errorDescription: String? {
            switch self {
            case .invalidUTF8: return "Invalid character encoding in response"
            case .noTextContent: return "Claude returned no text content"
            }
        }
    }
}
