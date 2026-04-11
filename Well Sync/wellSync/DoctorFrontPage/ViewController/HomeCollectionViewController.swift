import UIKit

class HomeCollectionViewController: UICollectionViewController {
    var patient: [Patient] = []
    var viewModel: AccessSupabase?
    var doctor: Doctor?{
        didSet{
            guard doctor != nil else { return }
            loadPatients()
        }
    }
    @IBOutlet weak var ellipsisButtonTapped: UIBarButtonItem!
    var selectedFilter: FilterType = .all
    var selectedPatient: Patient?
    
    let spinner = UIActivityIndicatorView(style: .large)


    override func viewDidLoad() {
        
        super.viewDidLoad()
        spinner.center = view.center
        view.addSubview(spinner)
        viewModel = AccessSupabase.shared
        setupCollectionView()
        self.collectionView.collectionViewLayout = createLayout()
        setupMenu()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadPatients()
        collectionView.reloadData()
    }

    func loadPatients() {
        guard let id = self.doctor?.docID else { return }
        spinner.startAnimating()

            Task {
                do {
                    let fetchedPatients = try await viewModel?.fetchPatients(for: id) ?? []

                    await MainActor.run {
                        self.patient = fetchedPatients
                        self.categorizePatients()
                        self.collectionView.reloadData()
                        self.spinner.stopAnimating()
                    }
                } catch {
                    print(error)
                    await MainActor.run {
                        self.spinner.stopAnimating()
                    }
                }
            }
    }
    
    var upcoming: [Patient] = []
    var missed: [Patient] = []
    var done: [Patient] = []

    // Categorize function
    private func categorizePatients() {
        upcoming.removeAll()
        missed.removeAll()
        done.removeAll()

        let now = Date()
        let calendar = Calendar.current
        

        for p in patient ?? [] {
            guard calendar.isDateInToday(p.nextSessionDate!) else { continue }

            if p.sessionStatus == true {
                done.append(p)
            }
            else if calendar.isDate(p.nextSessionDate ?? Date(), inSameDayAs: now) && p.nextSessionDate ?? Date() > now {
                upcoming.append(p)
            }
            else if p.nextSessionDate! < now {
                missed.append(p)
            }
        }
    }
    func filteredPatients() -> [Patient] {
        switch selectedFilter {
        case .all:
            return upcoming + missed + done
        case .upcoming:
            return upcoming
        case .missed:
            return missed
        case .done:
            return done
        }
    }

//    func numberOfPatients(in section: Int) -> Int {
//        switch section {
//        case 1: return upcoming.count
//        case 2: return missed.count
//        case 3: return done.count
//        default: return 0
//        }
//    }
    
//    func patientSection(at index: Int, section: Int) -> Patient {
//        switch section {
//        case 1: return upcoming[index]
//        case 2: return missed[index]
//        case 3: return done[index]
//        default: return upcoming[index]
//        }
//    }
    
    private func setupCollectionView() {

        collectionView.register(
            UINib(nibName: "PatientCollectionViewCell", bundle: nil),
            forCellWithReuseIdentifier: "PatientCell"
        )

        collectionView.register(
            UINib(nibName: "TopSectionCollectionViewCell", bundle: nil),
            forCellWithReuseIdentifier: "TopCell"
        )

//        collectionView.register(
//            UINib(nibName: "SectionHeaderView", bundle: nil),
//            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
//            withReuseIdentifier: "header"
//        )
        
        collectionView.register(
            UINib(nibName: "FilterCollectionViewCell", bundle: nil),
            forCellWithReuseIdentifier: "FilterCell"
        )
    }
    func setupMenu() {

      
        let profile = UIAction(title: "Profile",image: UIImage(systemName: "person")) { _ in
            self.openProfile()
        }

        let allPatients = UIAction(title: "All Patients",
                                    image: UIImage(systemName: "person.3")) { _ in
            self.openAllPatients()
        }

        let appointments = UIAction(title: "Appointments",
                                image: UIImage(systemName: "calendar")) { _ in
            self.openAppointments()
        }

        let settings = UIAction(title: "Settings",
                                image: UIImage(systemName: "gearshape")) { _ in
            self.openSettings()
        }

        let menu = UIMenu(title: "", children: [
            profile,
            allPatients,
            appointments,
            settings
        ])

        ellipsisButtonTapped.menu = menu
//        ellipsisButtonTapped.showsMenuAsPrimaryAction = true
    }
    func openAllPatients() {

        let storyboard = UIStoryboard(name: "AllPatient", bundle: nil)

        let vc = storyboard.instantiateViewController(
            withIdentifier: "AllPatientViewController"
        ) as! AllPatientCollectionViewController
        vc.doctor = doctor
        navigationController?.pushViewController(vc, animated: true)
    }

    func openAppointments() {

        let storyboard = UIStoryboard(name: "Appointment", bundle: nil)

        let vc = storyboard.instantiateViewController(
            withIdentifier: "appointment"
        ) as! AppointmentCollectionViewController   // ✅ cast

        vc.doctorID = doctor?.docID   // 🔥 THIS IS THE FIX

        navigationController?.pushViewController(vc, animated: true)
    }

    func openProfile() {
        let storyboard = UIStoryboard(name: "Doctor_Profile", bundle: nil)

        let vc = storyboard.instantiateViewController(
            withIdentifier: "doctorProfile"
        )

        navigationController?.pushViewController(vc, animated: true)
    }

    func openSettings() {
        let storyboard = UIStoryboard(name: "DoctorSetting", bundle: nil)

        let vc = storyboard.instantiateViewController(
            withIdentifier: "docSetting"
        )
        navigationController?.pushViewController(vc, animated: true)
    }



    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 3
    }

    
    override func collectionView(_ collectionView: UICollectionView,
                                 numberOfItemsInSection section: Int) -> Int {

        if section == 0 {
            return 2
        } else if section == 1{
            return 1
        } else {
            return filteredPatients().count
        }
    }

}
//extension HomeCollectionViewController {
//
//    override func collectionView(_ collectionView: UICollectionView,
//                                 viewForSupplementaryElementOfKind kind: String,
//                                 at indexPath: IndexPath) -> UICollectionReusableView {
//
//        let header = collectionView.dequeueReusableSupplementaryView(
//            ofKind: UICollectionView.elementKindSectionHeader,
//            withReuseIdentifier: "header",
//            for: indexPath
//        ) as! SectionHeaderView
//
//        if indexPath.section == 1 {
//            header.configure(withTitle: "Upcoming")
//        } else if indexPath.section == 2 {
//            header.configure(withTitle: "Missed")
//        } else if indexPath.section == 3 {
//            header.configure(withTitle: "Done")
//        }
//
//        return header
//    }
//}
extension HomeCollectionViewController {

    override func collectionView(_ collectionView: UICollectionView,
                                 cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        if indexPath.section == 0 {
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "TopCell",
                for: indexPath
            ) as! TopSectionCollectionViewCell

            if indexPath.row == 0 {
                    cell.configure(title: "Active Patients", subtitle: "\(patient.count)")
            } else {
                cell.configure(title: "Today's Session", subtitle: "\(upcoming.count+done.count+missed.count)")
            }

            applyShadow(cell: cell)
            return cell
        }
        
        if indexPath.section == 1 {
                let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: "FilterCell",
                    for: indexPath
                ) as! FilterCollectionViewCell

                cell.configure(
                    allCount: upcoming.count + missed.count + done.count,
                    upcomingCount: upcoming.count,
                    missedCount: missed.count,
                    doneCount: done.count
                )
                cell.onFilterSelected = { [weak self] filter in
                    guard let self = self else { return }
                    self.selectedFilter = filter
                    self.collectionView.reloadData()
                }

                return cell
            }
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "PatientCell",
            for: indexPath
        ) as! PatientCollectionViewCell

        let patient = filteredPatients()[indexPath.row]

        cell.configureCell(with: patient)

        applyShadow(cell: cell)
        return cell
    }
}
extension HomeCollectionViewController {

    func applyShadow(cell: UICollectionViewCell) {
        cell.contentView.layer.masksToBounds = true
        cell.layer.cornerRadius = 20
        cell.layer.shadowColor = UIColor.black.cgColor
        cell.layer.shadowRadius = 10
        cell.layer.masksToBounds = false
    }

//    func headerItem() -> NSCollectionLayoutBoundarySupplementaryItem {
//
//        let headerSize = NSCollectionLayoutSize(
//            widthDimension: .fractionalWidth(1.0),
//            heightDimension: .absolute(60)
//        )
//
//        return NSCollectionLayoutBoundarySupplementaryItem(
//            layoutSize: headerSize,
//            elementKind: UICollectionView.elementKindSectionHeader,
//            alignment: .top
//        )
//}

    func createLayout() -> UICollectionViewCompositionalLayout {
        UICollectionViewCompositionalLayout { sectionIndex, _ in
            return self.sectionLayout(for: sectionIndex)
        }
    }

    func sectionLayout(for section: Int) -> NSCollectionLayoutSection {

//        let header = headerItem()

        switch section {
        case 0:
            return topSectionLayout()

        case 1:
            return filterSectionLayout()
            
        case 2:
            return patientSectionLayout()
        default:
            return patientSectionLayout()
        }
    }

    func topSectionLayout() -> NSCollectionLayoutSection {

        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(0.5),
            heightDimension: .fractionalHeight(1.0)
        )

        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(120)
        )

        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: groupSize,
            subitems: [item]
        )

        group.interItemSpacing = .fixed(10)

        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 10
        section.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16)

        return section
    }

    func patientSectionLayout() -> NSCollectionLayoutSection {

        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .fractionalHeight(1.0)
        )

        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(170)
        )

        let group = NSCollectionLayoutGroup.vertical(
            layoutSize: groupSize,
            subitems: [item]
        )

        group.contentInsets = NSDirectionalEdgeInsets(top: 16, leading: 16, bottom: 0, trailing: 16)

        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 8

        return section
    }
    
    func filterSectionLayout() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .fractionalHeight(1.0)
        )
        
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(40))
        
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16)
        return section
    }
    
    override func collectionView(_ collectionView: UICollectionView,
                                 didSelectItemAt indexPath: IndexPath) {

        guard indexPath.section == 2 else { return }

        let patient = filteredPatients()[indexPath.row]
        //print(patient.name)
        selectedPatient = patient
        performSegue(withIdentifier: "PatientDetail", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "PatientDetail" {
            let destinationVC = segue.destination as! PatientDetailCollectionViewController
            destinationVC.patient = selectedPatient
        }
        if segue.identifier == "AddPatientSegue" {
            
            if let nav = segue.destination as? UINavigationController,
               let destinationVC = nav.topViewController as? AddPatientTableViewController {
                destinationVC.doctor = doctor
                destinationVC.onDismiss = { [weak self] in
                    guard let self = self else { return }

                        if let newPatient = destinationVC.patient {
                            self.patient.append(newPatient)
                            self.categorizePatients()
                            self.collectionView.reloadData()
                        }
                }
            }
        }
    }
}

