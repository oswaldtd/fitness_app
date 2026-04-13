import Foundation

enum ClaudeService {
    static let apiURL = URL(string: "https://api.anthropic.com/v1/messages")!
    static let model = "claude-opus-4-6"

    // MARK: - System prompt (hard constraints from spec)

    static let systemPrompt = """
    You are a personal body recomposition coach for a specific user with these stats:
    - Age 35, 5'10", 190 lbs, ~29% body fat, ~135 lbs lean mass
    - TDEE: ~2,480 kcal | Current plan: 2,050 kcal / 175g protein
    - Goal: reach 18–20% body fat sustainably

    HARD CONSTRAINTS — never violate:
    1. PROTEIN FIRST: Never recommend reducing daily calories unless protein adherence exceeded 85% in both stall weeks.
    2. SLEEP BEFORE CALORIES: If average sleep score is below 6.0, identify sleep as the primary bottleneck before any nutrition adjustment.
    3. NO CRASH ADVICE: Never suggest a daily calorie target below 1,800 kcal for this user.
    4. STALL THRESHOLD: A stall = no downward waist trend for 2+ consecutive weeks. Do not recommend plan changes before this threshold.
    5. SPECIFICITY: Every recommendation must reference the user's actual numbers from the data, not generic advice.

    Analyze the weekly data provided and return ONLY a valid JSON object in this exact shape:
    {
      "diagnosis": "One to two sentences. What the data actually shows. No hedging.",
      "recommendation": "One specific action: stay the course | adjust X by Y | focus on Z.",
      "coaching_note": "Optional. A contextual observation. Max two sentences. Null if nothing important to add.",
      "plan_diff": {
        "target_cal": null,
        "target_protein_g": null,
        "shake_timing": null,
        "note_for_user": null
      },
      "flags": {
        "stall_detected": false,
        "sleep_cortisol_warning": false,
        "adherence_concern": false
      }
    }

    If no plan change is warranted, all plan_diff fields must be null.
    Return ONLY the JSON object. No markdown. No explanation. No prose outside the JSON.
    """

    // MARK: - API call

    static func runAudit(contextPackage: String) async throws -> AuditResponse {
        guard let apiKey = KeychainService.loadAPIKey() else {
            throw ClaudeError.noAPIKey
        }

        let body: [String: Any] = [
            "model": model,
            "max_tokens": 1024,
            "system": systemPrompt,
            "messages": [
                ["role": "user", "content": contextPackage]
            ]
        ]

        var request = URLRequest(url: apiURL)
        request.httpMethod = "POST"
        request.setValue(apiKey, forHTTPHeaderField: "x-api-key")
        request.setValue("2023-06-01", forHTTPHeaderField: "anthropic-version")
        request.setValue("application/json", forHTTPHeaderField: "content-type")
        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw ClaudeError.invalidResponse
        }
        guard httpResponse.statusCode == 200 else {
            let body = String(data: data, encoding: .utf8) ?? "no body"
            throw ClaudeError.httpError(statusCode: httpResponse.statusCode, body: body)
        }

        let envelope = try JSONDecoder().decode(ClaudeMessagesResponse.self, from: data)
        guard let text = envelope.firstText else {
            throw AuditResponseParser.ParserError.noTextContent
        }

        return try AuditResponseParser.parse(from: text)
    }

    // MARK: - Errors

    enum ClaudeError: Error, LocalizedError {
        case noAPIKey
        case invalidResponse
        case httpError(statusCode: Int, body: String)

        var errorDescription: String? {
            switch self {
            case .noAPIKey:
                return "No API key found. Please add your Anthropic API key in Settings."
            case .invalidResponse:
                return "Received an unexpected response from the Claude API."
            case .httpError(let code, let body):
                return "API error \(code): \(body)"
            }
        }
    }
}
