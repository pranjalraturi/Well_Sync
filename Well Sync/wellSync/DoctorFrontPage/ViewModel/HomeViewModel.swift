//
//  HomeViewModel.swift
//  wellSync
//
//  Created by Pranjal on 05/02/26.
//

import UIKit



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
        upcoming = allPatients.filter { $0.sessionStatus == .upcoming }
        missed   = allPatients.filter { $0.sessionStatus == .missed }
        done     = allPatients.filter { $0.sessionStatus == .done }
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
