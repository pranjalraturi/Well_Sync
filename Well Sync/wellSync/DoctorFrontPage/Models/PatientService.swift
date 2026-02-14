//
//  PatientService.swift
//  wellSync
//
//  Created by Pranjal on 05/02/26.
//

import UIKit

class PatientService {

    static let shared = PatientService()
    private init() {}

    
    func fetchPatients() -> [PatientModel] {

        return [
            PatientModel(id: UUID(),
                                 name: "Vidit Saran Agarwal",
                                 condition: "BPD",
                                 sessionCount: 7,
                                 lastSessionDate: "Last Session : 11 Nov 25",
                                 sessionTime: "10:30 AM",
                                 imageName: "profile",
                                 sessionStatus: .upcoming,
                         mood: .happy,
                         age: 28),

                    PatientModel(id: UUID(),
                                 name: "Kavya Bansal",
                                 condition: "ADHD",
                                 sessionCount: 5,
                                 lastSessionDate: "Last Session : 9 Nov 25",
                                 sessionTime: "12:30 PM",
                                 imageName: "profile",
                                 sessionStatus: .missed,
                                 mood: .sad,
                                 age: 28),

                    PatientModel(id: UUID(),
                                 name: "Rishika Mittal",
                                 condition: "Bipolar",
                                 sessionCount: 6,
                                 lastSessionDate: "Last Session : 13 Nov 25",
                                 sessionTime: "09:30 AM",
                                 imageName: "profile",
                                 sessionStatus: .done,
                                 mood: .neutral,
                                 age: 28),

                    // Upcoming
                    PatientModel(id: UUID(),
                                 name: "Arjun Mehta",
                                 condition: "Anxiety",
                                 sessionCount: 3,
                                 lastSessionDate: "Last Session : 15 Nov 25",
                                 sessionTime: "11:00 AM",
                                 imageName: "profile",
                                 sessionStatus: .upcoming,
                                 mood: .angry,
                                 age: 28),

                    PatientModel(id: UUID(),
                                 name: "Sanya Kapoor",
                                 condition: "Depression",
                                 sessionCount: 8,
                                 lastSessionDate: "Last Session : 18 Nov 25",
                                 sessionTime: "02:00 PM",

                                 imageName: "profile",
                                 sessionStatus: .upcoming,
                                 mood: .happy,
                                 age: 27),

                    PatientModel(id: UUID(),
                                 name: "Rohan Verma",
                                 condition: "Stress",
                                 sessionCount: 2,
                                 lastSessionDate: "Last Session : 20 Nov 25",
                                 sessionTime: "04:30 PM",
                                 imageName: "profile",
                                 sessionStatus: .upcoming,
                                 mood: .sad,
                                 age: 27),

                    // Missed
                    PatientModel(id: UUID(),
                                 name: "Isha Sharma",
                                 condition: "PTSD",
                                 sessionCount: 4,
                                 lastSessionDate: "Last Session : 5 Nov 25",
                                 sessionTime: "01:00 PM",
                                 imageName: "profile",
                                 sessionStatus: .missed,
                                 mood: .happy,
                                 age: 27),

                    PatientModel(id: UUID(),
                                 name: "Kabir Singh",
                                 condition: "Anger Issues",
                                 sessionCount: 6,
                                 lastSessionDate: "Last Session : 3 Nov 25",
                                 sessionTime: "05:30 PM",
                                 imageName: "photo",
                                 sessionStatus: .missed,
                                 mood: .happy,
                                 age: 27),

                    // Done
                    PatientModel(id: UUID(),
                                 name: "Meera Joshi",
                                 condition: "OCD",
                                 sessionCount: 10,
                                 lastSessionDate: "Last Session : 1 Nov 25",
                                 sessionTime: "10:00 AM",

                                 imageName: "profile",
                                 sessionStatus: .done,
                                 mood: .happy,
                                 age: 27),

                    PatientModel(id: UUID(),
                                 name: "Aditya Rao",
                                 condition: "Sleep Disorder",
                                 sessionCount: 9,
                                 lastSessionDate: "Last Session : 28 Oct 25",
                                 sessionTime: "08:30 AM",
                                 imageName: "profile",
                                 sessionStatus: .done,
                                 mood: .happy,
                                 age: 27)
        ]
    }
}
