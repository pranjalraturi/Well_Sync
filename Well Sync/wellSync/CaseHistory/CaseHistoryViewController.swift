//
//  CaseHistoryViewController.swift
//  wellSync
//
//  Created by GEU on 09/03/26.
//

import UIKit
import UniformTypeIdentifiers
import QuickLook

class CaseHistoryViewController: UIViewController {
    @IBOutlet weak var CaseHistoryCollectionView: UICollectionView!
    
    var caseHistory: CaseHistory!
    var timeline: [Timeline] = []
    var reports: [Report] = []
    var selectedImage: UIImage?
    var selectedURL: URL?
    var generatedReportURl: URL?
    var patient: Patient!
    override func viewDidLoad() {
        super.viewDidLoad()
        Task{
            do{
                caseHistory = try await AccessSupabase.shared.fetchCaseHistory(for: patient.patientID)
                timeline = try await AccessSupabase.shared
                    .fetchTimelines(for: caseHistory.caseId)
                reports = try await AccessSupabase.shared
                    .fetchReports(for: caseHistory.caseId)
            }
            catch{
                print("Error Case History: ",error)
            }
            
        }
        registerCells()
        let layout = generateLayout()
        CaseHistoryCollectionView.setCollectionViewLayout(layout, animated: true)
        
        CaseHistoryCollectionView.dataSource = self
    }
    func registerCells(){
        CaseHistoryCollectionView.register(UINib(nibName: "ReportCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "ReportCell")
        CaseHistoryCollectionView.register(UINib(nibName: "TimelineCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "TimelineCell")
        CaseHistoryCollectionView.register(UINib(nibName: "HeaderView", bundle: nil), forSupplementaryViewOfKind: "header", withReuseIdentifier: "Heading")
        CaseHistoryCollectionView.register(UINib(nibName: "ReportAddHeadingView", bundle: nil), forSupplementaryViewOfKind: "header", withReuseIdentifier: "MedicalHeading")
    }
  

}

extension CaseHistoryViewController: UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0{
            return reports.count
        }else if section == 1{
            return timeline.count
        }
        return 0
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.section == 0{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ReportCell", for: indexPath)
            guard let reportCell = cell as? ReportCollectionViewCell else {
                return cell
            }
            let report = reports[indexPath.item]
            reportCell.configureCell(report: report)
            return cell
        }else if indexPath.section == 1{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TimelineCell", for: indexPath)
            guard let TimelineCell = cell as? TimelineCollectionViewCell else {
                return cell
            }
            let timeline = timeline[indexPath.item]
            TimelineCell.configureCell(timeline: timeline)
            return cell
        }
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TimelineCell", for: indexPath)
        guard let TimelineCell = cell as? TimelineCollectionViewCell else {
            return cell
        }
        let timeline = timeline[indexPath.item]
        TimelineCell.configureCell(timeline: timeline)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        var Heading: HeaderView!
        var MedicalHeading: ReportAddHeadingView!
        
        if kind == "header"{
            if indexPath.section == 0{
                MedicalHeading = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "MedicalHeading", for: indexPath) as? ReportAddHeadingView
                MedicalHeading.configure(title: "Medical Report")
                MedicalHeading.selectedMenu = { [weak self] option in
                    if option == "camera"{
                        self?.openCamera()
                    }else if option == "photo"{
                        self?.gallery()
                    }else if option == "document"{
                        self?.openDocument()
                    }
                }
                return MedicalHeading
            }else if indexPath.section == 1{
                Heading = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "Heading", for: indexPath) as? HeaderView
                Heading.configure(title: "Treatment Timeline")
                return Heading
            }
        }
        return Heading
    }
    func generateLayout() -> UICollectionViewLayout{
        let layout = UICollectionViewCompositionalLayout { (sectionIndex: Int, environment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection in
            let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(40))
            let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: "header", alignment: .topLeading)
            if sectionIndex == 0{
                let section = self.generateSectionForReport()
                section.boundarySupplementaryItems = [header]
                return section
            }else if sectionIndex == 1{
                let section = self.generateSectionForTimeline()
                section.boundarySupplementaryItems = [header]
                return section
            }
            return self.generateSectionForTimeline()
        }
        return layout
    }
        
        func generateSectionForReport() -> NSCollectionLayoutSection{
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            item.contentInsets = NSDirectionalEdgeInsets(
                top: 0,
                leading: 0,
                bottom: 0,
                trailing: 12
            )
            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.45), heightDimension: .absolute(120.0))
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize,subitems: [item])
            let section = NSCollectionLayoutSection(group: group)
            section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 16, bottom: 10, trailing: 16)
            section.orthogonalScrollingBehavior = .groupPaging
            return section
        }
    
      func generateSectionForTimeline() -> NSCollectionLayoutSection{
          let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(120))
          let item = NSCollectionLayoutItem(layoutSize: itemSize)
          item.contentInsets = NSDirectionalEdgeInsets(
                  top: 6,
                  leading: 6,
                  bottom: 6,
                  trailing: 6
              )
          let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(120))
          let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, repeatingSubitem: item, count: 1)
          group.interItemSpacing = .fixed(5)
          let section = NSCollectionLayoutSection(group: group)
          section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 16, bottom: 20, trailing: 16)
  //        section.orthogonalScrollingBehavior = .groupPaging
          section.interGroupSpacing = 12
          return section
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
   
}

extension CaseHistoryViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIDocumentPickerDelegate{
    

    func openCamera() {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.allowsEditing = true
        picker.delegate = self
        present(picker, animated: true)
    }
    func gallery(){
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        picker.delegate = self
        present(picker, animated: true)
    }
    func openDocument(){
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: [.pdf, .text, .jpeg, .png])
        picker.delegate = self
        picker.allowsMultipleSelection = true
        present(picker, animated: true)
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.originalImage] as? UIImage?{
        selectedImage = image
        }
        picker.dismiss(animated: true)
        self.NamingAlert()
    }
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let url = urls.first else { return }
        selectedURL = url
        if let data = try? Data(contentsOf: url),
            let image = UIImage(data: data){
            selectedImage = image
        }
        self.NamingAlert()
    }
    
    func NamingAlert(){
        let alert = UIAlertController(title: "Add Report", message: "\n\n\n\n", preferredStyle: .alert)
        let preview = UIImageView(frame: CGRect(x: 30, y: 50, width: 100, height: 100))
        preview.contentMode = .scaleAspectFill
        preview.image = selectedImage
        preview.clipsToBounds = true
        preview.layer.cornerRadius = 20
        preview.layer.masksToBounds = true
        
        alert.view.addSubview(preview)
        alert.addTextField{textField in
          textField.placeholder = "Enter Report Name"
        }
        
        let nameAction = UIAlertAction(title: "Add", style: .default) { _ in
            let text = alert.textFields?.first?.text ?? ""
            let name = text.isEmpty ? "Report" : text
            let newReport = Report(
                reportId: UUID(),
                caseId: self.caseHistory.caseId,
                    title: name,
                    date: Date(),
                reportPath: [self.selectedURL?.path ?? ""]
                )
            self.reports.insert(newReport, at: 0)
            self.CaseHistoryCollectionView.reloadSections(IndexSet(integer: 0))
        }
        alert.addAction(nameAction)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }
}

extension CaseHistoryViewController: QLPreviewControllerDataSource{
    func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
        return 1
    }
    
    func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
        guard let url = generatedReportURl else{
            return URL(fileURLWithPath: "") as QLPreviewItem
        }
        return url as QLPreviewItem
    }
    
    @IBAction func downLoadButtonTapped(_ sender: Any) {
//        guard let currentPatient = self.patient else {
//                print("Error: Patient data is missing")
//                return
//            }
//            
//            guard let currentHistory = self.caseHistory else {
//                print("Error: Case History data is missing")
//                return
//            }
      /*  if let url = ReportGenerator.createPDF(patient: currentPatient, history: currentHistory)*/
        if let url = ReportGenerator.createPDF(history: caseHistory){
            self.generatedReportURl = url
            
            let previewController = QLPreviewController()
            previewController.dataSource = self
            present(previewController, animated: true)
        }
    }
}
