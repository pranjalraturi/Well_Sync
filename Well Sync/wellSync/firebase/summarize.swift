//
//  summarize.swift
//  wellSync
//
//  Created by Rishika Mittal on 03/04/26.
//
//
//import UIKit
//import CoreImage
//import FirebaseCore
//import FirebaseAILogic
//
//class Summarise: UIViewController {
//    
//    static let summarise = Summarise()
//    
//    lazy var model: GenerativeModel = {
//        let ai = FirebaseAI.firebaseAI(backend: .googleAI())
//        return ai.generativeModel(modelName: "gemini-3-flash-preview")
//    }()
//    
//    func extractAndSummarizeWithGemini(image: UIImage) async throws -> String {
//        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
//            print("❌ Could not process image.")
//            return "Could not process image"
//        }
//            // Step 1 — Create inline image data for Gemini
//        let imagePart = InlineDataPart(data: imageData, mimeType: "image/jpeg")
//
//            // Step 2 — Prompt for RAW TEXT extraction
//        let extractPrompt = """
//        This is a photo of a handwritten journal page.
//        Please extract ALL the handwritten text as written. some words may be incomplete/or is not an actual word like comparnt, meaning compartment.
//        there may be some words which do not make sense in the sentence, as they miss some letters or are miss spelled, so correct them.
//        Preserve line breaks. Ignore any watermarks.
//        Do NOT add any numbering, bullet points, or formatting.
//        Do not paraphrase or remove or add any information from your side.
//        Only return the extracted text, nothing else.
//        """
//
//        await MainActor.run { print("✍️ Extracting handwriting...") }
//
//            // Step 3 — Send image + prompt to Gemini
//        let extractResponse = try await model.generateContent(extractPrompt, imagePart)
//        let extractedText = extractResponse.text ?? "No text found."
//
//            // Step 4 — Now ask Gemini to summarize the extracted text
//        await MainActor.run { print("🧠 Summarizing...") }
//
//        let summaryPrompt = """
//        Here is text extracted from a handwritten journal entry:
//
//        \(extractedText)
//
//        Please provide a clear, concise summary in 3-5 sentences.
//        Focus on the key points and main ideas.
//        """
//
//        let summaryResponse = try await model.generateContent(summaryPrompt)
//        return "\n\(summaryResponse.text ?? "Could not summarize.")"
//
//    }
//}

import UIKit
import CoreImage
import FirebaseCore
import FirebaseAILogic

class Summarise: UIViewController {

    static let summarise = Summarise()

    lazy var model: GenerativeModel = {
        let ai = FirebaseAI.firebaseAI(backend: .googleAI())
        return ai.generativeModel(modelName: "gemini-3-flash-preview")
//        gemini-2.0-flash
    }()

    // MARK: - Activity-aware prompt builder

    /// Returns the correct extraction + summary prompts for any activity name.
    /// Add more cases here as new activity types are introduced.
    static func prompts(for activityName: String) -> (extract: String, summarise: String) {
        let name = activityName.lowercased()

        // ── Journal / handwriting ───────────────────────────────────────
        if name.contains("journal") || name.contains("diary") || name.contains("writing") {
            let extract = """
            This is a photo of a handwritten journal page.
            Please extract ALL the handwritten text as written. some words may be incomplete/or is not an actual word like comparnt, meaning compartment.
            there may be some words which do not make sense in the sentence, as they miss some letters or are miss spelled, so correct them.
            Preserve line breaks. Ignore any watermarks.
            Do NOT add any numbering, bullet points, or formatting.
            Do not paraphrase or remove or add any information from your side.
            Only return the extracted text, nothing else.
            """
            let summarise = """
            Here is text extracted from a handwritten journal entry:
            {TEXT}
            Please provide a clear, concise summary in 3-5 sentences.
            summarise but do not paraphrase, keep it natural.
            Focus on the key points and main ideas.
            """
            return (extract, summarise)
        }

        // ── Exercise / physiotherapy ────────────────────────────────────
        if name.contains("exercise") || name.contains("physio") ||
           name.contains("workout") || name.contains("stretch") {
            let extract = """
            This is a photo related to a physiotherapy or exercise activity.
            Describe what you see: the body position, movement, or equipment visible.
            Be precise and factual. Return only the description.
            """
            let summarise = """
            Here is a description of a patient's exercise activity photo:

            {TEXT}

            Summarise in 2–3 sentences what exercise or movement is being performed
            and note any visible form or technique observations.
            Be clinical yet encouraging.
            """
            return (extract, summarise)
        }

        // ── Meal / food / nutrition ─────────────────────────────────────
        if name.contains("meal") || name.contains("food") ||
           name.contains("diet") || name.contains("nutrition") || name.contains("eat") {
            let extract = """
            This is a photo of a patient's meal or food item.
            List all visible food items, estimated portions, and preparation method if visible.
            Return only the food description, no commentary.
            """
            let summarise = """
            Here is a description of a patient's meal photo:

            {TEXT}

            Summarise in 2–3 sentences what was eaten.
            Note approximate nutritional balance (protein, carbs, vegetables) if apparent.
            Keep it neutral and factual.
            """
            return (extract, summarise)
        }

        // ── Mood / mental health ────────────────────────────────────────
        if name.contains("mood") || name.contains("mental") ||
           name.contains("emotion") || name.contains("feeling") {
            let extract = """
            This is a photo or drawing related to a patient's mood or emotional state.
            Describe any visible imagery, colors, expressions, or written text.
            Return only the description.
            """
            let summarise = """
            Here is a description of a patient's mood-tracking entry:

            {TEXT}

            Provide a gentle, empathetic summary in 2–3 sentences.
            Reflect on the emotional themes present without making clinical diagnoses.
            """
            return (extract, summarise)
        }

        // ── Default fallback for any other activity ─────────────────────
        let extract = """
        This is a photo submitted by a patient as part of their health activity log.
        Describe all visible content clearly and factually.
        If there is handwritten or printed text, transcribe it exactly.
        Return only the description or transcription.
        """
        let summarise = """
        Here is a description of a patient's activity photo for '\(activityName)':

        {TEXT}

        Provide a clear, concise summary in 2–4 sentences.
        Focus on what the patient has done or expressed.
        Be supportive and factual.
        """
        return (extract, summarise)
    }

    // MARK: - Main summarise method (activity-aware)

    func extractAndSummarise(image: UIImage, activityName: String) async throws -> String {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            throw SummariseError.imageConversionFailed
        }

        let imagePart = InlineDataPart(data: imageData, mimeType: "image/jpeg")
        let (extractPrompt, summariseTemplate) = Summarise.prompts(for: activityName)

        // Step 1 — Extract content from image
        print("✍️ Extracting content for activity: \(activityName)")
        let extractResponse = try await model.generateContent(extractPrompt, imagePart)
        let extractedText   = extractResponse.text ?? "No content found."

        // Step 2 — Summarise the extracted content
        print("🧠 Summarising...")
        let summaryPrompt    = summariseTemplate.replacingOccurrences(of: "{TEXT}", with: extractedText)
        let summaryResponse  = try await model.generateContent(summaryPrompt)
        return summaryResponse.text ?? "Could not summarise."
    }

    // MARK: - Legacy method (kept for backward compatibility)

    func extractAndSummarizeWithGemini(image: UIImage) async throws -> String {
        return try await extractAndSummarise(image: image, activityName: "journal")
    }
}

enum SummariseError: LocalizedError {
    case imageConversionFailed
    var errorDescription: String? {
        switch self {
        case .imageConversionFailed: return "Could not process the image."
        }
    }
}
