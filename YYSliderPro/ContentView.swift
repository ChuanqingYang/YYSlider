//
//  ContentView.swift
//  YYSliderPro
//
//  Created by ChuanqingYang on 2022/6/27.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @State var currentValue:CGFloat = 0
    var body: some View {
        YYSliderView(currentValue: $currentValue,showPopover: true,popoverDirection: .top)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

