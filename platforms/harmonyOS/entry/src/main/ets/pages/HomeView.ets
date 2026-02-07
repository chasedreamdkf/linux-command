import { CommandList } from "../components/CommandList";
import getLinuxCommandList from "../utils/dataLoader";

let commandListStore: Array<string> = [];

// @Entry
@Component
export struct HomeView {
  @State command: string = '';
  @State commandList: Array<string> = [];

  async aboutToAppear() {
    commandListStore = await getLinuxCommandList();
    this.commandList = commandListStore;
  }

  build() {
    Column() {
      TextInput({ placeholder: "请输入命令", text: $$this.command })     // 使用`$$`对数据进行双向绑定
        .onChange(() => {
          if (this.command != '') {
            this.commandList = this.commandList.filter((value: string) => value.includes(this.command))
          } else {
            this.commandList = commandListStore;
          }
        })
        .borderRadius('10.00vp')
        .backgroundColor('#fff')
        .width(320)
        .margin({ bottom: 20 })
      Column() {
        Scroll() {
          CommandList({ commandList: this.commandList })
        }
      }
      .height('85%')

    }
    .margin(5)
    .backgroundColor('#f1f2f3')
    .height('100%')
  }
}