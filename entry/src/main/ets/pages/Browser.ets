import { HttpErrorComponent, LoadComponent } from '../Component/components';
import { webview } from '@kit.ArkWeb';
import { hilog } from '@kit.PerformanceAnalysisKit';

interface RouterParameters {
  url: string
}

interface ExtObj {
  test: (str: string) => string;
}

// 自定义UA
const PAD_USER_AGENT: string = 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTMl, like Gecko) Chrome/99.0.4844.88 Safari/537.36'
const PHONE_USER_AGENT: string = 'Mozilla/5.0 (Linux; Android 10.0; ohos) AppleWebKit/537.36 (KHTMl, like Gecko) Chrome/99.0.4844.88 HuaweiBrowser/13.0.4.302 Mobile Safari/537.36'

@Entry
@Component
struct Browser {
  @State isLoading: boolean = false
  @State isHttpError: boolean = false
  @State title: string = ''
  @State url: string = ''
  @State isPhone: boolean = true
  controller: webview.WebviewController = new webview.WebviewController()
  // 扩展浏览器对象
  extObj: ExtObj = {
    test: (str) => {
      console.log("extObj.test: " + str)
      return "test " + str
    }
  }

  onPageShow() {
    let params = this.getUIContext().getRouter().getParams() as RouterParameters
    this.url = params.url
  }

  build() {
    Column() {
      if (this.isLoading) {
        LoadComponent()
      }

      if (this.isHttpError) {
        HttpErrorComponent({
          text: 'Seems you don\'t have Internet'
        })
      }

      // 加载在线网页
      Web({ src: this.url, controller: this.controller })
        .width('100%')
        .height('110%')
        .padding({ bottom: 56 })
        .javaScriptAccess(true)
        .javaScriptProxy({
          object: this.extObj,
          name: "extObj",
          methodList: ["test"],
          controller: this.controller,
        })
        .fileAccess(true)
        .domStorageAccess(true)
        .zoomAccess(true)
        .onControllerAttached(() => {
          this.controller.loadUrl(this.url)
          this.controller.setCustomUserAgent(this.isPhone ? PHONE_USER_AGENT : PAD_USER_AGENT)
        })
        .onPageBegin((event) => {
          this.isLoading = false

          // 在重新加载的时候
          this.isHttpError = false
          hilog.info(0x0, '[Index]', `onPageBegin= ${JSON.stringify(event)}`)
        })
        .onPageEnd((event) => {
          hilog.info(0x0, '[Index]', `onPageEnd= ${JSON.stringify(event)}`)
        })
        .onProgressChange(() => {
          hilog.info(0x0, '[Index]', `onProgressChange`)
        })
        .onErrorReceive((event) => {
          if (event) {
            this.isHttpError = true
          }
        })

    }
    .width('100%')
    .height('100%')
  }
}

