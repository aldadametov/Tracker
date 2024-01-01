//
//  AnalyticsService.swift
//  Tracker
//
//  Created by Алишер Дадаметов on 31.12.2023.
//

import Foundation
import YandexMobileMetrica

struct AnalyticsService {
    static func activate() {
        guard let configuration = YMMYandexMetricaConfiguration(apiKey: "8ec32e97-e8f6-42b7-b759-fd70ba5ad134") else { return }
        
        YMMYandexMetrica.activate(with: configuration)
    }
    
    func report(event: String, screen: String, item: String?) {
        var params: [String: Any] = ["event": event, "screen": screen]
        if let itemValue = item {
            params["item"] = itemValue
        }

        YMMYandexMetrica.reportEvent(event, parameters: params, onFailure: { error in
            print("REPORT ERROR: %@", error.localizedDescription)
        })

        // Для тестирования
        print("Reported event: \(event), screen: \(screen), item: \(item ?? "none")")
    }
}
