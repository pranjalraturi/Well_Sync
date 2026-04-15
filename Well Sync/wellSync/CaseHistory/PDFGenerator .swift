import UIKit
import PDFKit

struct ReportGenerator {
    
    static func createPDF(patient: Patient, timeline: [Timeline]) -> URL? {
        
        let pageRect = CGRect(x: 0, y: 0, width: 595.2, height: 841.8)
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect)
        
        let fileName = "CaseHistory_\(patient.name.replacingOccurrences(of: " ", with: "_")).pdf"
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
        
        do {
            try renderer.writePDF(to: tempURL) { context in
                
                var yOffset: CGFloat = 50
                
                let titleFont = UIFont.boldSystemFont(ofSize: 20)
                let headerFont = UIFont.boldSystemFont(ofSize: 16)
                let bodyFont = UIFont.systemFont(ofSize: 12)
                
                let dateFormatter = DateFormatter()
                dateFormatter.dateStyle = .medium
                
                func newPageIfNeeded(height: CGFloat) {
                    if yOffset + height > pageRect.height - 50 {
                        context.beginPage()
                        yOffset = 50
                    }
                }
                
                context.beginPage()
                
                // MARK: Title
                "Clinical Case History".draw(
                    at: CGPoint(x: 50, y: yOffset),
                    withAttributes: [.font: titleFont]
                )
                yOffset += 40
                
                // MARK: Patient Info
                "Patient: \(patient.name)".draw(
                    at: CGPoint(x: 50, y: yOffset),
                    withAttributes: [.font: bodyFont]
                )
                yOffset += 20
                
                let conditionText = patient.condition ?? "N/A"
                "Condition: \(conditionText)".draw(
                    at: CGPoint(x: 50, y: yOffset),
                    withAttributes: [.font: bodyFont]
                )
                yOffset += 30
                
                // MARK: Timeline Header
                "Treatment Timeline".draw(
                    at: CGPoint(x: 50, y: yOffset),
                    withAttributes: [.font: headerFont]
                )
                yOffset += 25
                
                // MARK: Timeline Content
                for item in timeline {
                    
                    newPageIfNeeded(height: 80)
                    
                    let dateStr = "[\(dateFormatter.string(from: item.date))] \(item.title)"
                    
                    dateStr.draw(
                        at: CGPoint(x: 50, y: yOffset),
                        withAttributes: [.font: bodyFont]
                    )
                    
                    yOffset += 18
                    
                    let descRect = CGRect(x: 60, y: yOffset, width: 480, height: 100)
                    
                    let descHeight = item.description.boundingRect(
                        with: CGSize(width: 480, height: CGFloat.greatestFiniteMagnitude),
                        options: .usesLineFragmentOrigin,
                        attributes: [.font: bodyFont],
                        context: nil
                    ).height
                    
                    item.description.draw(
                        with: descRect,
                        options: .usesLineFragmentOrigin,
                        attributes: [.font: bodyFont],
                        context: nil
                    )
                    
                    yOffset += descHeight + 15
                }
            }
            
            return tempURL
            
        } catch {
            print("could not create PDF: \(error)")
            return nil
        }
    }
}
