//
//  SettingView.swift
//  Courser
//
//  Created by c on 2021/2/14.
//

import SwiftUI

struct SettingView: View {
    @State var model: Settings
    
    var body: some View {
        Form {
            accountSection
//            actionSection  // cacheCleaning 什么的
        }
    }
    
    var accountSection: some View {
        Section(header: Text("教务账户")) {
            TextField("学号", text: $model.account.sid)
            TextField("密码", text: $model.account.password)
            Button("登录测试") {
                print("login")
            }
            .frame(maxWidth: .infinity, alignment: .center)
        }
        
    }
}

struct SettingView_Previews: PreviewProvider {
    static var previews: some View {
        SettingView(model: Settings())
    }
}
