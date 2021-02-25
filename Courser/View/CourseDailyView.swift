//
//  CourseDailyView.swift
//  Courser
//
//  Created by c on 2021/2/7.
//

import SwiftUI

struct CourseDailyView: View {
    @EnvironmentObject var store: Store
    
    var courseDailyBinding: Binding<AppState.DailyState> {
        $store.appState.courseDaily
    }

    var courseDaily: AppState.DailyState {
        store.appState.courseDaily
    }
    
    var model: DailyViewModel {
        courseDaily.model
    }

    var body: some View {
        NavigationView {
            ScrollView {
                // MARK: - 主体内容：当日课程列表
                ForEach(model.courseModels) { course in
                    NavigationLink(
                        destination: CourseDetailView(model: course),
                        label: {
                            CourseDailyRow(courseViewModel: course)
                        })
                }.padding()
            }
            .navigationBarTitle("第\(model.week)周 · 周\(model.weekday)")
            
        }
    }
}

// MARK: - 列表里的一行：一个课程的卡片
struct CourseDailyRow: View {
    let courseViewModel: CourseViewModel

    var body: some View {
        ZStack {
            // 背景 => 圆角矩形
            Rectangle()
                .foregroundColor(.white)

            HStack {
                // 图标
                Image("CourseAvatarSample") // TODO: realistic
                    .resizable()
                    .frame(width: 120, height: 120)

                // 文字信息
                VStack(alignment: .leading) {
                    Text(courseViewModel.course.courseName)
                        .font(.headline)
                        .foregroundColor(.primary)

                    Text(courseViewModel.course.teacher)

                    Text("\(courseViewModel.course.startTime)~\(courseViewModel.course.endTime)")

                    Text(courseViewModel.course.classroom)
                }.foregroundColor(.secondary)

                Spacer()
            }
        }
        .cornerRadius(12)
        .shadow(radius: 8)
    }
}

// MARK: - Preview
struct CourseDailyView_Previews: PreviewProvider {
    static var previews: some View {
        CourseDailyView().environmentObject(Store())
    }
}
