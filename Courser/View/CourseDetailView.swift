//
//  CourseDetailView.swift
//  Courser
//
//  Created by c on 2021/2/7.
//

import SwiftUI

struct CourseDetailView: View {
    let model: CourseViewModel

    var body: some View {
        ScrollView {
            // MARK: - Head Image

            Image("CourseImageSample") // TODO: realistic
                .resizable()
//                .edgesIgnoringSafeArea(.top)
                .frame(height: 200)

            // MARK: - Avatar and Title

            HStack(alignment: .top) {
                Image("CourseAvatarSample") // TODO: realistic
                    .resizable()
                    .frame(width: 120, height: 120)

                VStack(alignment: .leading) {
                    Text(model.course.courseName)
                        .font(.title)
                        .bold()

                    Text(model.course.teacher)
                        .foregroundColor(.secondary)

                    Spacer()

                    // Buttons
                    HStack {
                        Button(action: {}) {
                            Text("添加到日历")
                                .padding(8)
                                .foregroundColor(.white)
                                .background(model.color)
                                .cornerRadius(24)
                        }

                        Spacer()

                        // share
                        Image(systemName: "square.and.arrow.up")
                            .foregroundColor(model.color)
                    }
                }
            }.padding()

            // MARK: - Simple Information

            ScrollView(.horizontal) {
                Divider()

                HStack {
                    SimpleVerticalInfoCell(
                        key: "开始时间",
                        value: model.course.startTime,
                        appendix: "CST"
                    )

                    Divider()

                    SimpleVerticalInfoCell(
                        key: "结束时间",
                        value: model.course.endTime,
                        appendix: "CST"
                    )

                    Divider()

                    SimpleVerticalInfoCell(
                        key: "开课时间",
                        value: model.courseWeekday,
                        appendix: model.courseSessions
                    )

                    Divider()

                    SimpleVerticalInfoCell(
                        key: "开课周次",
                        value: model.course.courseWeeks,
                        appendix: "周"
                    )

                    Divider()

                    SimpleVerticalInfoCell(
                        key: "教室地点",
                        value: model.course.classroom,
                        appendix: "🚲"
                    )
                }

                Divider()

//                Spacer().padding(2)
            }
            .padding()
            .edgesIgnoringSafeArea(.horizontal)

            // MARK: Complex Information

            VStack(alignment: .leading) {
                HStack {
                    Text("关于课程")
                        .font(.title2)
                    Spacer()
                }.padding(.bottom)

                ComplexHorizontalInfoView(
                    icon: Image(systemName: "location.circle"),
                    headline: "教室地址",
                    detial: model.course.classroom,
                    color: model.color
                )

                Divider().padding(.leading, 70)

                ComplexHorizontalInfoView(
                    icon: Image(systemName: "calendar.circle"),
                    headline: "上课时间",
                    detial: "\(model.course.courseWeeks)周：\(model.courseWeekday)\(model.courseSessions)",
                    color: model.color
                )

            }.padding()

            Divider()

            Text("这里有些空白，可以考虑放点废话：他试着哼起欢快的小曲，但返回耳中时已经成了空洞的挽歌，他停了下来。")
                .font(.footnote)
                .foregroundColor(.secondary)
                .padding()

//            Text("Hello, World!")
        }.edgesIgnoringSafeArea(.top)
    }
}

struct SimpleVerticalInfoCell: View {
    let key: String
    let value: String
    let appendix: String

    var body: some View {
        VStack {
            Text(key)
                .font(.callout)

            Text(value)
                .font(.system(size: 24, weight: .bold, design: .monospaced))
                .padding(2)

            Text(appendix)
                .font(.callout)

        }.foregroundColor(.secondary)
    }
}

struct ComplexHorizontalInfoView: View {
    let icon: Image
    let headline: String
    let detial: String
    let color: Color

    var body: some View {
        HStack {
            icon
                .resizable()
                .frame(width: 45, height: 45)
                .padding(.trailing, 4)

            VStack(alignment: .leading) {
                Text(headline)
                    .font(.headline)
                    .padding(.vertical, 2)
                    .foregroundColor(.primary)

                Text(detial)
            }
        }
        .padding(.horizontal)
        .foregroundColor(color)
    }
}

struct CourseDetailView_Previews: PreviewProvider {
    static var previews: some View {
        CourseDetailView(model: CourseViewModel(course: sampleCourses.first!))
    }
}
