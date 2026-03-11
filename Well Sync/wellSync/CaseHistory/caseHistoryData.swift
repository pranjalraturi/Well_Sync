//
//  caseHistoryData.swift
//  wellSync
//
//  Created by GEU on 11/03/26.
//
import Foundation

func historyMockData() -> CaseHistory {

    let caseId = UUID()
    let patientId = UUID()

    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd"

    let timeline = [

        Timeline(
            caseID: caseId,
            title: "Initial Consultation",
            date: formatter.date(from: "2026-01-10")!,
            Description: "Patient visited hospital with fever and fatigue."
        ),

        Timeline(
            caseID: caseId,
            title: "Blood Test Ordered",
            date: formatter.date(from: "2026-01-11")!,
            Description: "Doctor ordered a complete blood test."
        ),

        Timeline(
            caseID: caseId,
            title: "Blood Test Result",
            date: formatter.date(from: "2026-01-12")!,
            Description: "Lab results confirmed mild infection."
        ),

        Timeline(
            caseID: caseId,
            title: "Medication Prescribed",
            date: formatter.date(from: "2026-01-12")!,
            Description: "Antibiotics prescribed for 7 days."
        ),

        Timeline(
            caseID: caseId,
            title: "Follow Up Visit",
            date: formatter.date(from: "2026-01-18")!,
            Description: "Patient showing improvement."
        ),

        Timeline(
            caseID: caseId,
            title: "Recovery Confirmed",
            date: formatter.date(from: "2026-01-25")!,
            Description: "Patient fully recovered."
        )
    ]

    let reports = [

        Report(
            caseId: caseId,
            title: "Blood Test Report",
            date: formatter.date(from: "2026-01-12")!,
            reportPath: ["blood_test.pdf"]
        ),

        Report(
            caseId: caseId,
            title: "Prescription",
            date: formatter.date(from: "2026-01-12")!,
            reportPath: ["prescription.pdf"]
        ),

        Report(
            caseId: caseId,
            title: "Follow Up Report",
            date: formatter.date(from: "2026-01-18")!,
            reportPath: ["followup.pdf"]
        )
    ]

    return CaseHistory(
        caseId: caseId,
        patientId: patientId,
        timeline: timeline,
        report: reports
    )
}
