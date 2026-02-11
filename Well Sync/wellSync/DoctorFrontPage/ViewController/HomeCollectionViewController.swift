import UIKit

class HomeCollectionViewController: UICollectionViewController {

    private let viewModel = HomeViewModel()
   
    @IBOutlet weak var ellipsisButtonTapped: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupCollectionView()
        viewModel.loadPatients()
        setupMenu()

        collectionView.setCollectionViewLayout(createLayout(), animated: false)
    }
//    @IBAction func ellipsisButtonTapped(_ sender: Any) {
//        showMenu()
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

        collectionView.register(
            UINib(nibName: "SectionHeaderView", bundle: nil),
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: "header"
        )
    }
    func setupMenu() {

      
        let allPatients = UIAction(title: "All Patients",image: UIImage(systemName: "person")) { _ in
            self.openAllPatients()
        }

        let appointments = UIAction(title: "Appointments",
                                    image: UIImage(systemName: "calendar")) { _ in
            self.openAppointments()
        }

        let reminder = UIAction(title: "Reminder",
                                image: UIImage(systemName: "bell")) { _ in
            self.openReminder()
        }

        let settings = UIAction(title: "Settings",
                                image: UIImage(systemName: "gearshape")) { _ in
            self.openSettings()
        }

        let menu = UIMenu(title: "", children: [
            allPatients,
            appointments,
            reminder,
            settings
        ])

        ellipsisButtonTapped.menu = menu
       // ellipsisButtonTapped.showsMenuAsPrimaryAction = true
    }
    func openAllPatients() {
        print("All Patients")
    }

    func openAppointments() {
        print("Appointments")
    }

    func openReminder() {
        print("Reminder")
    }

    func openSettings() {
        print("Settings")
    }


}


extension HomeCollectionViewController {

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 4
    }

//    override func collectionView(_ collectionView: UICollectionView,
//                                 numberOfItemsInSection section: Int) -> Int {
//
//        if section == 0 {
//            return 2   // top cards
//        } else {
//            return viewModel.numberOfPatients()
//        }
//        
//    }
    override func collectionView(_ collectionView: UICollectionView,
                                 numberOfItemsInSection section: Int) -> Int {

        if section == 0 {
            return 2
        } else {
            return viewModel.numberOfPatients(in: section)
        }
    }

}
extension HomeCollectionViewController {

    override func collectionView(_ collectionView: UICollectionView,
                                 viewForSupplementaryElementOfKind kind: String,
                                 at indexPath: IndexPath) -> UICollectionReusableView {

        let header = collectionView.dequeueReusableSupplementaryView(
            ofKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: "header",
            for: indexPath
        ) as! SectionHeaderView

        if indexPath.section == 1 {
            header.configure(withTitle: "Upcoming")
        } else if indexPath.section == 2 {
            header.configure(withTitle: "Missed")
        } else if indexPath.section == 3 {
            header.configure(withTitle: "Done")
        }

        return header
    }
}
extension HomeCollectionViewController {

    override func collectionView(_ collectionView: UICollectionView,
                                 cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        // TOP SECTION
        if indexPath.section == 0 {
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "TopCell",
                for: indexPath
            ) as! TopSectionCollectionViewCell

            if indexPath.row == 0 {
                cell.configure(title: "Active Patients", subtitle: "24")
            } else {
                cell.configure(title: "Today's Session", subtitle: "5")
            }

            applyShadow(cell: cell)
            return cell
        }

        // PATIENT CELLS (section 1,2,3)
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "PatientCell",
            for: indexPath
        ) as! PatientCollectionViewCell

//        let patient = viewModel.patient(at: indexPath.row)
        let patient = viewModel.patient(at: indexPath.row, section: indexPath.section)

        cell.configureCell(with: patient)

        applyShadow(cell: cell)
        return cell
    }
}
extension HomeCollectionViewController {

    func applyShadow(cell: UICollectionViewCell) {
        cell.contentView.layer.masksToBounds = true
        cell.layer.cornerRadius = 16
        cell.layer.shadowColor = UIColor.black.cgColor
        cell.layer.shadowOpacity = 0.15
        cell.layer.shadowOffset = CGSize(width: 0, height: 6)
        cell.layer.shadowRadius = 10
        cell.layer.masksToBounds = false
    }
}
extension HomeCollectionViewController {

    func headerItem() -> NSCollectionLayoutBoundarySupplementaryItem {

        let headerSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(60)
        )

        return NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: headerSize,
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top
        )
    }

    func createLayout() -> UICollectionViewCompositionalLayout {
        UICollectionViewCompositionalLayout { sectionIndex, _ in
            return self.sectionLayout(for: sectionIndex)
        }
    }

    func sectionLayout(for section: Int) -> NSCollectionLayoutSection {

        let header = headerItem()

        switch section {
        case 0:
            return topSectionLayout()

        case 1,2,3:
            let layout = patientSectionLayout()
            layout.boundarySupplementaryItems = [header]
            return layout

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
            heightDimension: .absolute(150)
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
}
extension HomeCollectionViewController {

    override func collectionView(_ collectionView: UICollectionView,
                                 didSelectItemAt indexPath: IndexPath) {

        guard indexPath.section != 0 else { return }

//        let patient = viewModel.patient(at: indexPath.row)
        let patient = viewModel.patient(at: indexPath.row, section: indexPath.section)
        print(patient.name)


        performSegue(withIdentifier: "PatientDetail", sender: self)
    }
}

