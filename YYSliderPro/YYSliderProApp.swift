//
//  YYSliderProApp.swift
//  YYSliderPro
//
//  Created by ChuanqingYang on 2022/6/27.
//

import SwiftUI

@main
struct YYSliderProApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
