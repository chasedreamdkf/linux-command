import Query from '../type/type'

@Component
export struct CommandList {
  @Prop commandList: Array<string>;
  private gridScroller: Scroller = new Scroller();
  router = this.getUIContext().getRouter()

  routePage(cmd: string) {
    this.router.pushUrl({ url: 'pages/CommandView', params: new Query(cmd) })
  }

  build() {
    Grid(this.gridScroller) {
      ForEach(this.commandList, (item: string) => {
        GridItem() {
          Text(item)
            .fontSize(20)
            .fontColor(Color.Blue)
            .textAlign(TextAlign.Center)
        }
        .onClick(() => {
          this.routePage(item)
        })
        .backgroundColor("#ffffff")
        .borderRadius(2)
        .width(100)
        .height(50)
        .margin({ left: 10, top: 10 })
      })
    }
    .width('100%')
    // .height('90%')
    .scrollBarWidth(2)
  }
}