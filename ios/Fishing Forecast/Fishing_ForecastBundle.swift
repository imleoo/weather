//
//  Fishing_ForecastBundle.swift
//  Fishing Forecast
//
//  Created by Leoo Bai on 9/1/25.
//

import WidgetKit
import SwiftUI

@main
struct Fishing_ForecastBundle: WidgetBundle {
    var body: some Widget {
        Fishing_Forecast()
        Fishing_ForecastControl()
        Fishing_ForecastLiveActivity()
    }
}
