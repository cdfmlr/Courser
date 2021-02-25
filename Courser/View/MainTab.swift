//
//  MainTab.swift
//  Courser
//
//  Created by c on 2021/2/25.
//

import SwiftUI

struct MainTab: View {
    @EnvironmentObject var store: Store
    
    var body: some View {
        TabView(selection: $store.appState.mainTab.selection) {
            
            CourseTableView().tabItem {
                Image(systemName: "calendar")
                Text("课表")
            }
            .tag(AppState.MainTabState.Index.table)
            
            CourseDailyView().tabItem {
                Image(systemName: "mappin.circle")
                Text("今天")
            }
            .tag(AppState.MainTabState.Index.daily)
            
            SettingView().tabItem {
                Image(systemName: "gear")
                Text("设置")
            }
            .tag(AppState.MainTabState.Index.settings)
        }
    }
}

struct MainTab_Previews: PreviewProvider {
    static var previews: some View {
        MainTab().environmentObject(Store())
    }
}
