import UIKit

class NewHabitViewController: UIViewController {

    let emojiNames = ["Emoji-1", "Emoji-2", "Emoji-3", "Emoji-4", "Emoji-5", "Emoji-6", "Emoji-7", "Emoji-8", "Emoji-9", "Emoji-10", "Emoji-11", "Emoji-12", "Emoji-13", "Emoji-14", "Emoji-15", "Emoji-16", "Emoji-17", "Emoji-18"]

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
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    let nameTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Введите название трекера"
        textField.backgroundColor = UIColor(red: 0.902, green: 0.91, blue: 0.922, alpha: 0.3)
        textField.layer.cornerRadius = 16 // Устанавливаем радиус углов
        textField.layer.borderWidth = 0 // Устанавливаем толщину рамки в 0, чтобы убрать обрамление
        textField.layer.masksToBounds = true // Обрезаем контент, чтобы он не выходил за пределы радиуса углов
        textField.translatesAutoresizingMaskIntoConstraints = false

        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: textField.frame.height))
        textField.leftView = paddingView
        textField.leftViewMode = .always
        return textField
    }()

    var habitCategory: String?
    var habitSchedule: String?

    let tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        let cornerRadius: CGFloat = 16.0
        tableView.layer.cornerRadius = cornerRadius
        tableView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        tableView.layer.masksToBounds = true
        tableView.isScrollEnabled = false
        return tableView
    }()

    let emojiLabel: UILabel = {
        let label = UILabel()
        label.text = "Emoji"
        label.font = .boldSystemFont(ofSize: 18)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    var selectedEmoji: String?

    let colorLabel: UILabel = {
        let label = UILabel()
        label.text = "Цвет"
        label.font = .boldSystemFont(ofSize: 18)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    let colorView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.layer.borderWidth = 1
        view.layer.cornerRadius = 8
        view.layer.borderColor = UIColor.black.cgColor
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    let cancelButton: UIButton = {
        let button = UIButton()
        button.setTitle("Отменить", for: .normal)
        button.setTitleColor(UIColor(red: 0.961, green: 0.42, blue: 0.424, alpha: 1), for: .normal)
        button.layer.cornerRadius = 16
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor(red: 0.961, green: 0.42, blue: 0.424, alpha: 1).cgColor
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    let createButton: UIButton = {
        let button = UIButton()
        button.setTitle("Создать", for: .normal)
        button.layer.backgroundColor = UIColor(red: 0.682, green: 0.686, blue: 0.706, alpha: 1).cgColor
        button.layer.cornerRadius = 16
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    let emojiCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()

    let colorCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        addSubviews()
        
        tableView.register(CustomTableViewCell.self, forCellReuseIdentifier: "CustomCell")
        emojiCollectionView.register(EmojiCollectionViewCell.self, forCellWithReuseIdentifier: "EmojiCell")
        colorCollectionView.register(ColorCollectionViewCell.self, forCellWithReuseIdentifier: "ColorCell")

        setUpConstraints()
        
        tableView.delegate = self
        tableView.dataSource = self

        setupEmojiCollectionView()
        setupColorCollectionView()
    }
    
    private func addSubviews() {
        view.addSubview(scrollView)
        
        scrollView.addSubview(contentView)

        contentView.addSubview(titleLabel)
        contentView.addSubview(nameTextField)
        contentView.addSubview(tableView)
        contentView.addSubview(emojiLabel)
        contentView.addSubview(colorLabel)
        contentView.addSubview(colorView)
        contentView.addSubview(cancelButton)
        contentView.addSubview(createButton)
        contentView.addSubview(emojiCollectionView) // Добавьте collectionView
        contentView.addSubview(colorCollectionView) // Добавьте colorCollectionView
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
            titleLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),


            nameTextField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 24),
            nameTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            nameTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            nameTextField.heightAnchor.constraint(equalToConstant: 75),
            nameTextField.widthAnchor.constraint(equalToConstant: 343),

            tableView.topAnchor.constraint(equalTo: nameTextField.bottomAnchor, constant: 24),
            tableView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            tableView.heightAnchor.constraint(equalToConstant: 150), // Высоту можно настроить по вашему выбору

            emojiLabel.topAnchor.constraint(equalTo: tableView.bottomAnchor, constant: 32),
            emojiLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 28),

            emojiCollectionView.topAnchor.constraint(equalTo: emojiLabel.bottomAnchor),
            emojiCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            emojiCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            emojiCollectionView.heightAnchor.constraint(equalToConstant: 204),
            emojiCollectionView.widthAnchor.constraint(equalTo: contentView.widthAnchor),

            colorLabel.topAnchor.constraint(equalTo: emojiCollectionView.bottomAnchor, constant: 16),
            colorLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 28),

            colorCollectionView.topAnchor.constraint(equalTo: colorLabel.bottomAnchor),
            colorCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            colorCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            colorCollectionView.heightAnchor.constraint(equalToConstant: 204),

            cancelButton.topAnchor.constraint(equalTo: colorCollectionView.bottomAnchor, constant: 16),
            cancelButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            cancelButton.widthAnchor.constraint(equalToConstant: 166),
            cancelButton.heightAnchor.constraint(equalToConstant: 60),

            createButton.topAnchor.constraint(equalTo: colorCollectionView.bottomAnchor, constant: 16),
            createButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            createButton.widthAnchor.constraint(equalToConstant: 166),
            createButton.heightAnchor.constraint(equalToConstant: 60),

        ])
    }
    
    private func setupEmojiCollectionView() {
        emojiCollectionView.delegate = self
        emojiCollectionView.dataSource = self
    }

    private func setupColorCollectionView() {
        colorCollectionView.delegate = self
        colorCollectionView.dataSource = self
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource

extension NewHabitViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CustomCell", for: indexPath) as! CustomTableViewCell

        if indexPath.row == 0 {
            cell.textLabel?.text = "Категория"
            cell.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        } else if indexPath.row == 1 {
            cell.textLabel?.text = "Расписание"
            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0 , right: 375)
        }
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        if indexPath.section == 0 {
        } else if indexPath.section == 1 {
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
}

// MARK: - UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout

extension NewHabitViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == emojiCollectionView {
            return emojiNames.count
        } else if collectionView == colorCollectionView {
            return UIColor.colorSelection.count
        }
        return 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == emojiCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "EmojiCell", for: indexPath) as! EmojiCollectionViewCell

            let emojiName = emojiNames[indexPath.item]
            if let emojiImage = UIImage(named: emojiName) {
                cell.emojiImageView.image = emojiImage
            }

            return cell
        } else if collectionView == colorCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ColorCell", for: indexPath) as! ColorCollectionViewCell

            let color = UIColor.colorSelection[indexPath.item]
            cell.colorView.backgroundColor = color

            return cell
        }
        return UICollectionViewCell()
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == emojiCollectionView {
            selectedEmoji = emojiNames[indexPath.item]
        } else if collectionView == colorCollectionView {
            let selectedColor = UIColor.colorSelection[indexPath.item]
        }
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 52, height: 52)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 8
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 24, left: 18, bottom: 24, right: 19) // Отступы сбоку
    }
}

