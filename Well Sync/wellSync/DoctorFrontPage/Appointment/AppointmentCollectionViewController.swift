//
//  AppointmentCollectionViewController.swift
//  wellSync
//
//  Created by Pranjal on 11/03/26.
//

import UIKit

class AppointmentCollectionViewController: UICollectionViewController {

    var currentDoctor: Doctor?
    var selectedDate: Date = Date()

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    var appointmentsForSelectedDay: [Patient] {

        guard let doctor = currentDoctor else { return [] }

        return doctor.Patients.filter {

            Calendar.current.isDate($0.nextSessionDate,
                                    inSameDayAs: selectedDate)

        }.sorted {

            $0.nextSessionDate < $1.nextSessionDate

        }
    }

    // MARK: - Sections

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }

    // MARK: - Items

    override func collectionView(_ collectionView: UICollectionView,
                                 numberOfItemsInSection section: Int) -> Int {

        if section == 0 { return 1 }

        return appointmentsForSelectedDay.count
    }

    // MARK: - Cells

    override func collectionView(_ collectionView: UICollectionView,
                                 cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        if indexPath.section == 0 {

            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "CalendarCollectionViewCell",
                for: indexPath
            ) as! CalendarCollectionViewCell

            cell.delegate = self
            return cell
        }

        let patient = appointmentsForSelectedDay[indexPath.row]

        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "PatientCollectionViewCell",
            for: indexPath
        ) as! PatientCollectionViewCell

        cell.configure(patient: patient)

        return cell
    }
}

extension AppointmentCollectionViewController: CalendarSelectionDelegate {

    func didSelectDate(_ date: Date) {

        selectedDate = date

        collectionView.reloadSections(IndexSet(integer: 1))

    }
}

extension AppointmentCollectionViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {

        let width = collectionView.frame.width - 32

        if indexPath.section == 0 {
            return CGSize(width: width, height: 320)
        }

        return CGSize(width: width, height: 120)
    }
}
