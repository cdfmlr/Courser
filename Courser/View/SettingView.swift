//
//  SettingView.swift
//  Courser
//
//  Created by c on 2021/2/14.
//

import SwiftUI

struct SettingView: View {
    @EnvironmentObject var store: Store

    var settingsBinding: Binding<AppState.SettingsState> {
        $store.appState.settings
    }

    var settings: AppState.SettingsState {
        store.appState.settings
    }

    var body: some View {
        Form {
            accountSection
//            actionSection  // cacheCleaning 什么的
        }
        .alert(item: settingsBinding.loginError) { error in
//             Alert(title: Text(error.localizedDescription))
            Alert(title: Text("登陆失败"), message: Text(error.localizedDescription), dismissButton: .cancel())
        }
    }

    var accountSection: some View {
        Section(header: VStack(alignment: .leading) {
            Text("教务账户")
                .bold()
            if settings.loginUser != nil {
                Text("已登陆: \(settings.loginUser?.userdwmc ?? "") \(settings.loginUser?.userrealname ?? "")")
                    .font(.footnote)
            }
        }) {
            TextField("学校", text: settingsBinding.model.account.school)
            TextField("学号", text: settingsBinding.model.account.sid)
            SecureField("密码", text: settingsBinding.model.account.password)
            if settings.logining {
                ActivityIndicator(
                    isAnimating: .constant(true),
                    style: .medium)
                    .frame(maxWidth: .infinity, alignment: .center)
            } else {
                Button("登录") {
                    store.dispatch(
                        .login(student: settings.model.account.student)
                    )
                }
                .frame(maxWidth: .infinity, alignment: .center)
            }
        }
    }
}

struct SettingView_Previews: PreviewProvider {
    static var previews: some View {
        SettingView().environmentObject(Store())
    }
}
