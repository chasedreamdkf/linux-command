@Component
export struct CommandList {
  @Prop commandList: Array<string>;
  private gridScroller: Scroller = new Scroller();

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
          console.log(item)
        })
        .backgroundColor("#ffffff")
        .borderRadius(2)
        .width(100)
        .height(50)
        .margin({left: 10, top: 10})
      })
    }
    .width('100%')
    .scrollBarWidth(2)
  }
}