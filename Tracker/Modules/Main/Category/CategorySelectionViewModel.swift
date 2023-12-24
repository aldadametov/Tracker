//
//  CategorySelectionViewModel.swift
//  Tracker
//
//  Created by Алишер Дадаметов on 23.12.2023.
//

import UIKit

final class CategorySelectionViewModel {
    
    private let categoryStore: TrackerCategoryStore
    var categoryTitles: [String] = [] {
        didSet {
            onCategoryTitlesUpdated?()
        }
    }
    var onCategoryTitlesUpdated: (() -> Void)?
        
    init(categoryStore: TrackerCategoryStore) {
        self.categoryStore = categoryStore
    }

    func fetchCategoryTitles() {
        categoryTitles = categoryStore.fetchAllCategoriesTitles()
    }
}
