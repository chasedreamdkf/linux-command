import { CommandList } from "../components/CommandList"

const commandListStore: Array<string> = [];

// @Entry
@Component
export struct HomeView  {
  @State command: string = '';
  @State commandList: Array<string> = [];

  aboutToAppear(): void {
    for (let i = 1; i <= 36; i++) {
      commandListStore.push(`item ${i}`);
    }
    this.commandList = commandListStore;
  }

  build() {
    Column() {
      TextInput({placeholder: "请输入命令", text: $$this.command})     // 使用`$$`对数据进行双向绑定
        .onChange(() => {
            if (this.command) {
              this.commandList = this.commandList.filter((value: string) => value.includes(this.command))
            } else {
              this.commandList = commandListStore;
            }
        })
        .borderRadius('10.00vp')
        .backgroundColor('#fff')
        .width(320)
      CommandList({commandList: this.commandList})
    }
    .margin(5)
    .backgroundColor('#f1f2f3')
    .height('100%')
  }
}