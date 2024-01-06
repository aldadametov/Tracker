//
//  CategorySelectionViewModel.swift
//  Tracker
//
//  Created by Алишер Дадаметов on 23.12.2023.
//

import Foundation

protocol CategorySelectionViewModelProtocol {
    var delegate: CategorySelectionDelegate? { get set }
    var categoryTitles: [String] { get }
    var onCategoryTitlesUpdated: (() -> Void)? { get set }
    var onCategorySelected: ((String) -> Void)? { get set }

    func fetchCategoryTitles()
    func selectCategory(at index: Int)
    func deleteCategory(named categoryName: String)
}

protocol CategorySelectionDelegate: AnyObject {
    func categorySelected(_ category: String)
}

final class CategorySelectionViewModel: CategorySelectionViewModelProtocol {
    
    private let categoryStore: TrackerCategoryStore
    
    weak var delegate: CategorySelectionDelegate?
    
    var categoryTitles: [String] = [] {
        didSet {
            onCategoryTitlesUpdated?()
        }
    }
    var onCategoryTitlesUpdated: (() -> Void)?
    var onCategorySelected: ((String) -> Void)?
        
    init(categoryStore: TrackerCategoryStore) {
        self.categoryStore = categoryStore
    }
    
    func fetchCategoryTitles() {
        categoryTitles = categoryStore.fetchAllCategoriesTitles()
    }
    
    func selectCategory(at index: Int) {
        let selectedCategory = categoryTitles[index]
        delegate?.categorySelected(selectedCategory)
        onCategorySelected?(selectedCategory)
    }
   
    func deleteCategory(named categoryName: String) {
        categoryStore.deleteCategory(named: categoryName)
        fetchCategoryTitles()
    }
}
