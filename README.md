# react-native-yz-vlcplayer

A `<VLCPlayer>` component for react-native  
此项目 参考react-native-video，react-native-vlcplayer, react-native-vlc-player

VLCPlayer 支持各种格式(mp4,m3u8,flv,mov,rtsp,rtmp,etc.)，具体参看[vlc wiki](https://wiki.videolan.org/Documentation:Documentation/)


### Add it to your project

Run `npm install react-native-yz-vlcplayer --save`

## android

android vlc-sdk 库来源:[https://github.com/mengzhidaren/Vlc-sdk-lib](https://github.com/mengzhidaren/Vlc-sdk-lib)

Run `react-native link react-native-yz-vlcplayer`

## FullScreen ##
需要用到 `npm install react-native-orientation --save` ，工程配置参看[https://github.com/yamill/react-native-orientation](https://github.com/yamill/react-native-orientation)  

## Static Methods

`seek(seconds)`

```
this.vlcplayer.seek(100); //单位是 ms
```




## Examples

````
   import { VLCPlayer, VlCPlayerView } from 'react-native-yz-vlcplayer';
   import Orientation from 'react-native-orientation';
   
   //插件参数说明
   (1) 静态方法
       this.vlcplayer.seek(100); //调整播放进度，单位是ms
  （2）
       <VLCPlayer
           ref={ref => (this.vlcPlayer = ref)}
           style={[styles.video]}
           /**
            *  是否暂停播放
            */
           paused={this.state.paused}
           /**
            *  资源路径
            *  暂不支持本地资源
            */
           source={{ uri: this.props.uri}}
           /**
            *  进度   
            *  返回 {currentTime:1000,duration:1000} 
            *  单位是 ms
            *  currentTime: 当前时间  
            *  duration:    总时间  
            */
           onProgress={this.onProgress.bind(this)}
           /**
            *  视屏播放结束
            */
           onEnd={this.onEnded.bind(this)}
           /**
            * 正在缓存中
            */
           onBuffering={this.onBuffering.bind(this)}
           onError={this._onError}
           //onStopped={this.onEnded.bind(this)}      暂未实现
           //onPlaying={this.onPlaying.bind(this)}    暂未实现
           //onPaused={this.onPaused.bind(this)}      暂未实现
       />
   （3）简单例子
       <VlCPlayerView
           url={this.state.url}           //视屏url
           Orientation={Orientation}      
           //BackHandle={BackHandle}
           ggUrl=""                      // 广告url
           showGG={true}                 // 是否显示广告
           startFullScreen={() => {      
              this.setState({
              isFull: true,
             });
           }}
           closeFullScreen={() => {
              this.setState({
              isFull: false,
             });
           }}
       />
````



**MIT Licensed**
