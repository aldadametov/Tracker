import UIKit

protocol TrackerCreationDelegate: AnyObject {
    func didCreateTracker(_ tracker: Tracker, category: TrackerCategory, isEvent: Bool)
    func didUpdateTracker(_ tracker: Tracker, category: String)
}

final class TrackerCreationViewController: UIViewController, ScheduleSelectionDelegate, CategorySelectionDelegate {
    
    private let trackerRecordStore = TrackerRecordStore()
    
    weak var delegate: TrackerCreationDelegate?
    
    var schedule: [Schedule] = []
    
    var isEvent: Bool = false
    
    var trackerToEdit: Tracker?
    
    init(trackerToEdit: Tracker? = nil,
         category: String? = nil,
         isEvent: Bool = false) {
        
        self.trackerToEdit = trackerToEdit
        self.isEvent = isEvent
        
        if let tracker = trackerToEdit {
            self.selectedEmoji = tracker.emoji
            self.selectedColor = tracker.color ?? .clear
            self.selectedCategory = category ?? ""
            self.schedule = tracker.schedule
            selectedEmojiIndexPath = IndexPath(item: emojis.firstIndex(of: tracker.emoji) ?? 0, section: 0)
            selectedColorIndexPath = IndexPath(item: UIColor.colorSelection.firstIndex(of: tracker.color ?? .clear) ?? 0, section: 1)
        } else {
            self.selectedEmoji = ""
            self.selectedColor = .clear
            self.selectedCategory = category ?? ""
        }
        createButton.setTitle(trackerToEdit != nil ? "Сохранить" : "Создать", for: .normal)
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let emojis = ["🙂", "😻", "🌺", "🐶", "❤️", "😱", "😇", "😡", "🥶", "🤔", "🙌", "🍔", "🥦", "🏓", "🥇", "🎸", "🌴", "😪"]
    private var selectedEmoji: String
    private var selectedColor: UIColor
    private var selectedEmojiIndexPath: IndexPath?
    private var selectedColorIndexPath: IndexPath?
    private var selectedCategory: String
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    private lazy var contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Новая Привычка"
        label.frame = CGRect(x: 0, y: 0, width: 149, height: 22)
        label.textColor = .ypBlack
        label.font = UIFont(name: "SFPro-Medium", size: 16)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let daysCountLabel: UILabel = {
        let label = UILabel()
        label.frame = CGRect(x: 0, y: 0, width: 103, height: 38)
        label.textColor = .ypBlack
        label.font = UIFont(name: "SFPro-Bold", size: 32)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let nameTextField: UITextField = {
        let textField = UITextField()
        textField.backgroundColor = .ypBackgroundDay
        textField.font = UIFont(name: "SFPro-Regular", size: 17)
        textField.layer.cornerRadius = 16
        textField.layer.borderWidth = 0
        textField.layer.masksToBounds = true
        textField.translatesAutoresizingMaskIntoConstraints = false
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: textField.frame.height))
        textField.leftView = paddingView
        textField.leftViewMode = .always

        let placeholderText = "Введите название трекера"
        textField.attributedPlaceholder = NSAttributedString(
            string: placeholderText,
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.ypGray]
        )
        return textField
    }()
    
    private let clearButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(systemName: "xmark.circle.fill")?.withRenderingMode(.alwaysTemplate), for: .normal)
        button.tintColor = .lightGray
        button.frame = CGRect(x: 0, y: 0, width: 20, height: 20)
        button.contentEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 12)
        button.contentMode = .scaleAspectFit
        button.isHidden = true
        return button
    }()
    
    private let maxCharacterCount = 38
    
    private lazy var symbolsLimitLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Ограничение 38 символов"
        label.font = UIFont(name: "SFPro-Regular", size: 17)
        label.textColor = .ypRed
        label.textAlignment = .center
        label.isHidden = true
        return label
    }()
    
    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        let cornerRadius: CGFloat = 16.0
        tableView.layer.cornerRadius = cornerRadius
        tableView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        tableView.layer.masksToBounds = true
        tableView.isScrollEnabled = false
        return tableView
    }()
    
    private var tableViewHeightConstraint: NSLayoutConstraint?
    private var contentViewHeightConstraint: NSLayoutConstraint?
    
    private lazy var emojiAndColorCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .ypWhite
        collectionView.isScrollEnabled = false
        collectionView.allowsMultipleSelection = true
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    private let cancelButton: UIButton = {
        let button = UIButton()
        button.setTitle("Отменить", for: .normal)
        button.setTitleColor(UIColor.ypRed, for: .normal)
        button.titleLabel?.font = UIFont(name: "SFPro-Medium", size: 16)
        button.layer.cornerRadius = 16
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.ypRed.cgColor
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let createButton: UIButton = {
        let button = UIButton()
        button.setTitle("Создать", for: .normal)
        button.backgroundColor = .ypGray
        button.titleLabel?.font = UIFont(name: "SFPro-Medium", size: 16)
        button.layer.cornerRadius = 16
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ypWhite
        if let _ = trackerToEdit {
        } else {
            selectedCategory = UserDefaults.standard.string(forKey: "selectedCategory") ?? ""
        }
        addSubviews()
        setupCollectionView()
        setupTableView()
        setupConstraints()
        configureInitialValues()
        setupActions()
        hideKeyboardWhenTappedAround()
        tableView.separatorColor = .ypGray
        DispatchQueue.main.async { [weak self] in
            self?.selectInitialCollectionViewItems()
        }
    }
    
    
    private func setupCollectionView() {
        emojiAndColorCollectionView.register(EmojiCollectionViewCell.self, forCellWithReuseIdentifier: "EmojiCell")
        emojiAndColorCollectionView.register(ColorCollectionViewCell.self, forCellWithReuseIdentifier: "ColorCell")
        emojiAndColorCollectionView.register(SectionHeaderCollectionReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "SectionHeader")
        emojiAndColorCollectionView.delegate = self
        emojiAndColorCollectionView.dataSource = self
        emojiAndColorCollectionView.reloadData()
    }
    
    private func setupTableView() {
        tableView.register(CustomTableViewCell.self, forCellReuseIdentifier: "CustomCell")
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    private func configureInitialValues() {
        titleLabel.text = trackerToEdit != nil ? "Редактирование трекера" : (isEvent ? "Новое нерегулярное событие" : "Новая Привычка")
        tableViewHeightConstraint?.constant = isEvent ? 75 : 150
        tableView.layoutIfNeeded()
        if trackerToEdit != nil {
            contentViewHeightConstraint?.constant = isEvent ? 850 : 925
        } else {
            contentViewHeightConstraint?.constant = isEvent ? 800 : 875
        }
        contentView.layoutIfNeeded()
        
        updateConstraintsForDaysCountLabel()
        if let tracker = trackerToEdit {
            nameTextField.text = tracker.name
            schedule = tracker.schedule
            selectedEmojiIndexPath = IndexPath(item: emojis.firstIndex(of: tracker.emoji) ?? 0, section: 0)
            selectedColorIndexPath = IndexPath(item: UIColor.colorSelection.firstIndex(of: tracker.color ?? .clear) ?? 0, section: 1)
            
            let completedDaysCount = trackerRecordStore.countCompletedDays(for: tracker)
            daysCountLabel.text = String.localizedStringWithFormat(NSLocalizedString("daysCount", comment: ""), completedDaysCount)
        }
        nameTextField.rightView = clearButton
        nameTextField.rightViewMode = .whileEditing
        updateCreateButtonState()
    }
    
    private func selectInitialCollectionViewItems() {
        if let emojiIndexPath = selectedEmojiIndexPath, emojis.indices.contains(emojiIndexPath.item) {
            emojiAndColorCollectionView.selectItem(at: emojiIndexPath, animated: false, scrollPosition: [])
            if let cell = emojiAndColorCollectionView.cellForItem(at: emojiIndexPath) as? EmojiCollectionViewCell {
                cell.contentView.backgroundColor = .ypLightGray
            }
        }

        let colorHex = selectedColor.toHexString()

        if let colorIndex = UIColor.colorSelection.firstIndex(where: {$0.toHexString() == colorHex}) {
            let colorIndexPath = IndexPath(item: colorIndex, section: 1)
            emojiAndColorCollectionView.selectItem(at: colorIndexPath, animated: false, scrollPosition: [])
            if let cell = emojiAndColorCollectionView.cellForItem(at: colorIndexPath) as? ColorCollectionViewCell {
                cell.layer.cornerRadius = 16
                cell.layer.borderWidth = 3
                cell.layer.borderColor = selectedColor.withAlphaComponent(0.3).cgColor
            }
        }
    }

    private func setupActions() {
        clearButton.addTarget(self, action: #selector(clearButtonTapped), for: .touchUpInside)
        nameTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        cancelButton.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        createButton.addTarget(self, action: #selector(createButtonTapped), for: .touchUpInside)
    }
    
    private func addSubviews() {
        view.addSubview(scrollView)
        
        scrollView.addSubview(contentView)
        
        contentView.addSubview(titleLabel)
        contentView.addSubview(nameTextField)
        contentView.addSubview(tableView)
        contentView.addSubview(emojiAndColorCollectionView)
        contentView.addSubview(cancelButton)
        contentView.addSubview(createButton)
    }
    
    private func setupConstraints() {
        contentViewHeightConstraint = contentView.heightAnchor.constraint(equalToConstant: 875)
        contentViewHeightConstraint?.isActive = true
        
        tableViewHeightConstraint = tableView.heightAnchor.constraint(equalToConstant: 150)
        tableViewHeightConstraint?.isActive = true
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            titleLabel.widthAnchor.constraint(equalToConstant: 375),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 30),
            
            nameTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            nameTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            nameTextField.heightAnchor.constraint(equalToConstant: 75),
            nameTextField.widthAnchor.constraint(equalToConstant: 343),
            
            tableView.topAnchor.constraint(equalTo: nameTextField.bottomAnchor, constant: 24),
            tableView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            emojiAndColorCollectionView.topAnchor.constraint(equalTo: tableView.bottomAnchor, constant: 16),
            emojiAndColorCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            emojiAndColorCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            emojiAndColorCollectionView.heightAnchor.constraint(equalToConstant: 476),
            
            cancelButton.topAnchor.constraint(equalTo: emojiAndColorCollectionView.bottomAnchor, constant: 16),
            cancelButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            cancelButton.heightAnchor.constraint(equalToConstant: 60),
            
            createButton.topAnchor.constraint(equalTo: emojiAndColorCollectionView.bottomAnchor, constant: 16),
            createButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            createButton.heightAnchor.constraint(equalToConstant: 60),
            
            cancelButton.widthAnchor.constraint(equalTo: createButton.widthAnchor),
            createButton.leadingAnchor.constraint(equalTo: cancelButton.trailingAnchor, constant: 8)
            
        ])
    }
    
    @objc private func textFieldDidChange() {
        guard let text = nameTextField.text else { return }
        
        clearButton.isHidden = text.isEmpty
        
        if text.count > maxCharacterCount {
            symbolsLimitLabel.isHidden = false
            updateConstraintsForSymbolsLimitLabel(true)
        } else {
            symbolsLimitLabel.isHidden = true
            updateConstraintsForSymbolsLimitLabel(false)
        }
        updateCreateButtonState()
    }
    
    private func updateConstraintsForSymbolsLimitLabel(_ isVisible: Bool) {
        if isVisible {
            contentView.addSubview(symbolsLimitLabel)
            
            NSLayoutConstraint.activate([
                symbolsLimitLabel.topAnchor.constraint(equalTo: nameTextField.bottomAnchor, constant: 8),
                symbolsLimitLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
                symbolsLimitLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
                symbolsLimitLabel.bottomAnchor.constraint(equalTo: tableView.topAnchor, constant: -32)
            ])
            
            tableView.topAnchor.constraint(equalTo: nameTextField.bottomAnchor, constant: 62).isActive = true
        } else {
            symbolsLimitLabel.removeFromSuperview()
            tableView.topAnchor.constraint(equalTo: nameTextField.bottomAnchor, constant: 24).isActive = true
        }
    }
    
    private func updateConstraintsForDaysCountLabel() {
        if trackerToEdit != nil {
            contentView.addSubview(daysCountLabel)
            
            NSLayoutConstraint.activate([
                daysCountLabel.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 24),
                daysCountLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
                daysCountLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
                daysCountLabel.heightAnchor.constraint(equalToConstant: 38)
            ])
            nameTextField.topAnchor.constraint(equalTo: daysCountLabel.bottomAnchor, constant: 40).isActive = true
        } else {
            daysCountLabel.removeFromSuperview()
            nameTextField.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 40).isActive = true
        }
    }
    
    func categorySelected(_ category: String) {
        self.selectedCategory = category
        tableView.reloadData()
        UserDefaults.standard.set(category, forKey: "selectedCategory")
        updateCreateButtonState()
    }
    
    func didSelectSchedule(_ selectedSchedule: [Schedule]) {
        self.schedule = selectedSchedule
        tableView.reloadData()
        updateCreateButtonState()
    }
    
    private func updateCreateButtonState() {
        let isNameTextFieldEmpty = nameTextField.text?.isEmpty ?? true
        let isScheduleSelected = !schedule.isEmpty || isEvent
        let isEmojiSelected = !selectedEmoji.isEmpty
        let isCategorySelected = !selectedCategory.isEmpty
        let isColorSelected = selectedColor != .clear
        
        let isButtonEnabled = !isNameTextFieldEmpty && isScheduleSelected && isEmojiSelected && isColorSelected && isCategorySelected
        createButton.isEnabled = isButtonEnabled
        if isButtonEnabled {
            createButton.backgroundColor = .ypBlack
            createButton.setTitleColor(.ypWhite, for: .normal)
        } else {
            createButton.backgroundColor = .ypGray 
        }
    }
    
    
    @objc private func clearButtonTapped() {
        nameTextField.text = ""
        clearButton.isHidden = true
        updateConstraintsForSymbolsLimitLabel(false)
    }
    
    @objc private func cancelButtonTapped() {
        dismiss(animated: true)
    }
    
    @objc private func createButtonTapped() {
        if let trackerToEdit = self.trackerToEdit {
            let updatedTracker = Tracker(
                id: trackerToEdit.id,
                name: nameTextField.text ?? "",
                color: selectedColor,
                emoji: selectedEmoji,
                schedule: schedule,
                isPinned: trackerToEdit.isPinned
            )
            delegate?.didUpdateTracker(updatedTracker, category: selectedCategory)
        } else {
            let newTracker = Tracker(
                id: UUID(),
                name: nameTextField.text ?? "",
                color: selectedColor,
                emoji: selectedEmoji,
                schedule: isEvent ? [.monday, .tuesday, .thursday, .wednesday, .friday, .saturday, .sunday] : schedule
            )
            let category = TrackerCategory(title: selectedCategory, trackers: [newTracker])
            delegate?.didCreateTracker(newTracker, category: category, isEvent: isEvent)
        }
        dismiss(animated: true)
    }
    
}

// MARK: - UITableViewDelegate, UITableViewDataSource

extension TrackerCreationViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return isEvent ? 1 : 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CustomCell", for: indexPath) as! CustomTableViewCell
        cell.selectionStyle = .none
        
        if indexPath.row == 0 && !isEvent {
            cell.configure(title: "Категория", description: selectedCategory)
            cell.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16 )
        } else if indexPath.row == 1 && !isEvent {
            cell.configure(title: "Расписание", description: scheduleDescription())
            cell.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 400)
        } else {
            cell.configure(title: "Категория", description: selectedCategory)
            cell.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 400)
        }
        return cell
    }
    
    private func scheduleDescription() -> String {
        let allDaysOfWeek = Schedule.allCases
        
        if Set(schedule) == Set(allDaysOfWeek) {
            return "Каждый День"
        } else if !schedule.isEmpty {
            return schedule.map { $0.shortRepresentation() }.joined(separator: ", ")
        }
        
        return ""
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.row == 0 {
            let categorySelectionViewModel = CategorySelectionViewModel(categoryStore: TrackerCategoryStore())
            let categorySelectionVC = CategorySelectionViewController(viewModel: categorySelectionViewModel)
            let category = trackerToEdit != nil ? selectedCategory : UserDefaults.standard.string(forKey: "selectedCategory") ?? ""
            categorySelectionVC.savedCategory = category
            categorySelectionVC.viewModel.delegate = self
            
            self.navigationController?.pushViewController(categorySelectionVC, animated: true)
        } else if indexPath.row == 1 && !isEvent {
            let scheduleSelectionVC = ScheduleSelectionViewController()
            scheduleSelectionVC.selectedSchedule = self.schedule
            scheduleSelectionVC.delegate = self
            self.navigationController?.pushViewController(scheduleSelectionVC, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
}

// MARK: - UICollectionViewDataSource

extension TrackerCreationViewController: UICollectionViewDataSource{
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch section {
        case 0:
            return emojis.count
        case 1:
            return UIColor.colorSelection.count
        default:
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch indexPath.section{
        case 0:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "EmojiCell", for: indexPath) as! EmojiCollectionViewCell
            cell.configure(with: emojis[indexPath.item])
            return cell
        case 1:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ColorCell", for: indexPath) as! ColorCollectionViewCell
            cell.configure(with: UIColor.colorSelection[indexPath.item])
            return cell
        default:
            fatalError("Unexpected section")
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "SectionHeader", for: indexPath) as? SectionHeaderCollectionReusableView else {
            fatalError("Could not dequeue SectionHeader")
        }
        
        switch indexPath.section {
        case 0:
            header.title = "Эмодзи"
        case 1:
            header.title = "Цвета"
        default:
            header.title = ""
        }
        
        return header
    }
}

// MARK: - UICollectionViewDelegate

extension TrackerCreationViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch indexPath.section {
        case 0:
            if let previousSelectedIndexPath = selectedEmojiIndexPath,
               let previousCell = collectionView.cellForItem(at: previousSelectedIndexPath) as? EmojiCollectionViewCell {
                previousCell.contentView.backgroundColor = .clear
            }
            
            selectedEmoji = emojis[indexPath.item]
            selectedEmojiIndexPath = indexPath
            
            if let cell = collectionView.cellForItem(at: indexPath) as? EmojiCollectionViewCell {
                cell.contentView.backgroundColor = .ypLightGray
            }
        case 1:
            if let previousSelectedIndexPath = selectedColorIndexPath,
               let previousCell = collectionView.cellForItem(at: previousSelectedIndexPath) as? ColorCollectionViewCell {
                previousCell.layer.borderWidth = 0
            }
            
            selectedColor = UIColor.colorSelection[indexPath.item]
            selectedColorIndexPath = indexPath
            
            if let cell = collectionView.cellForItem(at: indexPath) as? ColorCollectionViewCell {
                cell.layer.cornerRadius = 16
                cell.layer.borderWidth = 3
                cell.layer.borderColor = selectedColor.withAlphaComponent(0.3).cgColor
            }
        default:
            return
        }
        updateCreateButtonState()
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        switch indexPath.section {
        case 0:
            if let cell = collectionView.cellForItem(at: indexPath) as? EmojiCollectionViewCell {
                cell.contentView.backgroundColor = .clear
                selectedEmoji = ""
            }
        case 1:
            if let cell = collectionView.cellForItem(at: indexPath) as? ColorCollectionViewCell {
                cell.layer.borderWidth = 0
                selectedColor = .clear
            }
        default:
            return
        }
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension TrackerCreationViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 52, height: 52)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 24, left: 18, bottom: 24, right: 18)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 34)
    }
}
