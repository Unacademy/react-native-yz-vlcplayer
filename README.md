# react-native-yz-vlcplayer

A `<VLCPlayer>` component for react-native
Reference to this project[react-native-video](https://github.com/react-native-community/react-native-video)，
[react-native-vlcplayer](https://github.com/xiongchuan86/react-native-vlcplayer),
[react-native-vlc-player](https://github.com/ghondar/react-native-vlc-player)

VLCPlayer support for various formats (mp4,m3u8,flv,mov,rtsp,rtmp,etc.), see[vlc wiki](https://wiki.videolan.org/Documentation:Documentation/)

[https://code.videolan.org/videolan/VLCKit](https://code.videolan.org/videolan/VLCKit)


## Example project

   [https://github.com/xuyuanzhou/vlcplayerExample](https://github.com/xuyuanzhou/vlcplayerExample)

   ![](https://github.com/xuyuanzhou/resource/blob/master/gif/lizi.gif)


## Xcode10+ Some of problems

（1）Libstdc++.6.0.9.tbd can't find in Xcode10,
  Libstdc++.6.0.9.tbd was removed, and we removed it, OK.

（2）Compile the case of the card death (at present can only wait for the official correction of this problem)

   [https://forums.developer.apple.com/thread/107570](https://forums.developer.apple.com/thread/107570)

   (1)Removal of DSYM

   Project  Build Settings  --> Build Options --> Debug Information Format set to DWARF.

   ![](./images/dsym.png)

   (2)Change to Xcode10 the following version to compile




###  install

     `npm install react-native-yz-vlcplayer --save`


## android setup

android vlc-sdk from:[https://github.com/mengzhidaren/Vlc-sdk-lib](https://github.com/mengzhidaren/Vlc-sdk-lib)

step 1:

Run `react-native link react-native-yz-vlcplayer`


## ios setup

combined from  [react-native-vlcplayer](https://github.com/xiongchuan86/react-native-vlcplayer) 。

reference: [https://code.videolan.org/videolan/VLCKit](https://code.videolan.org/videolan/VLCKit)

step 1:

   Run `react-native link react-native-yz-vlcplayer`

step 2:

   download  MobileVLCKit.framework from  [nightlies.videolan.org/build/iOS/](http://nightlies.videolan.org/build/iOS/)

step 3:

   create a folder named vlcKit, and copy MobileVLCKit.framework in this folder.

   ![](./images/7.png)

step 4:

   In XCode, in the project navigator, right click Frameworks -> Add Files to [your project's name], go to `/vlckit` and add MobileVLCKit.framework


   ![](./images/2.png)

   ![](./images/3.png)

step 5:

   add framework search path:      `$(PROJECT_DIR)/../vlcKit`

   ![](./images/1.png)


step 6:

   Select your project. Add the following libraries to your project's Build Phases -> Link Binary With Libraries:

   * AudioToolbox.framework
   * VideoToolbox.framework
   * CoreMedia.framework
   * CoreVideo.framework
   * CoreAudio.framework
   * AVFoundation.framework
   * MediaPlayer.framework
   * libstdc++.6.0.9.tbd
   * libiconv.2.tbd
   * libc++.1.tbd
   * libz.1.tbd
   * libbz2.1.0.tbd

step 7:

   set `Enable Bitcode`  to  `no`

   Build Settings ---> search  Bitcode

   ![](./images/4.png)


step 8:

  set project deployment target  `9.3`



## other react-native plugins

   1. npm install react-native-orientation --save

      react-native link react-native-orientation

   2. npm install react-native-slider --save

   3. npm install react-native-vector-icons --save

      react-native link react-native-vector-icons


## Static Methods

`seek(seconds)`

```
android:
    this.vlcplayer.seek(100); //  unit  ms
ios:
    this.vlcplayer.seek(0.1); //  0 --- 1 Video Location Progress


this.vlcPlayer.resume(autoplay) //Reload the video for playback, autopaly:true indicates that playing false indicates a pause

this.vlcPlayer.play(bool)       // true: play the video   false: paused the video


this.vlcPlayer.snapshot(path)  // path: string  The path to the stored file.


```

##  VLCPlayer props

    import { VLCPlayer } from 'react-native-yz-vlcplayer';

   | props       | type     |  value  |   describe |
   | --------    | :----:   |  :----:  |   :----:   |
   | paused      | bool     |         |            |
   | muted       | bool     |         |            |
   | volume      | bool     | 0---200 |            |
   | hwDecoderEnabled | number  | 0  or  1 |   (Only android)  need  use with hwDecoderForced |
   | hwDecoderForced  | number  | 0  or  1 |   (Only android)  need  use with hwDecoderEnabled|
   | initType    | number   |         |            |
   | initOptions | array    |         |            |
   | mediaOptions| object   |         |            |
   | source      | object   | { uri: 'http:...' }| |
   | autoplay    | bool     |       |  Whether to play automatically (default false) |
   | onLoadStart | func     |       |  VLC video container initialization completed  |
   | onOpen      | func     |       |  Video is turned on        |
   | onBuffer    | func     |       |  Buffering in progress     |
   | onProgress  | func     | { currentTime:1000,duration:1000 }  unit：ms    |  Video Progress changes     |
   | onEnd       | func     |       |  Video playback ends        |
   | onPlaying   | func     |       |  Video is playing           |
   | onPaused    | func     |       |  Video Pause                |
   | onError     | func     |       |  Error playing video       |
   | onStopped   | func     |       |  Video stops playing (live video please be judged by this) |
   | onIsPlaying | func     | {isPlaying:true}   |  Whether the video is playing       |


   ```
      initType:   1,2     default value: 1
        example:
             ios:
                   1: [[VLCMediaPlayer alloc] init]
                   2: [[VLCMediaPlayer alloc] initWithOptions:options];

   ```

   initOptions:

   [https://wiki.videolan.org/VLC_command-line_help](https://wiki.videolan.org/VLC_command-line_help)

   [https://www.cnblogs.com/waimai/p/3342739.html](https://www.cnblogs.com/waimai/p/3342739.html)



   ```
      onBuffer:

        android: {
                    isPlaying: true,
                    bufferRate: 70,
                    duration: 0,
                 }

            ios: {
                   duration: 0,
                   isPlaying: true,
                 }

      onProgress:

                {
                    currentTime: 1000        ms
                    duration: 5000           ms
                }

      onIsPlaying:

                {
                    isPlaying: true
                }



   ```


## A brief description of the callback function (currently encountered)
 ```
                                                             支持平台
           onEnd            Video playback ends                  ios       android
           onBuffer         Buffering in progress                    ios       android
           onError          Error playing video
           onPlaying        Video playback                      ios       android
           onPaused         Video Pause                      ios       android
           onOpen           Video is turned on                              android
           onLoadStart      VLC video container initialization completed          ios       android
           onProgress       Video Progress changes               ios       android          SWF format does not support

           The order in which the callback function appears:  onLoadStart  ---> onOpen

 ```


##  use plugin
````
   import { VLCPlayer, VlCPlayerView } from 'react-native-yz-vlcplayer';
   import Orientation from 'react-native-orientation';

   (1)
       android:
           this.vlcplayer.seek(100); // Unit ms
       ios:
           this.vlcplayer.seek(0.1); // 0 --- 1 Video Location Progress
  （2）
       <VLCPlayer
           ref={ref => (this.vlcPlayer = ref)}
           style={[styles.video]}
           /**
            *  Increase the video aspect ratio and the video will stretch at this rate
            *  Do not set by default scale
            */
           videoAspectRatio="16:9"
           /**
            *  Whether to pause playback
            */
           paused={this.state.paused}
           /**
            *  Resource Path
            *  Local resources are not supported on a temporary
            */
           source={{ uri: this.props.uri}}
           /**
            *  Progress
            *  Return {currentTime:1000,duration:1000}
            *  Unit is ms
            *  currentTime: Current time
            *  duration:    Total time
            */
           onProgress={this.onProgress.bind(this)}
           /**
            *  Video playback ends
            */
           onEnd={this.onEnded.bind(this)}
           /**
            * is in the cache
            */
           onBuffer={this.onBuffering.bind(this)}
           /**
            * Error playing video
            */
           onError={this._onError}
           /**
            * Video Stop
            */
           onStopped={this.onStopped.bind(this)}
           /**
            * Video playback
            */
           onPlaying={this.onPlaying.bind(this)}
           /**
            * Video Pause
            */
           onPaused={this.onPaused.bind(this)}
           /**
            * Video is turned on
            /
           onOpen={this._onOpen}
           /**
            * VLC video container initialization completed
            * Set the progress of playback here, whether to start playing
            */
           onLoadStart={()=>{
                   if(Platform.OS === 'ios'){
                       this.vlcPlayer.seek(0); //Set Playback Progress
                   }else{
                       this.vlcPlayer.seek(0); //Set the time of playback
                   }
                   this.setState({
                     paused: true,
                   },()=>{
                     this.setState({
                       paused: false,
                     });
                   })
           }}
       />

````

## Available sources

Hong Kong Finance,rtmp://202.69.69.180:443/webcast/bshdlive-pc

Hunan Satellite TV,rtmp://58.200.131.2:1935/livetv/hunantv

rtsp://184.72.239.149/vod/mp4://BigBuckBunny_175k.mov


## Simple description of the version

````
    1.1.1-beta7:
        (1) Increase  autoAspectRatio  bool  (only  on  Android)
            Full Android Full Screen
````


## Simple Example

````
   (1)
      1. npm install react-native-orientation --save

         react-native link react-native-orientation

      2. npm install react-native-slider --save

      3. npm install react-native-vector-icons --save

         react-native link react-native-vector-icons

   (2)

       import { VLCPlayer, VlcSimplePlayer } from 'react-native-yz-vlcplayer';
       import Orientation from 'react-native-orientation';





       <VlcSimplePlayer
           ref={ ref => this.vlCPlayerView = ref}
           url={"rtmp://live.hkstv.hk.lxdns.com/live/hks"}
           Orientation={Orientation}
       />

       Note:
        《1》 The plug-in uses the aspect ratio (1.1.1-BETA1 and below) as shown below by default
            fullVideoAspectRatio: deviceHeight + ':' + deviceWidth,
            videoAspectRatio: deviceWidth + ':' + 211.5,
            （1）If there is a problem with the picture scale in the case of vertical screen, please set your own aspect ratio or remove the built-in aspect ratio
            （2）If the default height is modified in a non-full screen, set your own aspect ratio or remove the built-in aspect ratio
                Remove built-in aspect ratio
                            fullVideoAspectRatio={""}
                            videoAspectRatio={""}
        《2》 By default does not play automatically, need to play automatically please add the following parameters
             autoplay={true}

        《3》 You can customize the following parameters :
                endingViewText: {
                    endingText: 'End of video program',
                    reloadBtnText: 'Replay',
                    nextBtnText: 'Next'
                },
                errorViewText: {
                    errorText: 'Video playback Error',
                    reloadBtnText: 'Replay',
                },
                vipEndViewText: {
                    vipEndText: 'End of the sample',
                    boughtBtnText: 'Please watch and buy now after purchasing',
                },

      Here are some of the parameters that are available:

       static propTypes = {

        /**
            * vlc Playback type related
            */
               //Type of AD initialization
               initAdType: PropTypes.oneOf([1,2]),
               //AD Initialization Parameters
               initAdOptions: PropTypes.array,

               //Video initialization type
               initType: PropTypes.oneOf([1,2]),
               //Video Initialization parameters
               initOptions: PropTypes.array,

           /**
            * Live related
            */
                //Is it live?
                isLive: PropTypes.bool,
                //Whether to automatically reload  live
                autoReloadLive: PropTypes.bool,

           /**
            * Advertising related
            */
               //Whether to display ads
               showAd:  PropTypes.bool,
               //Advertising
               adUrl: PropTypes.oneOfType([PropTypes.string,PropTypes.number]).isRequired,
               //Reload includes ads
               reloadWithAd: PropTypes.bool,
               //End of AD header playback
               onAdEnd: PropTypes.func,
               //Whether the ad is playing
               onIsAdPlaying: PropTypes.func,


           /**
            * Screen related
            */
           // Initialize with full screen
           initWithFull: PropTypes.bool,
           //Turn on the full screen callback function
           onStartFullScreen: PropTypes.func,
           //Turn off the full-screen callback function
           onCloseFullScreen: PropTypes.func,

           /**
            * Video related
            */

               //Video Path：
                    //string:  Local or network resource path
                    //number:  require('./resource/1.mp4')
               url: PropTypes.oneOfType([PropTypes.string,PropTypes.number]).isRequired,
               //Video playback ends
               onEnd: PropTypes.func,
               //Whether to play the
               onIsPlaying: PropTypes.func,
               //Time already viewed
               lookTime: PropTypes.number,
               //Total time
               totalTime: PropTypes.number,
               //Is there a next video source
               hadNext: PropTypes.bool,
               //Automatically play the next video
               autoPlayNext: PropTypes.bool,
               //Auto Repeat Playback
               autoRePlay: PropTypes.bool,


           /**
            * Style related
            */
               //Video Style
               style: PropTypes.object,
               //Full Screen video styles
               fullStyle: PropTypes.object,
               //Do you need to consider StatusBar   only for ios
               considerStatusBar: PropTypes.bool,
               //Whether to display the top
               showTop: PropTypes.bool,
               //Title
               title: PropTypes.string,
               //Whether to display the title
               showTitle: PropTypes.bool,
               //Whether to display the return button
               showBack: PropTypes.bool,
               //Back button click event
               onLeftPress: PropTypes.func,

           /**
            * VIP related
            */
               //Whether to use VIP
               useVip: PropTypes.bool,
               //on-VIP viewing length
               vipPlayLength: PropTypes.number,

         };

````

````
    /**
     * Sample React Native App
     * https://github.com/facebook/react-native
     *
     * @format
     * @flow
     */

    import React, {Component} from 'react';
    import {StyleSheet, View} from 'react-native';
    import {VlcSimplePlayer, VLCPlayer}  from 'react-native-yz-vlcplayer';


    export default class App extends Component<Props> {
        render() {
            return (
                <View style={styles.container}>
                <VlcSimplePlayer
                    autoplay={false}
                    url='rtsp://184.72.239.149/vod/mp4://BigBuckBunny_175k.mov'
                    initType={2}
                    hwDecoderEnabled={1}
                    hwDecoderForced={1}
                    initOptions={[
                        "--no-audio",
                        "--rtsp-tcp",
                        "--network-caching=" + 150,
                        "--rtsp-caching=" + 150,
                        "--no-stats",
                        "--tcp-caching=" + 150,
                        "--realrtsp-caching=" + 150,
                    ]}
                />
                <VLCPlayer
                    style={{width:"100%",height:200,marginTop:30}}
                    source={{uri:'rtsp://184.72.239.149/vod/mp4://BigBuckBunny_175k.mov'}}
                    initType={2}
                    initOptions={[
                        "--network-caching=" + 150,
                        "--rtsp-caching=" + 150,
                        "--no-stats",
                        "--tcp-caching=" + 150,
                        "--realrtsp-caching=" + 150,
                    ]}
            />
            </View>
        );
        }
    }

    const styles = StyleSheet.create({
        container: {
            flex: 1,
            justifyContent: 'center',
            alignItems: 'center',
            backgroundColor: '#F5FCFF',
        },
    });

````


**MIT Licensed**
