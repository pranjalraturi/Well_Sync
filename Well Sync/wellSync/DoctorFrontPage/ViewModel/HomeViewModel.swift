//
//  HomeViewModel.swift
//  wellSync
//
//  Created by Pranjal on 05/02/26.
//

//import UIKit
//
//class HomeViewModel {
//
//    private var patients: [PatientModel] = []
//
//    func loadPatients() {
//        patients = PatientService.shared.fetchPatients()
//    }
//
//    func numberOfPatients() -> Int {
//        return patients.count
//    }
//
//    func patient(at index: Int) -> PatientModel {
//        return patients[index]
//    }
//}


class HomeViewModel {

    private var allPatients: [PatientModel] = []

    private var upcoming: [PatientModel] = []
    private var missed: [PatientModel] = []
    private var done: [PatientModel] = []

    func loadPatients() {
        allPatients = PatientService.shared.fetchPatients()
        categorizePatients()
    }

    private func categorizePatients() {

        // demo logic (you can change later)
        upcoming = allPatients.filter { $0.status == .normal }
        missed   = allPatients.filter { $0.status == .critical }
        done     = allPatients.filter { $0.status == .warning }
    }

    func numberOfPatients(in section: Int) -> Int {
        switch section {
        case 1: return upcoming.count
        case 2: return missed.count
        case 3: return done.count
        default: return 0
        }
    }

    func patient(at index: Int, section: Int) -> PatientModel {
        switch section {
        case 1: return upcoming[index]
        case 2: return missed[index]
        case 3: return done[index]
        default: return upcoming[index]
        }
    }
}
