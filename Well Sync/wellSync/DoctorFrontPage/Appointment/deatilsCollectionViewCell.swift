//
//  deatilsCollectionViewCell.swift
//  calendar
//
//  Created by Vidit Saran Agarwal on 15/03/26.
//

import UIKit

class deatilsCollectionViewCell: UICollectionViewCell, UITableViewDelegate, UITableViewDataSource {
//    var session:[SessionNote] = [
//        SessionNote(
//        sessionId: UUID(),
//        patientId: UUID(),
//        date: Date(),
//        notes: "Patient reported mild anxiety and difficulty sleeping. Recommended breathing exercises and journaling.",
//        images: "session1.jpg",
//        voice: "session1.m4a",
//        title: "Initial Consultation"
//        ),
//
//        SessionNote(
//        sessionId: UUID(),
//        patientId: UUID(),
//        date: Date(),
//        notes: "Mood improved slightly. Patient completed assigned mindfulness activity for 5 days.",
//        images: "session2.jpg",
//        voice: nil,
//        title: "Weekly Progress Review"
//        ),
//
//        SessionNote(
//        sessionId: UUID(),
//        patientId: UUID(),
//        date: Date(),
//        notes: "Discussed work stress and coping mechanisms. Introduced grounding techniques.",
//        images: nil,
//        voice: "session3.m4a",
//        title: "Stress Management Session"
//        ),
//
//        SessionNote(
//        sessionId: UUID(),
//        patientId: UUID(),
//        date: Date(),
//        notes: "Patient logged mood daily. Positive trend observed. Encouraged continuation of journaling.",
//        images: "session4.jpg",
//        voice: nil,
//        title: "Mood Tracking Review"
//        )]
    @IBOutlet weak var tableView: UITableView!
    
    var filteredPatients:[Patient] = []
    var sessions: [SessionNote] = []
    var filteredSessions: [SessionNote] = []
    
    override func awakeFromNib() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.sectionHeaderHeight = 0
        tableView.sectionFooterHeight = 0
        tableView.contentInset = .zero
        tableView.tableFooterView = UIView()
    }
    
    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {

        return filteredSessions.count
    }

    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(
            withIdentifier: "detailcell",
            for: indexPath
        ) as! deatilTableViewCell

        let session = filteredSessions[indexPath.row]

        if let idx = filteredPatients.firstIndex(where: { $0.patientID == session.patientId }) {
            let patient = filteredPatients[idx]
            cell.configureCell(patient: patient, session: session)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 95.0
    }
//    func updateDate(_ date: Date) {
//
//        let calendar = Calendar.current
//
//        filteredSessions = sessions.filter {
//            calendar.isDate($0.date, inSameDayAs: date)
//        }
//
//        tableView.reloadData()
//    }
//
    func updateDate(_ date: Date) {

        let calendar = Calendar.current
        let selectedDay = calendar.startOfDay(for: date)

//        filteredSessions = sessions.filter {
//            calendar.isDate(calendar.startOfDay(for: $0.date), inSameDayAs: selectedDay)
//        }
        filteredSessions = sessions.filter {
            Calendar.current.isDate($0.date, inSameDayAs: date)
        }
        tableView.reloadData()
    }
}

