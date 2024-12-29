import webview from '@ohos.web.webview';
import socket from '@ohos.net.socket';
import { BusinessError } from '@kit.BasicServicesKit';

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

class TCPClient {
  private tcpSocket: socket.TCPSocket;

  constructor() {
    // 创建 TCPSocket 实例
    this.tcpSocket = socket.constructTCPSocketInstance();
  }

  // 连接到服务器
   connect(serverIp: string, serverPort: number): boolean {
    let netAddress: socket.NetAddress = {
      address: serverIp,
      port: serverPort
    }
    this.tcpSocket.connect({ address: netAddress }, (err: BusinessError) => {
      if (err) {
        console.log('connect fail');
        return false;
      }
      console.log('connect success');
      return true;
    })
     return false;
  }

  // 发送数据
  sendData(sendData: string): boolean {

    this.tcpSocket.send({ data:sendData } , (err: BusinessError) => {
      if (err) {
        console.log(err.message);
        return false;
      }
      console.log('send success');
      return true;
    })
    return false;
  }

  // 接收数据
  async receiveData(): Promise<string> {
    return new Promise((resolve, reject) => {
      this.tcpSocket.on('message', (message: socket.SocketMessageInfo) => {
        const data = message.message?.toString();
        console.log('Data received:', data);
        resolve(data || '');
      });
    });
  }

  // 关闭连接
  close(): boolean {
    this.tcpSocket.close();
    console.log('Connection closed');
    return false;
  }
}


@Entry
@Component
struct Index {
  @State tcpSocket:TCPClient = new TCPClient();

  webviewController: WebviewController = new webview.WebviewController();
  responseResource: WebResourceResponse = new WebResourceResponse();
  mimeTypeStruct: MimeTypeStruct = new MimeTypeStruct();
  fakePath = "http://localapp/";

  build() {
    RelativeContainer() {


      Web({ src: this.fakePath, controller: this.webviewController })
        
        .javaScriptAccess(true)
        .javaScriptProxy({
          object: this.tcpSocket,
          name: "tcpSocket",
          methodList: ["connect", "sendData", "close"],
          controller: this.webviewController
        } )

        .onInterceptRequest((event) => {
          if (event) {
            const requestUrl = event.request.getRequestUrl();
            if (requestUrl.startsWith(this.fakePath)) {
              let path = requestUrl.replace(this.fakePath, '');
              if (path == '') {
                path = 'index.html';
              }

              this.responseResource.setResponseData($rawfile(path));
              this.responseResource.setResponseEncoding('utf-8');
              let parts = path.split(".");
              let fileType = parts.pop() ?? "";
              let mimeType = this.mimeTypeStruct.getMimeType(fileType);
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