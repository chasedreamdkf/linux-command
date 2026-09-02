/**
 * 搜索输入组件，保持输入行为与 Web 端首页一致。
 */
@Component
export struct SearchBar {
  @Prop query: string = '';
  onQueryChange: (value: string) => void = (value: string): void => {};

  build() {
    TextInput({ placeholder: '输入命令名称搜索，例如 ls、cd、grep', text: this.query })
      .height(44)
      .width('100%')
      .fontSize(16)
      .fontColor('#182431')
      .placeholderColor('#8A8F99')
      .backgroundColor('#FFFFFF')
      .borderRadius(12)
      .padding({ left: 14, right: 14 })
      .onChange((value: string) => {
        this.onQueryChange(value);
      })
  }
}
