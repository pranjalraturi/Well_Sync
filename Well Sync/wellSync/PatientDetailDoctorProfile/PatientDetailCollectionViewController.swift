//
//  PatientDetailCollectionViewController.swift
//  wellSync
//
//  Created by Rishika Mittal on 06/02/26.
//

import UIKit

class PatientDetailCollectionViewController: UICollectionViewController{

    @IBOutlet weak var PatientProfileCollectionView: UICollectionView!
    
  var patient: Patient!

    override func viewDidLoad() {
        super.viewDidLoad()
//        print(patient.name)
        registerCells()
        let Layout = generateLayout()
        PatientProfileCollectionView.setCollectionViewLayout(Layout, animated: true)
        
        PatientProfileCollectionView.delegate = self
        PatientProfileCollectionView.dataSource = self
    }
    func registerCells(){
        PatientProfileCollectionView.register(UINib(nibName: "ProfileCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "ProfileCollectionViewCell")
    }
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0{
            return 1
        }
        return 6
     }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.section == 0{
            let profilecell = collectionView.dequeueReusableCell(withReuseIdentifier: "ProfileCollectionViewCell", for: indexPath) as! ProfileCollectionViewCell
            profilecell.configureCell(with: patient)
            profilecell.delegate = self
            return profilecell
        }
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "detailCell", for: indexPath) as! DetailCollectionViewCell
        cell.configure(index: indexPath.row)
        return cell
    }
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "Summarised" {
            let destination     = segue.destination as! SummarisedReportTableViewController
            destination.patient = patient
        }
        if segue.identifier == "activity" {
            let destination     = segue.destination as! DoctorActivityStatusCollectionViewController
            destination.patient = patient
        }
        if segue.identifier == "sessionNotes",
               let vc = segue.destination as? SessionNoteCollectionViewController {
                vc.patient = self.patient   
            }
    }
    
}


extension PatientDetailCollectionViewController{
    
    func generateLayout() -> UICollectionViewLayout {

           let layout = UICollectionViewCompositionalLayout { [weak self]
               sectionIndex, environment -> NSCollectionLayoutSection in

               guard let self = self else {
                   return self!.generateSectionForDetailCells()
               }

               switch sectionIndex {
               case 0:
                   return self.generateSectionForProfile()
               default:
                   return self.generateSectionForDetailCells()
               }
           }
            
            
        layout.register(RoundedBackgroundCollectionReusableView.self,
                        forDecorationViewOfKind: "background")

           return layout
       }
    func cardStyle(cell:UICollectionViewCell){
        cell.backgroundColor = .systemBackground
        cell.layer.masksToBounds = false
        cell.layer.shadowColor = UIColor.black.cgColor
        cell.layer.shadowOpacity = 0.08
        cell.layer.shadowRadius = 10
        cell.layer.shadowOffset = CGSize(width: 0, height: 4)
    }
    func generateSectionForProfile() -> NSCollectionLayoutSection{
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(160))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            
            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(160))
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 1)
            
            let section = NSCollectionLayoutSection(group: group)
            
            section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 16, trailing: 0)
        return section
    }
    
    func generateSectionForDetailCells() -> NSCollectionLayoutSection {

        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(70)
        )

        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(70)
        )

        let group = NSCollectionLayoutGroup.vertical(
            layoutSize: groupSize,
            subitem: item,
            count: 1
        )

        let section = NSCollectionLayoutSection(group: group)

        section.contentInsets = NSDirectionalEdgeInsets(
            top: 4,
            leading: 28,
            bottom: 4,
            trailing: 28
        )

        let backgroundItem = NSCollectionLayoutDecorationItem.background(
            elementKind: "background"
        )

        backgroundItem.contentInsets = NSDirectionalEdgeInsets(
            top: -8,
            leading: 16,
            bottom: -8,
            trailing: 16
        )

        
        section.decorationItems = [backgroundItem]
        return section
    }

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch indexPath.section
        {
        case 1:
            switch indexPath.row {
            case 0:
                performSegue(withIdentifier: "sessionNotes", sender: nil)
            case 1:
                performSegue(withIdentifier: "Summarised", sender: nil)
            case 2:
                performSegue(withIdentifier: "mood", sender: nil)
            case 3:
                performSegue(withIdentifier: "activity", sender: nil)
            case 4:
                performSegue(withIdentifier: "vitals", sender: nil)
            case 5:
                performSegue(withIdentifier: "case", sender: nil)
            default:
                break
            }
        default:
            break
            
        }
    }
    @IBAction func doneButtonTapped(_ sender: UIBarButtonItem){
        let alert = UIAlertController(title: "Session Note", message: "Have you Added the session Note?", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { _ in
                self.showSecondAlert(option: 1)
            }))
            alert.addAction(UIAlertAction(title: "Later", style: .default, handler: { _ in
                self.showSecondAlert(option: 0)
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: .destructive))
            present(alert, animated: true)
        }
    func showSecondAlert(option: Int) {
        let alert = UIAlertController(title: "Next Session Date", message: "Have you schedule the next session?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { _ in
            self.showThirdAlert(option: 1)
        }))
        alert.addAction(UIAlertAction(title: "Later", style: .default, handler: { _ in
            self.showThirdAlert(option: 0)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .destructive))
        present(alert, animated: true)
    }
    func showThirdAlert(option: Int) {
        let alert = UIAlertController(title: "Session Completed", message: "You have marked this session as Done", preferredStyle: .alert)
        let done = UIAlertAction(title: "OK", style: .default){_ in
            if let index = globalPatient.firstIndex(where: { $0.patientID == self.patient.patientID }) {
                globalPatient[index].sessionStatus = true
            }
        }
        done.setValue(UIColor.systemGreen, forKey: "titleTextColor")
        alert.addAction(done)
        present(alert, animated: true)
    }
    
    
//    func showScheduleAlert(sourceView: UIView) {
//
//        let alert = UIAlertController(title: "",
//                                      message: "\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n",
//                                      preferredStyle: .actionSheet)
//
//        let calendarView = UICalendarView()
//           calendarView.translatesAutoresizingMaskIntoConstraints = false
//           calendarView.calendar = .current
//           calendarView.locale = .current
//           calendarView.fontDesign = .rounded
//           let selection = UICalendarSelectionSingleDate(delegate: self)
//           calendarView.selectionBehavior = selection
//           alert.view.addSubview(calendarView)
//        
//        let divider = UIView()
//           divider.backgroundColor = UIColor.separator
//           divider.translatesAutoresizingMaskIntoConstraints = false
//           alert.view.addSubview(divider)
//        
//        let timeLabel = UILabel()
//            timeLabel.text = "Time"
//            timeLabel.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
//            timeLabel.translatesAutoresizingMaskIntoConstraints = false
//            alert.view.addSubview(timeLabel)
//        
//        let timePicker = UIDatePicker()
//           timePicker.datePickerMode = .time
//           timePicker.preferredDatePickerStyle = .wheels
//           timePicker.translatesAutoresizingMaskIntoConstraints = false
//           alert.view.addSubview(timePicker)
//        
//        NSLayoutConstraint.activate([
//            calendarView.topAnchor.constraint(equalTo: alert.view.topAnchor, constant: 0),
//               calendarView.leadingAnchor.constraint(equalTo: alert.view.leadingAnchor, constant: 8),
//               calendarView.trailingAnchor.constraint(equalTo: alert.view.trailingAnchor, constant: -8),
//            calendarView.heightAnchor.constraint(equalToConstant: 280),
//            
//            divider.topAnchor.constraint(equalTo: calendarView.bottomAnchor, constant: 6),
//                   divider.leadingAnchor.constraint(equalTo: alert.view.leadingAnchor, constant: 16),
//                   divider.trailingAnchor.constraint(equalTo: alert.view.trailingAnchor, constant: -16),
//                   divider.heightAnchor.constraint(equalToConstant: 0.5),
//
//               timeLabel.topAnchor.constraint(equalTo: calendarView.bottomAnchor, constant: 16),
//               timeLabel.leadingAnchor.constraint(equalTo: alert.view.leadingAnchor, constant: 20),
//
//               timePicker.topAnchor.constraint(equalTo: timeLabel.bottomAnchor, constant: 0),
//               timePicker.leadingAnchor.constraint(equalTo: alert.view.leadingAnchor, constant: 8),
//               timePicker.trailingAnchor.constraint(equalTo: alert.view.trailingAnchor, constant: -8),
//               timePicker.heightAnchor.constraint(equalToConstant: 100),
//            ])
//        let schedule = UIAlertAction(title: "Schedule", style: .default){_ in
//            print("Time Selected:", timePicker.date)
//        }
//        let cancel = UIAlertAction(title: "Cancel", style: .cancel)
//        alert.addAction(schedule)
//        alert.addAction(cancel)
//        
//        if let popover = alert.popoverPresentationController {
//            popover.sourceView = sourceView
//            popover.sourceRect = sourceView.bounds
//        }
//        present(alert, animated: true)
//    }
}
extension PatientDetailCollectionViewController: ProfileCellDelegate {
    func calendarButtonTapped(from view: UIView){
        showScheduleAlert(sourceView: view)
    }
    func showScheduleAlert(sourceView: UIView){
        let popoverVC = ScheduleViewController()
        popoverVC.patient = self.patient
        popoverVC.scheduleDate = self.patient.nextSessionDate
        
        popoverVC.modalPresentationStyle = .popover
        
        popoverVC.preferredContentSize = CGSize(width: 350, height: 620)
        
        if let popover = popoverVC.popoverPresentationController {
            popover.sourceView = sourceView
            popover.sourceRect = sourceView.bounds
            popover.permittedArrowDirections = .any
            popover.delegate = self
        }
        popoverVC.onScheduleConfirmed = { [weak self] selectedFullDate in
            guard let self = self else{return}
            print("Selected date: \(selectedFullDate)")
            self.patient.nextSessionDate = selectedFullDate
            
            let formatter = DateFormatter()
            formatter.dateFormat = "MMM dd"
            let dateString = formatter.string(from: selectedFullDate)
            
            if let profileCell = self.PatientProfileCollectionView.cellForItem(at: IndexPath(item: 0, section: 0)) as? ProfileCollectionViewCell{
                profileCell.calendarButton.setTitle("   \(dateString)", for: .normal)
            }
        }
        present(popoverVC, animated: true)
    }
}

extension PatientDetailCollectionViewController: UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
}
//extension PatientDetailCollectionViewController: UICalendarSelectionSingleDateDelegate {
//
//    func dateSelection(_ selection: UICalendarSelectionSingleDate,
//                       didSelectDate dateComponents: DateComponents?) {
//
//        guard let components = dateComponents,
//              let date = Calendar.current.date(from: components) else { return }
//
//        print("Selected date:", date)
//    }
//}
