//
//  CourseTableView.swift
//  Courser
//
//  Created by c on 2021/2/13.
//

import SwiftUI

/// 一周的课程表
struct CourseTableView: View {
    @EnvironmentObject var store: Store
    
    var courseTableBinding: Binding<AppState.TableState> {
        $store.appState.courseTable
    }

    var courseTable: AppState.TableState {
        store.appState.courseTable
    }
    

    /// 一周有几天
    let weekdayNum = 7
    /// 一天有几节课
    let courseSectionNum = 10

    /// 表头高度
    let headerCellHeight: CGFloat = 30
    /// 单元格高度
    let cellHeight: CGFloat = 70

    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                ScrollView {
                    HStack(alignment: .top) {
                        rowsHeader(geometry: geometry)

                        ForEach(1 ..< weekdayNum + 1) { day in // 周一到周日
                            column(day: day, geometry: geometry)
                        }
                    }
                }.navigationBarTitle("课程表")
            }.padding(.horizontal)
        }
    }
}

extension CourseTableView {
    /// 第几节课：1, 2, 3, ...
    func rowsHeader(geometry: GeometryProxy) -> some View {
        return VStack {
            Text("")
                .frame(height: headerCellHeight)

            ForEach(1 ..< courseSectionNum + 1) { num in
                VStack {
                    Spacer()
                    Text("\(num)")
                    Spacer()
                    Divider()
                }.frame(
                    width: geometry.size.width / 18,
                    height: cellHeight,
                    alignment: .center
                )
            }
        }
    }

    /// 周几的各种课程，排成一列
    ///
    /// 这里面实现了 NavigationLink
    func column(day: Int, geometry: GeometryProxy) -> some View {
        VStack {
            Text("周\(day)")
                .frame(height: headerCellHeight)

            ForEach(courseTable.model.getCells(at: day), id: \.title) { cell in

                placeholderCell(heightGrid: cell.distancePrev, geometry: geometry)

                NavigationLink(
                    destination: CourseDetailView(model: cell.courseViewModel),
                    label: {
                        courseCell(cell: cell, geometry: geometry)
                    })
            }
        }.frame(width: geometry.size.width / 9)
    }

    /// 空白单元格：没课
    func placeholderCell(heightGrid: Int, geometry: GeometryProxy) -> some View {
        return Spacer()
            .frame(
                width: geometry.size.width / 9,
                height: cellHeight * CGFloat(heightGrid),
                alignment: .center
            )
    }

    /// 单元格：一节课
    func courseCell(cell: TableViewModel.TableCell, geometry: GeometryProxy) -> some View {
        Text(cell.title)
            .frame(
                width: geometry.size.width / 9,
                height: cellHeight * CGFloat(cell.length) * 0.95,
                alignment: .center
            )
            .background(cell.color)
            .foregroundColor(.white)
            .cornerRadius(cellHeight / 10)
            .shadow(radius: cellHeight / 12)
            .frame(
                width: geometry.size.width / 9,
                height: cellHeight * CGFloat(cell.length),
                alignment: .center
            )
    }
}

struct CourseTableView_Previews: PreviewProvider {
    static var previews: some View {
        CourseTableView().environmentObject(Store())
    }
}
