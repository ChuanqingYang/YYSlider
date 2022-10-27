//
//  ContentView.swift
//  YYSliderPro
//
//  Created by ChuanqingYang on 2022/6/27.
//

import SwiftUI

struct Model {
    var title:String
    var index:Int
}

class VM: ObservableObject {
    @Published var title:String = ""
    
    var index:Int = 0
    
    init() {
        
    }
    
    func grow() {
        index += 1
        
        title = "123"
    }
    
    
}

struct ContentView: View {
    
    @ObservedObject var vm = VM()
    
    @State var currentValue:CGFloat = 0
    var body: some View {
        Text("title:\(vm.title)")
            .padding(20)
            .background(.blue)
            .foregroundColor(.black)
            .onTapGesture {
                vm.grow()
            }.onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    vm.grow()
                }
            }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

