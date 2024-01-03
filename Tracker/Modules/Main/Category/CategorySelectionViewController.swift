//
//  CategorySelectionViewController.swift
//  Tracker
//
//  Created by Алишер Дадаметов on 23.12.2023.
//

import UIKit

final class CategorySelectionViewController: UIViewController {
    
    var viewModel: CategorySelectionViewModelProtocol

    init(viewModel: CategorySelectionViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var savedCategory: String?
    
    private var lastSelectedIndexPath: IndexPath?
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Категория"
        label.frame = CGRect(x: 0, y: 0, width: 149, height: 22)
        label.textColor = .ypBlack
        label.font = UIFont(name: "SFPro-Medium", size: 16)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var noCategoriesCreatedImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "noTrackersSet")
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var noCategoriesCreatedLabel: UILabel  = {
        let label = UILabel()
        label.text = "Привычки и события можно обьеденить по смыслу"
        label.textColor = .ypBlack
        label.font = UIFont(name: "SFPro-Medium", size: 12)
        label.textAlignment = .center
        label.numberOfLines = 2
        label.lineBreakMode = .byWordWrapping
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    } ()
    
    private lazy var cateoryTableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        let cornerRadius: CGFloat = 16.0
        tableView.layer.cornerRadius = cornerRadius
        tableView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        tableView.layer.masksToBounds = true
        tableView.isScrollEnabled = false
        return tableView
    }()
    
    private lazy var addCategoryButton: UIButton = {
        let button = UIButton()
        button.setTitle("Добавить категорию", for: .normal)
        button.setTitleColor(.ypWhite, for: .normal)
        button.backgroundColor = .ypBlack
        button.titleLabel?.font = UIFont(name: "SFPro-Medium", size: 16)
        button.layer.cornerRadius = 16
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.fetchCategoryTitles()
        updatePlaceholderVisibility()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ypWhite
        navigationItem.rightBarButtonItem = nil
        navigationItem.hidesBackButton = true
        
        viewModel.onCategoryTitlesUpdated = { [weak self] in
            DispatchQueue.main.async {
                self?.cateoryTableView.reloadData()
                self?.updatePlaceholderVisibility()
            }
        }
        viewModel.onCategorySelected = { [weak self] selectedCategory in
            self?.navigationController?.popViewController(animated: true)
        }
        viewModel.fetchCategoryTitles()
        
        addSubviews()
        setupConstraints()
        setupTableView()
        
        
        addCategoryButton.addTarget(self, action: #selector(addCategoryButtonTapped), for: .touchUpInside )
    }
    
    private func updatePlaceholderVisibility() {
        let hasCategories = !viewModel.categoryTitles.isEmpty
        noCategoriesCreatedImageView.isHidden = hasCategories
        noCategoriesCreatedLabel.isHidden = hasCategories
        cateoryTableView.isHidden = !hasCategories
    }
    
    private func setupTableView() {
        cateoryTableView.delegate = self
        cateoryTableView.dataSource = self
        cateoryTableView.register(CategoryTableViewCell.self, forCellReuseIdentifier: "categoryCell")
        cateoryTableView.separatorColor = .ypGray
    }
    
    private func addSubviews() {
        view.addSubview(titleLabel)
        view.addSubview(noCategoriesCreatedLabel)
        view.addSubview(noCategoriesCreatedImageView)
        view.addSubview(cateoryTableView)
        view.addSubview(addCategoryButton)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 30),
            
            cateoryTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            cateoryTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            cateoryTableView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 45),
            cateoryTableView.bottomAnchor.constraint(equalTo: addCategoryButton.topAnchor, constant: -20),
            
            
            noCategoriesCreatedImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            noCategoriesCreatedImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -40),
            
            noCategoriesCreatedLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            noCategoriesCreatedLabel.topAnchor.constraint(equalTo: noCategoriesCreatedImageView.bottomAnchor, constant: 8),
            noCategoriesCreatedLabel.widthAnchor.constraint(equalToConstant: 190),
            
            addCategoryButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            addCategoryButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            addCategoryButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -50),
            addCategoryButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    @objc private func addCategoryButtonTapped() {
        let categoryCreationVC = CategoryCreationViewController()
        self.navigationController?.pushViewController(categoryCreationVC, animated: true)
    }
    
}

//MARK: - UITableViewDataSource

extension CategorySelectionViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.categoryTitles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "categoryCell", for: indexPath) as! CategoryTableViewCell
        let categoryTitle = viewModel.categoryTitles[indexPath.row]
        cell.configure(with: categoryTitle)
        cell.selectionStyle = .none
        
        if categoryTitle == savedCategory {
            cell.accessoryType = .checkmark
            cell.tintColor = .ypBlue
        } else {
            cell.accessoryType = .none
        }
        
        if indexPath.row == viewModel.categoryTitles.count - 1 {
            cell.roundCorners(corners: [.bottomLeft, .bottomRight], radius: 16)
        } else {
            cell.roundCorners(corners: [], radius: 0)
        }
        return cell
    }
}

//MARK: - UITableViewDelegate
extension CategorySelectionViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let lastIndexPath = lastSelectedIndexPath,
           let lastCell = tableView.cellForRow(at: lastIndexPath) as? CategoryTableViewCell {
            lastCell.accessoryType = .none
        }
        
        if let cell = tableView.cellForRow(at: indexPath) as? CategoryTableViewCell {
            cell.accessoryType = .checkmark
            cell.tintColor = .systemBlue
        }
        
        lastSelectedIndexPath = indexPath
        viewModel.selectCategory(at: indexPath.row)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let separatorInset: CGFloat = 16
        if indexPath.row == viewModel.categoryTitles.count - 1 {
            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: tableView.bounds.width)
        } else {
            cell.separatorInset = UIEdgeInsets(top: 0, left: separatorInset, bottom: 0, right: separatorInset)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
           let configuration = UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { _ -> UIMenu? in
               let editAction = UIAction(title: "Редактировать") { [weak self] _ in
                   let categoryToEdit = self?.viewModel.categoryTitles[indexPath.row]
                   let editVC = CategoryCreationViewController()
                   editVC.isEditingCategory = true
                   editVC.originalCategoryName = categoryToEdit
                   self?.navigationController?.pushViewController(editVC, animated: true)
               }

               let deleteAction = UIAction(title: "Удалить", attributes: .destructive) { [weak self] _ in
                   let categoryName = self?.viewModel.categoryTitles[indexPath.row]
                   
                   let alert = UIAlertController(title: "", message: "Эта категория точно не нужна?", preferredStyle: .actionSheet)
                   
                   let delete = UIAlertAction(title: "Удалить", style: .destructive) { _ in
                       self?.viewModel.deleteCategory(named: categoryName ?? "")
                   }
                   
                   let cancel = UIAlertAction(title: "Отмена", style: .cancel)
                   
                   alert.addAction(delete)
                   alert.addAction(cancel)
                   
                   self?.present(alert, animated: true)
               }

               return UIMenu(title: "", children: [editAction, deleteAction])
           }
           return configuration
       }
}
