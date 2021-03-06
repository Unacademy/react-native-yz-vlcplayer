#import "React/RCTConvert.h"
#import "RCTVLCPlayer.h"
#import "React/RCTBridgeModule.h"
#import "React/RCTEventDispatcher.h"
#import "React/UIView+React.h"
#import <MobileVLCKit/MobileVLCKit.h>
#import <AVFoundation/AVFoundation.h>
static NSString *const statusKeyPath = @"status";
static NSString *const playbackLikelyToKeepUpKeyPath = @"playbackLikelyToKeepUp";
static NSString *const playbackBufferEmptyKeyPath = @"playbackBufferEmpty";
static NSString *const readyForDisplayKeyPath = @"readyForDisplay";
static NSString *const playbackRate = @"rate";

@interface RCTVLCPlayer () <VLCMediaPlayerDelegate,VLCMediaDelegate>
@end

@implementation RCTVLCPlayer
{
    
    /* Required to publish events */
    RCTEventDispatcher *_eventDispatcher;
    VLCMediaPlayer *_player;
    
    NSDictionary * _source;
    BOOL _paused;
    BOOL _started;
    BOOL _loaded;
    float _progressUpdateInterval;
    float _progressAddonTime;
    id _timeObserver;
    float _playBackRate;
    
}

- (instancetype)initWithEventDispatcher:(RCTEventDispatcher *)eventDispatcher
{
    if ((self = [super init])) {
        _eventDispatcher = eventDispatcher;
        _loaded = false;
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(applicationWillResignActive:)
                                                     name:UIApplicationWillResignActiveNotification
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(applicationWillEnterForeground:)
                                                     name:UIApplicationWillEnterForegroundNotification
                                                   object:nil];
        
    }
    
    return self;
}


- (void)applicationWillResignActive:(NSNotification *)notification
{
    if (!_paused) {
        [self setPaused:_paused];
    }
}

- (void)applicationWillEnterForeground:(NSNotification *)notification
{
    [self applyModifiers];
}

- (void)applyModifiers
{
    if(!_paused)
        [self play];
}

- (void)setPaused:(BOOL)paused
{
    if(_player){
        if(!paused){
            [self play];
        }else {
            [_player pause];
            _paused =  YES;
            _started = NO;
            [self removePlayerTimeObserver];
        }
    }
}

-(void)play
{
    if(_player){
        [_player play];
        _paused = NO;
        _started = YES;
    }
}

-(void)setResume:(BOOL)autoplay
{
    @try{
        char * videoRatio = nil;
        if(_player){
            videoRatio = _player.videoAspectRatio;
            [_player stop];
            _player = nil;
        }
        NSMutableDictionary* mediaOptions = [_source objectForKey:@"mediaOptions"];
        NSArray* options = [_source objectForKey:@"initOptions"];
        NSString* uri    = [_source objectForKey:@"uri"];
        NSInteger initType = [RCTConvert NSInteger:[_source objectForKey:@"initType"]];
        BOOL autoplay = [RCTConvert BOOL:[_source objectForKey:@"autoplay"]];
        BOOL isNetWork   = [RCTConvert BOOL:[_source objectForKey:@"isNetwork"]];
        BOOL isAsset   = [RCTConvert BOOL:[_source objectForKey:@"isAsset"]];
        NSURL* _uri    = [NSURL URLWithString:uri];
        if(uri && uri.length > 0){
            //init player && play
            if(initType == 2){
                _player = [[VLCMediaPlayer alloc] initWithOptions:options];
            }else{
                _player = [[VLCMediaPlayer alloc] init];
            }
            [_player setDrawable:self];
            _player.delegate = self;
            _player.scaleFactor = 0;
            //Set how many milliseconds to cache
            // [mediaDictonary setObject:@"1500" forKey:@"network-caching"];
            VLCMedia *media = nil;
            if(isNetWork || isAsset){
                media = [VLCMedia mediaWithURL:_uri];
            }else{
                media = [VLCMedia mediaWithPath: uri];
            }
            media.delegate = self;
            if(mediaOptions){
                [media addOptions:mediaOptions];
            }
            /*if(videoRatio){
             _player.videoAspectRatio = videoRatio;
             }*/
            [media parseWithOptions:VLCMediaParseLocal|VLCMediaFetchLocal|VLCMediaParseNetwork|VLCMediaFetchNetwork];
            _player.media = media;
            if(autoplay)
                [self play];
            if(self.onVideoLoadStart){
                self.onVideoLoadStart(@{
                                        @"target": self.reactTag
                                        });
            }
        }
    }
    @catch(NSException *exception){
        NSLog(@"%@", exception);
    }
}

-(void)setSource:(NSDictionary *)source
{
    @try{
        if(_player){
            [_player stop];
            _player = nil;
        }
        _loaded = false;
        _source = source;
        NSMutableDictionary* mediaOptions = [source objectForKey:@"mediaOptions"];
        NSArray* options = [source objectForKey:@"initOptions"];
        NSString* uri    = [source objectForKey:@"uri"];
        NSInteger initType = [RCTConvert NSInteger:[source objectForKey:@"initType"]];
        BOOL autoplay = [RCTConvert BOOL:[source objectForKey:@"autoplay"]];
        BOOL isNetWork   = [RCTConvert BOOL:[source objectForKey:@"isNetwork"]];
        BOOL isAsset   = [RCTConvert BOOL:[source objectForKey:@"isAsset"]];
        NSURL* _uri    = [NSURL URLWithString:uri];
        if(uri && uri.length > 0){
            //init player && play
            if(initType == 2){
                _player = [[VLCMediaPlayer alloc] initWithOptions:options];
            }else{
                _player = [[VLCMediaPlayer alloc] init];
            }
            [_player setDrawable:self];
            _player.delegate = self;
            _player.scaleFactor = 0;
            if(_playBackRate) {
                [self setRate:_playBackRate];
            }
            //Set how many milliseconds to cache
            // [mediaDictonary setObject:@"1500" forKey:@"network-caching"];
            //            [mediaOptions setObject:@20 forKey:@"dshow-fps"];
            //[mediaOptions setObject:<#(nonnull id)#> forKey:VLCMediaTracksInformationBitrate]
            VLCMedia *media = nil;
            if(isNetWork || isAsset){
                media = [VLCMedia mediaWithURL:_uri];
            }else{
                media = [VLCMedia mediaWithPath: uri];
            }
            if(media){
                media.delegate = self;
                //                [mediaOptions setObject:@20.0 forKey:VLCMediaTracksInformationFrameRate];
                
                if(mediaOptions){
                    [media addOptions:mediaOptions];
                }
                [media parseWithOptions:VLCMediaParseLocal|VLCMediaFetchLocal|VLCMediaParseNetwork|VLCMediaFetchNetwork];
                _player.media = media;
            }
            if(autoplay)
                [self play];
            if(self.onVideoLoadStart){
                self.onVideoLoadStart(@{
                                        @"target": self.reactTag
                                        });
            }
        }
    }
    @catch(NSException *exception){
        NSLog(@"%@", exception);
    }
}

- (void)mediaPlayerSnapshot:(NSNotification *)aNotification{
    NSLog(@"userInfo %@",[aNotification userInfo]);
    self.onSnapshot(@{
                      @"target": self.reactTag,
                      @"success": [NSNumber numberWithInt:1],
                      });
}


- (void)mediaMetaDataDidChange:(VLCMedia *)aMedia{
    NSLog(@"mediaMetaDataDidChange");
    NSInteger readBytes = aMedia.numberOfReadBytesOnInput;
    NSLog(@"readBytes %zd", readBytes);
    BOOL isPlaying = _player.isPlaying;
    BOOL hasVideoOut = _player.hasVideoOut;
    self.onVideoStateChange(@{
                              @"target": self.reactTag,
                              @"isPlaying": [NSNumber numberWithBool: isPlaying],
                              @"hasVideoOut": [NSNumber numberWithBool: hasVideoOut],
                              @"type": @"mediaMetaDataDidChange",
                              });
}

- (void)mediaDidFinishParsing:(VLCMedia *)aMedia
{
    NSLog(@"mediaDidFinishParsing");
    BOOL isPlaying = _player.isPlaying;
    BOOL hasVideoOut = _player.hasVideoOut;
    self.onVideoStateChange(@{
                              @"target": self.reactTag,
                              @"isPlaying": [NSNumber numberWithBool: isPlaying],
                              @"hasVideoOut": [NSNumber numberWithBool: hasVideoOut],
                              @"type": @"mediaDidFinishParsing",
                              });
    //NSLog(@"readBytes %zd", readBytes);
}

- (void)mediaPlayerTimeChanged:(NSNotification *)aNotification
{
    if (!_loaded) {
        [self sendOnLoadEvent];
    }
    [self updateVideoProgress:0];
    
    [self removePlayerTimeObserver];
    [self addPlayerTimeObserver];
}

- (void)mediaPlayerStateChanged:(NSNotification *)aNotification
{
    @try{
        if(_player){
            
            BOOL isPlaying = _player.isPlaying;
            BOOL hasVideoOut = _player.hasVideoOut;
            /*NSInteger numberOfReadBytesOnInput = _player.media.numberOfReadBytesOnInput;
             NSInteger numberOfPlayedAudioBuffers =  _player.media.numberOfPlayedAudioBuffers;
             NSInteger numberOfSentBytes = _player.media.numberOfSentBytes;
             NSInteger numberOfReadBytesOnDemux =  _player.media.numberOfReadBytesOnDemux;
             NSInteger numberOfSentPackets =  _player.media.numberOfSentPackets;
             NSInteger numberOfCorruptedDataPackets =  _player.media.numberOfCorruptedDataPackets;
             NSInteger numberOfDisplayedPictures =  _player.media.numberOfDisplayedPictures;
             NSInteger numberOfDecodedVideoBlocks =  _player.media.numberOfDecodedVideoBlocks;
             */
            /*self.onIsPlaying(@{
             @"target": self.reactTag,
             @"isPlaying": [NSNumber numberWithBool: isPlaying],
             @"numberOfReadBytesOnInput":[NSNumber numberWithInteger:numberOfReadBytesOnInput],
             @"numberOfPlayedAudioBuffers":[NSNumber numberWithInteger:numberOfPlayedAudioBuffers],
             @"numberOfSentBytes":[NSNumber numberWithInteger:numberOfSentBytes],
             @"numberOfReadBytesOnDemux":[NSNumber numberWithInteger:numberOfReadBytesOnDemux],
             @"numberOfSentPackets":[NSNumber numberWithInteger:numberOfSentPackets],
             @"numberOfCorruptedDataPackets":[NSNumber numberWithInteger:numberOfCorruptedDataPackets],
             @"numberOfDisplayedPictures":[NSNumber numberWithInteger:numberOfDisplayedPictures],
             @"numberOfDecodedVideoBlocks":[NSNumber numberWithInteger:numberOfDecodedVideoBlocks],
             });
             */
            VLCMediaPlayerState state = _player.state;
            CGSize videoSize =  _player.videoSize;
            int height = videoSize.height;
            int width = videoSize.width;
            BOOL willPlay = _player.willPlay;
            switch (state) {
                case VLCMediaPlayerStateOpening:
                    self.onVideoStateChange(@{
                                              @"target": self.reactTag,
                                              @"isPlaying": [NSNumber numberWithBool: isPlaying],
                                              @"hasVideoOut": [NSNumber numberWithBool: hasVideoOut],
                                              @"type": @"Opening",
                                              @"videoWidth":[NSNumber numberWithInt:width],
                                              @"videoHeight":[NSNumber numberWithInt:height],
                                              @"willPlay":[NSNumber numberWithBool:willPlay],
                                              });
                    break;
                case VLCMediaPlayerStatePaused:
                    _paused = YES;
                    self.onVideoStateChange(@{
                                              @"target": self.reactTag,
                                              @"isPlaying": [NSNumber numberWithBool: isPlaying],
                                              @"hasVideoOut": [NSNumber numberWithBool: hasVideoOut],
                                              @"type": @"Paused",
                                              @"videoWidth":[NSNumber numberWithInt:width],
                                              @"videoHeight":[NSNumber numberWithInt:height],
                                              @"willPlay":[NSNumber numberWithBool:willPlay],
                                              });
                    break;
                case VLCMediaPlayerStateStopped:
                    self.onVideoStateChange(@{
                                              @"target": self.reactTag,
                                              @"isPlaying": [NSNumber numberWithBool: isPlaying],
                                              @"hasVideoOut": [NSNumber numberWithBool: hasVideoOut],
                                              @"type": @"Stopped",
                                              @"videoWidth":[NSNumber numberWithInt:width],
                                              @"videoHeight":[NSNumber numberWithInt:height],
                                              @"willPlay":[NSNumber numberWithBool:willPlay],
                                              });
                    break;
                case VLCMediaPlayerStateBuffering:
                    self.onVideoStateChange(@{
                                              @"target": self.reactTag,
                                              @"isPlaying": [NSNumber numberWithBool: isPlaying],
                                              @"duration": [self getDuration:_player.media.length],
                                              @"hasVideoOut": [NSNumber numberWithBool: hasVideoOut],
                                              @"type": @"Buffering",
                                              @"videoWidth":[NSNumber numberWithInt:width],
                                              @"videoHeight":[NSNumber numberWithInt:height],
                                              @"willPlay":[NSNumber numberWithBool:willPlay],
                                              });
                    break;
                case VLCMediaPlayerStatePlaying:
                    _paused = NO;
                    self.onVideoStateChange(@{
                                              @"target": self.reactTag,
                                              @"isPlaying": [NSNumber numberWithBool: isPlaying],
                                              @"duration": [self getDuration:_player.media.length],
                                              @"hasVideoOut": [NSNumber numberWithBool: hasVideoOut],
                                              @"isPlaying": [NSNumber numberWithBool: isPlaying],
                                              @"type": @"Playing",
                                              @"videoWidth":[NSNumber numberWithInt:width],
                                              @"videoHeight":[NSNumber numberWithInt:height],
                                              @"willPlay":[NSNumber numberWithBool:willPlay],
                                              });
                    break;
                case VLCMediaPlayerStateESAdded:
                    self.onVideoStateChange(@{
                                              @"target": self.reactTag,
                                              @"duration": [self getDuration:_player.media.length],
                                              @"isPlaying": [NSNumber numberWithBool: isPlaying],
                                              @"hasVideoOut": [NSNumber numberWithBool: hasVideoOut],
                                              @"type": @"ESAdded",
                                              @"videoWidth":[NSNumber numberWithInt:width],
                                              @"videoHeight":[NSNumber numberWithInt:height],
                                              @"willPlay":[NSNumber numberWithBool:willPlay],
                                              });
                    break;
                case VLCMediaPlayerStateEnded:
                    self.onVideoStateChange(@{
                                              @"target": self.reactTag,
                                              @"type": @"Ended",
                                              @"currentTime": [self getDuration:[_player time]],
                                              @"remainingTime": [self getDuration:[_player remainingTime]],
                                              @"duration":[self getDuration:_player.media.length],
                                              @"position":[NSNumber numberWithFloat:_player.position],
                                              @"isPlaying": [NSNumber numberWithBool: isPlaying],
                                              @"hasVideoOut": [NSNumber numberWithBool: hasVideoOut],
                                              @"videoWidth":[NSNumber numberWithInt:width],
                                              @"videoHeight":[NSNumber numberWithInt:height],
                                              @"willPlay":[NSNumber numberWithBool:willPlay],
                                              });
                    break;
                case VLCMediaPlayerStateError:
                    self.onVideoStateChange(@{
                                              @"target": self.reactTag,
                                              @"duration": [self getDuration:_player.media.length],
                                              @"isPlaying": [NSNumber numberWithBool: isPlaying],
                                              @"hasVideoOut": [NSNumber numberWithBool: hasVideoOut],
                                              @"type": @"Error",
                                              @"videoWidth":[NSNumber numberWithInt:width],
                                              @"videoHeight":[NSNumber numberWithInt:height],
                                              @"willPlay":[NSNumber numberWithBool:willPlay],
                                              });
                    [self _release];
                    break;
                default:
                    self.onVideoStateChange(@{
                                              @"target": self.reactTag,
                                              @"duration": [self getDuration:_player.media.length],
                                              @"isPlaying": [NSNumber numberWithBool: isPlaying],
                                              @"hasVideoOut": [NSNumber numberWithBool: hasVideoOut],
                                              @"type": [NSString stringWithCString:state encoding:(NSASCIIStringEncoding)],
                                              @"videoWidth":[NSNumber numberWithInt:width],
                                              @"videoHeight":[NSNumber numberWithInt:height],
                                              @"willPlay":[NSNumber numberWithBool:willPlay],
                                              });
                    break;
            }
        }
    }@catch(NSException *exception){
        NSLog(@"%@", exception);
    }
}

-(NSNumber *)getDuration:(VLCTime *)length
{
    float videoFloatLength = [[length value] floatValue] / 1000.0f;
    return [NSNumber numberWithFloat:videoFloatLength];
}

-(void)sendOnLoadEvent
{
    @try{
        if(_player){
            if(!_loaded) {
                _loaded = true;
                self.onVideoStateChange(@{
                                          @"target": self.reactTag,
                                          @"type": @"onLoad",
                                          @"currentTime": [self getDuration:[_player time]],
                                          @"remainingTime": [self getDuration:[_player remainingTime]],
                                          @"duration":[self getDuration:_player.media.length],
                                          @"position":[NSNumber numberWithFloat:_player.position],
                                          @"isPlaying": [NSNumber numberWithBool: _player.isPlaying],
                                          });
            }
        }
    }
    @catch(NSException *exception){
        NSLog(@"%@", exception);
    }
}

-(void)addPlayerTimeObserver
{
    _progressAddonTime = 0;
    _timeObserver = [NSTimer scheduledTimerWithTimeInterval:(_progressUpdateInterval / 1000) target:self selector:@selector(handleAddonTimeUpdate) userInfo:nil repeats:true];
}

-(void)removePlayerTimeObserver
{
    if (_timeObserver) {
        [_timeObserver invalidate];
        _timeObserver = nil;
    }
}

-(void)handleAddonTimeUpdate {
    _progressAddonTime += _progressUpdateInterval;
    [self updateVideoProgress:_progressAddonTime];
}

-(void)updateVideoProgress: (float)addOnTime
{   @try{
    if(_player){
        int currentTime   = [[_player time] intValue];
        int duration      = [_player.media.length intValue];
        VLCTime *currentTimeWithAddOn = [VLCTime timeWithInt:(currentTime + (int)addOnTime)] ;
        
        if( currentTime >= 0 && currentTime < duration) {
            self.onVideoProgress(@{
                                   @"target": self.reactTag,
                                   @"currentTime": [self getDuration: currentTimeWithAddOn],
                                   @"remainingTime": [self getDuration:[_player remainingTime]],
                                   @"duration":[self getDuration:_player.media.length],
                                   @"position":[NSNumber numberWithFloat:_player.position],
                                   @"isPlaying": [NSNumber numberWithBool: _player.isPlaying],
                                   });
        }
    }
}
    @catch(NSException *exception){
        NSLog(@"%@", exception);
    }
}

- (void)jumpBackward:(int)interval
{
    if(interval>=0 && interval <= [_player.media.length intValue])
        [_player jumpBackward:interval];
}

- (void)jumpForward:(int)interval
{
    if(interval>=0 && interval <= [_player.media.length intValue])
        [_player jumpForward:interval];
}

/**
 * audio  -----> start
 */
- (void)setMuted:(BOOL)muted
{
    if(_player){
        VLCAudio *audio = _player.audio;
        [audio setMuted: muted];
    }
}

-(void)setVolume:(int)interval
{
    if(_player){
        VLCAudio *audio = _player.audio;
        if(interval >= 0){
            audio.volume = interval;
        }
    }
}

-(void)setVolumeDown:(int)volume
{
    if(_player){
        
        VLCAudio *audio = _player.audio;
        [audio volumeDown];
    }
}



-(void)setVolumeUp:(int)volume
{
    if(_player){
        VLCAudio *audio = _player.audio;
        [audio volumeUp];
    }
}

//audio  -----> end


-(void)setSeek:(float)pos
{
    if(_player != nil && [_player isSeekable]){
        if(pos>=0 && pos <= 1){
            [_player setPosition:pos];
        }
    }
}

-(void)setSeekTime:(float)seekTime{
    if(_player != nil && [_player isSeekable]){
        // Convert seekTime in ms before changing in VLCTime
        VLCTime *time = [VLCTime timeWithNumber:[NSNumber numberWithFloat:(seekTime * 1000)]];
        [_player setTime:time];
        
        [self setPaused:_paused];
        [self updateVideoProgress: 0];
    }
}

-(void)setProgressUpdateInterval:(float)progressUpdateInterval
{
    _progressUpdateInterval = progressUpdateInterval;
}

-(void)setSnapshotPath:(NSString*)path
{
    if(_player)
        [_player saveVideoSnapshotAt:path withWidth:0 andHeight:0];
}

-(void)setRate:(float)rate
{
    _playBackRate = rate;
    [_player setRate:rate];
}

-(void)setClear:(float)clear
{
    [self _release];
}


-(void)setVideoAspectRatio:(NSString *)ratio{
    if(ratio != nil && ratio.length > 0){
        char *char_content = [ratio cStringUsingEncoding:NSASCIIStringEncoding];
        [_player setVideoAspectRatio:char_content];
    }
}

- (void)_release
{
    if(_player){
        [_player stop];
        _player = nil;
        _eventDispatcher = nil;
    }
    [self removePlayerTimeObserver];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)dealloc{
    [self _release];
}
#pragma mark - Lifecycle

//- (void)willMoveToSuperview:(UIView *)newSuperview
//- (void)didMoveToSuperview

//- (void)willRemoveSubview:(UIView *)subview


- (void)removeFromSuperview
{
    NSLog(@"removeFromSuperview");
    [self _release];
    [super removeFromSuperview];
}

@end
