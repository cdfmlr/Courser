//
//  ContentView.swift
//  Courser
//
//  Created by c on 2021/1/31.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        Text("Hello, world!\(sampleCourses.first?.courseName ?? "ooops")")
            .foregroundColor(.primary)
            .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
