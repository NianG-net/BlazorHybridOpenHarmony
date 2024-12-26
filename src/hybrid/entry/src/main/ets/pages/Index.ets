import webview from '@ohos.web.webview';
class MimeTypeStruct {
  // 定义属性
  mimeTypes: Record<string, string>;

  // 构造函数
  constructor() {
    this.mimeTypes = {
      "html": "text/html",
      "css": "text/css",
      "js": "text/javascript",
      "png": "image/png",
      "gif": "image/gif",
      "svg": "image/svg+xml",
      "wasm": "application/wasm",
    };
  }

  // 方法：根据文件扩展名获取 MIME 类型
  getMimeType(fileExtension: string): string {

    return this.mimeTypes[fileExtension] || "text/plain";
  }
}

@Entry
@Component
struct Index {
  webviewController:WebviewController = new webview.WebviewController();
  responseResource: WebResourceResponse = new WebResourceResponse();
  mimeTypeStruct: MimeTypeStruct = new MimeTypeStruct();
  fakePath = "http://localapp/";
  build() {
    RelativeContainer() {

      Web({src: this.fakePath ,controller:this.webviewController})
        .onInterceptRequest((event) =>
        {
          if (event)
          {
            const requestUrl = event.request.getRequestUrl();
            const mimeTypeStruct = new MimeTypeStruct();
            if(requestUrl.startsWith(this.fakePath))
            {
              let  path = requestUrl.replace(this.fakePath,'');
              if(path ==  '')
              {
                path = 'index.html';
              }

              this.responseResource.setResponseData($rawfile(path));
              this.responseResource.setResponseEncoding('utf-8');
              let parts = path.split(".");
              let fileType = parts.pop() ?? "";
              let mimeType = mimeTypeStruct.getMimeType(fileType);
              this.responseResource.setResponseMimeType(mimeType);
              this.responseResource.setResponseCode(200);
              this.responseResource.setReasonMessage('OK');
              return this.responseResource;
            }

          }
          return null;
        })
    }
    .height('100%')
    .width('100%')
  }
}