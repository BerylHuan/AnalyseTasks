//
//  AppDelegate.m
//  AnalyseTasks
//
//  Created by 宁丽环 on 2022/9/7.
//

#import "AppDelegate.h"
#import <AVFoundation/AVFoundation.h>

@interface AppDelegate ()
{
  __block  UIBackgroundTaskIdentifier background_task;
}
@property (nonatomic,strong)AVAudioPlayer *player;
@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    return YES;
}

//进入后台
- (void)applicationDidEnterBackground:(UIApplication *)application
{
    [self.player play];
}

//程序进入前台
- (void)applicationDidBecomeActive:(UIApplication *)application
{
    //后台保持app一直运作的播放器停止工作
    [self.player pause];
}


- (AVAudioPlayer *)player {
    
    if (!_player) {
        NSString *filePath = [[NSBundle mainBundle] pathForResource:@"silent"ofType:@"mp3"];
        BOOL isExist = [[NSFileManager defaultManager] fileExistsAtPath:filePath];
            if (!isExist)
            {
                return nil;
            }
        AVAudioPlayer *audioPlayer = [[AVAudioPlayer alloc] initWithData:[NSData dataWithContentsOfFile:filePath] error:nil];
        audioPlayer.numberOfLoops = NSUIntegerMax;
        _player = audioPlayer;
        _player.volume = 0.5;
        [[AVAudioSession sharedInstance] setActive:YES error:nil];                                  //后台播放设置
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
    }
    return _player;
}

@end
