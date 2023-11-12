import UIKit

protocol TrackerCreationDelegate: AnyObject {
    func didCreateTracker(_ tracker: Tracker, isEvent: Bool)
}

class TrackerCreationViewController: UIViewController, ScheduleSelectionDelegate {
    
    
    weak var delegate: TrackerCreationDelegate?

    var schedule: [Schedule] = []
    var isEvent: Bool = false
    init(isEvent: Bool = false) {
        self.isEvent = isEvent
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    private lazy var contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Новая Привычка"
        label.frame = CGRect(x: 0, y: 0, width: 149, height: 22)
        label.textColor = UIColor(red: 0.102, green: 0.106, blue: 0.133, alpha: 1)
        label.font = UIFont(name: "SFPro-Medium", size: 16)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let nameTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Введите название трекера"
        textField.backgroundColor = UIColor(red: 0.902, green: 0.91, blue: 0.922, alpha: 0.3)
        textField.font = UIFont(name: "SFPro-Regular", size: 17)
        textField.layer.cornerRadius = 16
        textField.layer.borderWidth = 0
        textField.layer.masksToBounds = true
        textField.translatesAutoresizingMaskIntoConstraints = false
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: textField.frame.height))
        textField.leftView = paddingView
        textField.leftViewMode = .always
        return textField
    }()
    
    let clearButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(systemName: "xmark.circle.fill")?.withRenderingMode(.alwaysTemplate), for: .normal)
        button.tintColor = .lightGray
        button.frame = CGRect(x: 0, y: 0, width: 20, height: 20)
        button.contentEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 12) // добавленный отступ влево
        button.contentMode = .scaleAspectFit
        button.isHidden = true
        return button
    }()
    
    let maxCharacterCount = 38
    
    private lazy var symbolsLimitLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Ограничение 38 символов"
        label.font = UIFont(name: "SFPro-Regular", size: 17)
        label.textColor = UIColor(red: 0.961, green: 0.42, blue: 0.424, alpha: 1)
        label.textAlignment = .center
        label.isHidden = true
        return label
    }()
    
    let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        let cornerRadius: CGFloat = 16.0
        tableView.layer.cornerRadius = cornerRadius
        tableView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        tableView.layer.masksToBounds = true
        tableView.isScrollEnabled = false
        return tableView
    }()
    
    var tableViewHeightConstraint: NSLayoutConstraint!
    
    let cancelButton: UIButton = {
        let button = UIButton()
        button.setTitle("Отменить", for: .normal)
        button.setTitleColor(UIColor(red: 0.961, green: 0.42, blue: 0.424, alpha: 1), for: .normal)
        button.titleLabel?.font = UIFont(name: "SFPro-Medium", size: 16)
        button.layer.cornerRadius = 16
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor(red: 0.961, green: 0.42, blue: 0.424, alpha: 1).cgColor
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    let createButton: UIButton = {
        let button = UIButton()
        button.setTitle("Создать", for: .normal)
        button.layer.backgroundColor = UIColor(red: 0.102, green: 0.106, blue: 0.133, alpha: 1).cgColor
        button.titleLabel?.font = UIFont(name: "SFPro-Medium", size: 16)
        button.layer.cornerRadius = 16
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        addSubviews()
        
        tableView.register(CustomTableViewCell.self, forCellReuseIdentifier: "CustomCell")
        tableView.delegate = self
        tableView.dataSource = self
        hideKeyboardWhenTappedAround()
        setUpConstraints()
        
        
        if isEvent {
            tableViewHeightConstraint = tableView.heightAnchor.constraint(equalToConstant: 75)
            titleLabel.text = "Новое нерегулярное событие"
        } else {
            tableViewHeightConstraint = tableView.heightAnchor.constraint(equalToConstant: 150)
        }
        nameTextField.rightView = clearButton
        nameTextField.rightViewMode = .whileEditing
        tableViewHeightConstraint.isActive = true
        updateCreateButtonState()
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
        contentView.addSubview(cancelButton)
        contentView.addSubview(createButton)
    }
    
    private func setUpConstraints() {
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
            contentView.heightAnchor.constraint(equalToConstant: 900),
            
            titleLabel.widthAnchor.constraint(equalToConstant: 375),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 30),
            
            
            nameTextField.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 40),
            nameTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            nameTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            nameTextField.heightAnchor.constraint(equalToConstant: 75),
            nameTextField.widthAnchor.constraint(equalToConstant: 343),
            
            tableView.topAnchor.constraint(equalTo: nameTextField.bottomAnchor, constant: 24),
            tableView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            tableView.heightAnchor.constraint(equalToConstant: 150),
            
            cancelButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -34),
            cancelButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            cancelButton.widthAnchor.constraint(equalToConstant: 166),
            cancelButton.heightAnchor.constraint(equalToConstant: 60),
            
            createButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -34),
            createButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            createButton.widthAnchor.constraint(equalToConstant: 166),
            createButton.heightAnchor.constraint(equalToConstant: 60),
            
        ])
    }
    
    @objc private func textFieldDidChange() {
        guard let text = nameTextField.text else { return }

        clearButton.isHidden = text.isEmpty

        if text.count > maxCharacterCount {
            // Пользователь превысил допустимое количество символов, отобразите лейбл и обновите иерархию элементов
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
            // Показать лейбл и обновить констрейнты
            contentView.addSubview(symbolsLimitLabel)

            NSLayoutConstraint.activate([
                symbolsLimitLabel.topAnchor.constraint(equalTo: nameTextField.bottomAnchor, constant: 8),
                symbolsLimitLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
                symbolsLimitLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
                symbolsLimitLabel.bottomAnchor.constraint(equalTo: tableView.topAnchor, constant: -32)
            ])

            tableView.topAnchor.constraint(equalTo: nameTextField.bottomAnchor, constant: 62).isActive = true
        } else {
            // Скрыть лейбл и обновить констрейнты
            symbolsLimitLabel.removeFromSuperview()
            tableView.topAnchor.constraint(equalTo: nameTextField.bottomAnchor, constant: 24).isActive = true
        }
    }
    
    func didSelectSchedule(_ selectedSchedule: [Schedule]) {
        self.schedule = selectedSchedule
        print("Выбранные дни обновлены: \(selectedSchedule)")
        tableView.reloadData()
        updateCreateButtonState()
    }
    
    private func updateCreateButtonState() {
        let isNameTextFieldEmpty = nameTextField.text?.isEmpty ?? true
        let isScheduleSelected = !schedule.isEmpty || isEvent

        createButton.isEnabled = !isNameTextFieldEmpty && isScheduleSelected
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
        let newTracker = Tracker(name: nameTextField.text ?? "", 
                                 color: .colorSelection[5],
                                 emoji: "👽",
                                 schedule: isEvent ? [.monday, .tuesday, .thursday, .wednesday, .friday, .saturday, .sunday] : schedule)
        
        delegate?.didCreateTracker(newTracker, isEvent: isEvent)
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
        
        if indexPath.row == 0 && !isEvent {
            cell.configure(title: "Категория", description: "Важное")
            cell.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16 )
        } else if indexPath.row == 1 && !isEvent {
            cell.configure(title: "Расписание", description: scheduleDescription())
            cell.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 375)
        } else {
            cell.configure(title: "Категория", description: "Важное")
            cell.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 375)
        }
        return cell
    }
    
    func scheduleDescription() -> String {
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
        
        if indexPath.row == 1 && !isEvent {
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
