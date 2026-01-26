import { HomeView } from "./HomeView";

@Entry
@Component
struct Index {

  build() {
    Column() {
      Column() {
        Text("Linux命令搜索引擎")
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
      }.margin({ left: 5 })
      HomeView()
    }
    .margin(5)
    .backgroundColor('#f1f2f3')
    .height('100%')
  }
}