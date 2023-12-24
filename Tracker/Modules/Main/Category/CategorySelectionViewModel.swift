//
//  CategorySelectionViewModel.swift
//  Tracker
//
//  Created by Алишер Дадаметов on 23.12.2023.
//

import UIKit

protocol CategorySelectionDelegate: AnyObject {
    func categorySelected(_ category: String)
}

final class CategorySelectionViewModel {
    
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
}
