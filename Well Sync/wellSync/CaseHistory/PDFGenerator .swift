//
//  PDFGenerator .swift
//  wellSync
//
//  Created by GEU on 20/03/26.
//

import UIKit
import PDFKit

struct ReportGenerator {
//    static func createPDF(patient: Patient, history: CaseHistory) -> URL?
    static func createPDF(history: CaseHistory) -> URL? {
        let pageRect = CGRect(x: 0, y: 0, width: 595.2, height: 841.8)
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect)
        
//        let fileName = "CaseHistory_\(patient.name.replacingOccurrences(of: " ", with:"_")).pdf"
        let fileName = "CaseHistory_Aarav_Sharma.pdf"
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
        
        do{
            try renderer.writePDF(to: tempURL) { (context) in
                context.beginPage()
                
                let titleFont = UIFont.preferredFont(forTextStyle: .headline)
                let headerFont = UIFont.preferredFont(forTextStyle: .headline)
                let bodyFont = UIFont.preferredFont(forTextStyle: .body)
                
                let title = "Clinical Case History"
                title.draw(at: CGPoint(x: 50, y: 50), withAttributes: [.font: bodyFont])
                
                var yOffset: CGFloat = 100
//                "Patient: \(patient.name)".draw(at: CGPoint(x: 50, y: yOffset), withAttributes: [.font: bodyFont])
//                 yOffset += 20
//                "Condition: \(patient.condition)".draw(at: CGPoint(x: 50, y: yOffset), withAttributes: [.font:bodyFont])
//                yOffset += 40
                "Patient: Aarav Sharma".draw(at: CGPoint(x: 50, y: yOffset), withAttributes: [.font: bodyFont])
                 yOffset += 20
                "Condition: Maladaptive Day Dreaming".draw(at: CGPoint(x: 50, y: yOffset), withAttributes: [.font:bodyFont])
                yOffset += 40
                "Treatment Timeline".draw(at: CGPoint(x: 50, y: yOffset), withAttributes: [.font: headerFont])
                yOffset += 30
                
                guard let timeline = history.timeline else { return }
                for item in timeline {
                    if yOffset > 750{
                        context.beginPage()
                        yOffset = 50
                    }
                    let dateStr = "[\(item.date)] \(item.title)"
                    dateStr.draw(at: CGPoint(x: 50, y: yOffset), withAttributes: [.font: UIFont.preferredFont(forTextStyle: .body)])
                    yOffset += 18
                    
                    let descRect = CGRect(x: 60, y: yOffset, width: 480, height: 100)
                    item.description.draw(with: descRect, options: .usesLineFragmentOrigin, attributes: [.font: UIFont.preferredFont(forTextStyle: .body)], context: nil)
                    yOffset += 45
                }
            }
            return tempURL
        }catch{
            print("could not create PDF: \(error)")
            return nil
        }
    }
}
