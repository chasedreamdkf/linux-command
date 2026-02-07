import { webview } from '@kit.ArkWeb';
import Query from '../type/type'


@Entry
@Component
struct CommandView {
  controller = new webview.WebviewController();
  router = this.getUIContext().getRouter();
  params = this.router.getParams() as Query;

  build() {
    Column() {
      Web({ src: `http://172.21.223.159:8080/command/${this.params.cmd}`, controller: this.controller })
      // Button('命令详情')
      //   .onClick(() => {
      //     console.log(`${this.params.cmd}`)
      //   })
    }
  }
}