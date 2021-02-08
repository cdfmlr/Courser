//
//  CourseDailyView.swift
//  Courser
//
//  Created by c on 2021/2/7.
//

import SwiftUI

struct CourseDailyView: View {
    var body: some View {
        ScrollView {
            // MARK: - Head: Design 1. Image and Title

//            ZStack(alignment: .bottomLeading) {
//                Image("CourseImageSample") // TODO: realistic
//                    .resizable()
//                    .frame(height: 300)
//
//                VStack(alignment: .leading) {
//                    Text("第12周 · 周三")
//                        .font(.title)
//                        .bold()
//
//                    Text("2021年2月7日")
//                        .font(.callout)
//                }
//                .padding()
//                .foregroundColor(.white)
//            }

            // MARK: - Head: Design 2. No Image

            HStack {
                VStack(alignment: .leading) {
                    Text("第12周 · 周三")
                        .font(.title)
                        .bold()

                    Text("2021年2月7日")
                        .font(.callout)
                }
                .padding()

                Spacer()
            }

            Divider().padding(.horizontal)

            // MARK: - 主体内容：当日课程列表

            ForEach(sampleCourses, id: \.courseName) { course in
                ZStack {
                    Rectangle()
                        .foregroundColor(.white)

                    HStack {
                        Image("CourseAvatarSample") // TODO: realistic
                            .resizable()
                            .frame(width: 120, height: 120)

                        VStack(alignment: .leading) {
                            Text(course.courseName)
                                .font(.headline)
                                .foregroundColor(.primary)

                            Text(course.teacher)

                            Text("\(course.startTime)~\(course.endTime)")

                            Text(course.classroom)
                        }.foregroundColor(.secondary)

                        Spacer()
                    }
                }
                .cornerRadius(12)
                .shadow(radius: 8)

//                Divider()
//                    .padding(.leading, 128)
            }.padding()
        }
        // .edgesIgnoringSafeArea(.top) // for only Head Design 1
    }
}

struct CourseDailyView_Previews: PreviewProvider {
    static var previews: some View {
        CourseDailyView()
    }
}
