//
//  StatisticsViewController.swift
//  Tracker
//
//  Created by Алишер Дадаметов on 08.09.2023.
//

import UIKit

final class StatisticsViewContoller: UIViewController {
    
    private let trackerRecordStore = TrackerRecordStore()
    var onStatisticsUpdate: (() -> Void)?

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Статистика"
        label.frame = CGRect(x: 0, y: 0, width: 149, height: 22)
        label.textColor = .ypBlack
        label.font = UIFont(name: "SFPro-Bold", size: 34)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var bestPeriodLabel: UILabel = createLabel(text: "Лучший период", font: UIFont(name: "SFPro-Medium", size: 12)!, textColor: .ypBlack)
    private lazy var perfectDaysLabel: UILabel = createLabel(text: "Идеальные дни", font: UIFont(name: "SFPro-Medium", size: 12)!, textColor: .ypBlack)
    private lazy var completedTrackersLabel: UILabel = createLabel(text: "Трекеров завершено", font: UIFont(name: "SFPro-Medium", size: 12)!, textColor: .ypBlack)
    private lazy var averageValueLabel: UILabel = createLabel(text: "Среднее значение", font: UIFont(name: "SFPro-Medium", size: 12)!, textColor: .ypBlack)

    
    private lazy var bestPeriodCountLabel: UILabel = createLabel(text: "0", font: UIFont(name: "SFPro-Bold", size: 34)!, textColor: .ypBlack)
    private lazy var perfectDaysCountLabel: UILabel = createLabel(text: "0", font: UIFont(name: "SFPro-Bold", size: 34)!, textColor: .ypBlack)
    private lazy var completedTrackersCountLabel: UILabel = createLabel(text: "0", font: UIFont(name: "SFPro-Bold", size: 34)!, textColor: .ypBlack)
    private lazy var averageValueCountLabel: UILabel = createLabel(text: "0", font: UIFont(name: "SFPro-Bold", size: 34)!, textColor: .ypBlack)
    

    private lazy var bestPeriodView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "StatsBorder")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    private lazy var perfectDaysView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "StatsBorder")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    private lazy var completedTrackersView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "StatsBorder")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    private lazy var averageValueView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "StatsBorder")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var noStatisticsImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "noStatisticsFound")
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.isHidden = true
        return imageView
    }()
    
    private lazy var noStatisticsLabel: UILabel = {
        let label = UILabel()
        label.text = "Анализировать пока нечего"
        label.textColor = .ypBlack
        label.font = UIFont(name: "SFPro-Medium", size: 12)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.isHidden = true
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ypWhite
        updateStatistics()
        addSubviews()
        setupConstraints()
        NotificationCenter.default.addObserver(self, selector: #selector(updateStatistics), name: .didUpdateTrackerData, object: nil)
    }
    
    private func addSubviews() {
        view.addSubview(titleLabel)
        view.addSubview(bestPeriodView)
        view.addSubview(perfectDaysView)
        view.addSubview(completedTrackersView)
        view.addSubview(averageValueView)
        view.addSubview(noStatisticsImageView)
        view.addSubview(noStatisticsLabel)
        
        bestPeriodView.addSubview(bestPeriodCountLabel)
        perfectDaysView.addSubview(perfectDaysCountLabel)
        completedTrackersView.addSubview(completedTrackersCountLabel)
        averageValueView.addSubview(averageValueCountLabel)
        
        bestPeriodView.addSubview(bestPeriodLabel)
        perfectDaysView.addSubview(perfectDaysLabel)
        completedTrackersView.addSubview(completedTrackersLabel)
        averageValueView.addSubview(averageValueLabel)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 88),
            titleLabel.heightAnchor.constraint(equalToConstant: 41),
            titleLabel.widthAnchor.constraint(equalToConstant: 254),
            
            bestPeriodView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            bestPeriodView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            bestPeriodView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 77),
            
            perfectDaysView.topAnchor.constraint(equalTo: bestPeriodView.bottomAnchor, constant: 12),
            perfectDaysView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            perfectDaysView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),

            completedTrackersView.topAnchor.constraint(equalTo: perfectDaysView.bottomAnchor, constant: 12),
            completedTrackersView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            completedTrackersView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            
            averageValueView.topAnchor.constraint(equalTo: completedTrackersView.bottomAnchor, constant: 12),
            averageValueView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            averageValueView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            
            bestPeriodCountLabel.leadingAnchor.constraint(equalTo: bestPeriodView.leadingAnchor, constant: 12),
            bestPeriodCountLabel.topAnchor.constraint(equalTo: bestPeriodView.topAnchor, constant: 12),
            
            perfectDaysCountLabel.leadingAnchor.constraint(equalTo: perfectDaysView.leadingAnchor, constant: 12),
            perfectDaysCountLabel.topAnchor.constraint(equalTo: perfectDaysView.topAnchor, constant: 12),
            
            completedTrackersCountLabel.leadingAnchor.constraint(equalTo: completedTrackersView.leadingAnchor, constant: 12),
            completedTrackersCountLabel.topAnchor.constraint(equalTo: completedTrackersView.topAnchor, constant: 12),
            
            averageValueCountLabel.leadingAnchor.constraint(equalTo: averageValueView.leadingAnchor, constant: 12),
            averageValueCountLabel.topAnchor.constraint(equalTo: averageValueView.topAnchor, constant: 12),
            
            bestPeriodLabel.leadingAnchor.constraint(equalTo: bestPeriodView.leadingAnchor, constant: 12),
            bestPeriodLabel.bottomAnchor.constraint(equalTo: bestPeriodView.bottomAnchor, constant: -12),
            
            perfectDaysLabel.leadingAnchor.constraint(equalTo: perfectDaysView.leadingAnchor, constant: 12),
            perfectDaysLabel.bottomAnchor.constraint(equalTo: perfectDaysView.bottomAnchor, constant: -12),
            
            completedTrackersLabel.leadingAnchor.constraint(equalTo: completedTrackersView.leadingAnchor, constant: 12),
            completedTrackersLabel.bottomAnchor.constraint(equalTo: completedTrackersView.bottomAnchor, constant: -12),
            
            averageValueLabel.leadingAnchor.constraint(equalTo: averageValueView.leadingAnchor, constant: 12),
            averageValueLabel.bottomAnchor.constraint(equalTo: averageValueView.bottomAnchor, constant: -12),
                
            noStatisticsImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            noStatisticsImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            noStatisticsImageView.widthAnchor.constraint(equalToConstant: 80),
            noStatisticsImageView.heightAnchor.constraint(equalToConstant: 80),
            
            noStatisticsLabel.topAnchor.constraint(equalTo: noStatisticsImageView.bottomAnchor, constant: 8),
            noStatisticsLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            noStatisticsLabel.widthAnchor.constraint(equalToConstant: 343),
            noStatisticsLabel.heightAnchor.constraint(equalToConstant: 18),
        ])
    }
    
    @objc private func updateStatistics() {
        let hasData = trackerRecordStore.findLongestStreak() != 1 ||
                      trackerRecordStore.totalCompletedTrackers() != 0 ||
                      trackerRecordStore.countPerfectDays() != 0 ||
                      trackerRecordStore.averageCompletedTrackers() != 0

        bestPeriodView.isHidden = !hasData
        perfectDaysView.isHidden = !hasData
        completedTrackersView.isHidden = !hasData
        averageValueView.isHidden = !hasData

        noStatisticsImageView.isHidden = hasData
        noStatisticsLabel.isHidden = hasData

        if hasData {
            bestPeriodCountLabel.text = "\(trackerRecordStore.findLongestStreak())"
            completedTrackersCountLabel.text = "\(trackerRecordStore.totalCompletedTrackers())"
            perfectDaysCountLabel.text = "\(trackerRecordStore.countPerfectDays())"
            averageValueCountLabel.text = "\(trackerRecordStore.averageCompletedTrackers())"
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

