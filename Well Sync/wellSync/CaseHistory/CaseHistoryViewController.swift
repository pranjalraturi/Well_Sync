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
    
    var caseHistory: CaseHistory?
    var timeline: [Timeline] = []
    var reports: [Report] = []
    var selectedImage: UIImage?
    var selectedURL: URL?
    var generatedReportURl: URL?
    var patient: Patient!
    override func viewDidLoad() {
        super.viewDidLoad()
        registerCells()
        CaseHistoryCollectionView.dataSource = self
        
        let layout = generateLayout()
        CaseHistoryCollectionView.setCollectionViewLayout(layout, animated: true)
        loadData()
        CaseHistoryCollectionView.delegate = self
    }
    
    func loadData(){
        Task {
               do {
                   let full = try await AccessSupabase.shared
                       .fetchFullCaseHistory(for: patient.patientID)

                   self.caseHistory = full
                   self.timeline = full.timeline ?? []
                   self.reports = full.report ?? []

                   await MainActor.run {
                       self.CaseHistoryCollectionView.reloadData()
                   }
               } catch {
                   print("Error:", error)
               }
           }
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
//        if let data = try? Data(contentsOf: url),
//            let image = UIImage(data: data){
//            selectedImage = image
//        }
        selectedImage = nil
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
//            let text = alert.textFields?.first?.text ?? ""
//            let name = text.isEmpty ? "Report" : text
//            let newReport = Report(
//                reportId: UUID(),
//                caseId: self.caseHistory.caseId,
//                    title: name,
//                    date: Date(),
//                reportPath: [self.selectedURL?.path ?? ""]
//                )
//            self.reports.insert(newReport, at: 0)
//            self.CaseHistoryCollectionView.reloadSections(IndexSet(integer: 0))
            
            guard let name = alert.textFields?.first?.text, !name.isEmpty else { return }
            self.uploadReportAndSave(name: name)
        }
        alert.addAction(nameAction)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }
    func uploadReportAndSave(name: String) {
        guard let caseId = caseHistory?.caseId else {
            print("caseHistory is nil")
            return }
        print(" caseId:", caseId)
        Task {
            do {
                var fileData: Data?
                var fileName = "file"
                var contentType = "application/octet-stream"

                if let image = selectedImage {
                    print(" Uploading image")
                    fileData = image.jpegData(compressionQuality: 0.8)
                    fileName = "image.jpg"
                    contentType = "image/jpeg"
                } else if let url = selectedURL {
                    print("Uploading document:", url)
                    fileData = try Data(contentsOf: url)
                    fileName = url.lastPathComponent
                    contentType = "application/pdf"
                }

                guard let data = fileData else { print("No data found")
                    return }
                print("Uploading to Supabase...")
                let url = try await AccessSupabase.shared.uploadReport(
                    data: data,
                    fileName: fileName,
                    contentType: contentType
                )
                print("Uploaded URL:", url)
                let report = Report(
                    reportId: UUID(),
                    caseId: caseId,
                    title: name,
                    date: Date(),
                    reportPaths: [url]
                )
                print("Saving to DB...")
                
                let saved = try await AccessSupabase.shared.saveReport(report)
                print("Saved in DB:", saved)

                await MainActor.run{
                    self.reports.insert(saved, at: 0)
                    self.CaseHistoryCollectionView.reloadSections(IndexSet(integer: 0))
                }

            } catch {
                print("Upload Error:", error)
            }
        }
    }
}

extension CaseHistoryViewController: QLPreviewControllerDataSource, UICollectionViewDelegate{
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
        guard let caseHistory = self.caseHistory else {
                print("No case history")
                return
            }
        if let url = ReportGenerator.createPDF(patient: patient, history: caseHistory){
            self.generatedReportURl = url
            
            let previewController = QLPreviewController()
            previewController.dataSource = self
            present(previewController, animated: true)
        }else {
            print("PDF generation failed")
        }
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
            if indexPath.section == 0 {
                let report = reports[indexPath.item]
                openReport(report)
            }
        }
    
    func openReport(_ report: Report) {
        guard let path = report.reportPaths.first,
              let url = URL(string: path) else { return }

        self.generatedReportURl = url
        
        let preview = QLPreviewController()
        preview.dataSource = self
        present(preview, animated: true)
    }
    
}
