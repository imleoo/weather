//
//  Fishing_ForecastLiveActivity.swift
//  Fishing Forecast
//
//  Created by Leoo Bai on 9/1/25.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct Fishing_ForecastAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var emoji: String
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}

struct Fishing_ForecastLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: Fishing_ForecastAttributes.self) { context in
            // Lock screen/banner UI goes here
            VStack {
                Text("Hello \(context.state.emoji)")
            }
            .activityBackgroundTint(Color.cyan)
            .activitySystemActionForegroundColor(Color.black)

        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI goes here.  Compose the expanded UI through
                // various regions, like leading/trailing/center/bottom
                DynamicIslandExpandedRegion(.leading) {
                    Text("Leading")
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text("Trailing")
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text("Bottom \(context.state.emoji)")
                    // more content
                }
            } compactLeading: {
                Text("L")
            } compactTrailing: {
                Text("T \(context.state.emoji)")
            } minimal: {
                Text(context.state.emoji)
            }
            .widgetURL(URL(string: "http://www.apple.com"))
            .keylineTint(Color.red)
        }
    }
}

extension Fishing_ForecastAttributes {
    fileprivate static var preview: Fishing_ForecastAttributes {
        Fishing_ForecastAttributes(name: "World")
    }
}

extension Fishing_ForecastAttributes.ContentState {
    fileprivate static var smiley: Fishing_ForecastAttributes.ContentState {
        Fishing_ForecastAttributes.ContentState(emoji: "😀")
     }
     
     fileprivate static var starEyes: Fishing_ForecastAttributes.ContentState {
         Fishing_ForecastAttributes.ContentState(emoji: "🤩")
     }
}

#Preview("Notification", as: .content, using: Fishing_ForecastAttributes.preview) {
   Fishing_ForecastLiveActivity()
} contentStates: {
    Fishing_ForecastAttributes.ContentState.smiley
    Fishing_ForecastAttributes.ContentState.starEyes
}
