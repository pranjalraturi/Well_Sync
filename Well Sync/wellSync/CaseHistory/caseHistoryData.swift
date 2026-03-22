//
//  caseHistoryData.swift
//  wellSync
//
//  Created by GEU on 11/03/26.
//
//import Foundation
//
//func historyMockData() -> CaseHistory {
//
//    let caseId = UUID()
//    let patientId = UUID()
//
//    let formatter = DateFormatter()
//    formatter.dateFormat = "yyyy-MM-dd"
//
//    let timeline = [
//
//        Timeline(
//            caseID: caseId,
//            title: "Intake Assessment",
//            date: formatter.date(from: "2026-01-10")!,
//            Description: "Initial screening. Patient reports persistent anxiety and disrupted sleep patterns."
//        ),
//
//        Timeline(
//            caseID: caseId,
//            title: "PHQ-9 & GAD-7 Testing",
//            date: formatter.date(from: "2026-01-17")!,
//            Description: "Administered standardized depression and anxiety scales to establish a baseline."
//        ),
//
//        Timeline(
//            caseID: caseId,
//            title: "Diagnostic Formulation",
//            date: formatter.date(from: "2026-01-24")!,
//            Description: "Assessment results suggest Generalized Anxiety Disorder (GAD). Established treatment goals."
//        ),
//
//        Timeline(
//            caseID: caseId,
//            title: "Medication Prescribed",
//            date: formatter.date(from: "2026-01-31")!,
//            Description: "Antibiotics prescribed for 7 days."
//        ),
//
//        Timeline(
//            caseID: caseId,
//            title: "CBT Protocol Initiated",
//            date: formatter.date(from: "2026-02-08")!,
//            Description: "Started Cognitive Behavioral Therapy. Focus on identifying maladaptive thought patterns."
//        ),
//
//        Timeline(
//            caseID: caseId,
//            title: "Progress Review",
//            date: formatter.date(from: "2026-02-22")!,
//            Description: "Significant reduction in symptoms. Moving to bi-weekly sessions for relapse prevention."
//        )
//    ]
//
//    let reports = [
//
//        Report(
//            caseId: caseId,
//            title: "Psychological Evaluation",
//            date: formatter.date(from: "2026-01-12")!,
//            reportPath: ["initial_assessment_report.pdf"]
//        ),
//
//        Report(
//            caseId: caseId,
//            title: "Standardized Test Scores",
//            date: formatter.date(from: "2026-01-18")!,
//            reportPath: ["phq9_gad7_results.pdf"]
//        ),
//
//        Report(
//            caseId: caseId,
//            title: "Treatment Plan",
//            date: formatter.date(from: "2026-02-08")!,
//            reportPath: ["cbt_treatment_strategy.pdf"]
//        )
//    ]
//
//    return CaseHistory(
//        caseId: caseId,
//        patientId: patientId,
//        timeline: timeline,
//        report: reports
//    )
//}
