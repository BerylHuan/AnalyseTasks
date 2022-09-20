//
//  ViewController.m
//  AnalyseTasks
//
//  Created by 宁丽环 on 2022/9/7.
//

#import "ViewController.h"
#import <AudioToolbox/AudioToolbox.h>
#import "SettingViewController.h"
#define WeakSelf __typeof(self) weakSelf = self;

#define kWidth ([UIScreen mainScreen].bounds.size.width - 40)
#define kHeight [UIScreen mainScreen].bounds.size.height
#define kCount 4
#define LogFile [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"logfile"]

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UIView *backgroundView;
@property (weak, nonatomic) IBOutlet UITextView *myTextView;
@property (nonatomic,assign)BOOL batteryState;//充电状态
@property (nonatomic,assign)CGFloat lowBattery;//最低电量（默认为60);
@property (nonatomic,assign)CGFloat lagerBattery;//最低电量（默认为98);


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //解归档
    //读取文件的内容
    NSData *data = [NSData dataWithContentsOfFile:LogFile];
    //将二进制数据转化为对应的对象类型
    NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"%@", str);
    self.myTextView.text = str;
    self.lowBattery = 60;
    self.lagerBattery = 98;
    [self checkAndMonitorBatteryState];
    [self checkAndMonitorBatteryLevel];
    
}


#pragma mark - 电池状态获取及监控
- (void)checkAndMonitorBatteryState{
    UIDevice *device = [UIDevice currentDevice];
    device.batteryMonitoringEnabled = true;
    UIDeviceBatteryState state = device.batteryState;
    NSArray *stateArray = [NSArray arrayWithObjects:@"未开启监视电池状态",@"电池未充电状态",@"电池充电状态",@"电池充电完成" ,nil];
    NSLog(@"电池状态：%@", [stateArray objectAtIndex:state]);
    if (state == 1){
        self.batteryState = NO;
    }else{
        self.batteryState = YES;
    }
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(didChangBatteryState:) name:@"UIDeviceBatteryStateDidChangeNotification" object:device];
}

-(void)didChangBatteryState:(NSNotification *)notification{
    //电池状态发生改变时调用
    UIDevice *device = notification.object;
    UIDeviceBatteryState state = device.batteryState;
    if (state == 1){
        self.batteryState = NO;
    }else{
        self.batteryState = YES;
    }
}

- (void)showCurrentBatteryWithLevel:(CGFloat)level
{
    int currntLevel = level * 100;
    NSDateFormatter *formatter = [NSDateFormatter new];
    formatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";//规定格式转化，并转化为当前系统的时间
    NSString *timestr = [formatter stringFromDate:[NSDate date]];//
    NSString *loger = [NSString stringWithFormat:@"%@      %.1f           %@             %@   \n",timestr,level*100,@"未知",self.batteryState?@"是":@"否"];
    self.myTextView.text = [loger stringByAppendingString:self.myTextView.text];
    BOOL isExist = [[NSFileManager defaultManager] fileExistsAtPath:LogFile];
    if(!isExist){
        [[NSFileManager defaultManager] createFileAtPath:LogFile contents:nil attributes:nil];
    }
    //解归档
    NSData *data = [NSData dataWithContentsOfFile:LogFile];
    //日志本地化存储
    NSData *newdata = [loger dataUsingEncoding:NSUTF8StringEncoding];
    if(data){
        NSMutableData *mutableData = [NSMutableData dataWithData:newdata];
        [mutableData appendData:data];
        [mutableData writeToFile:LogFile atomically:YES];
    }else{
        [newdata writeToFile:LogFile atomically:YES];
    }
    
    //添加震动⏰
    if(currntLevel<=self.lowBattery||currntLevel>=self.lagerBattery){
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
        AudioServicesAddSystemSoundCompletion(kSystemSoundID_Vibrate, NULL, NULL, vibrateCallback, NULL);
    }
    
}
void vibrateCallback(SystemSoundID sound,void * clientData) {
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);  //震动
}

#pragma mark - 电池电量获取及监控
-(void)checkAndMonitorBatteryLevel{
    
    //拿到当前设备
    UIDevice * device = [UIDevice currentDevice];
    
    //是否允许监测电池
    //要想获取电池电量信息和监控电池电量 必须允许
    device.batteryMonitoringEnabled = true;
    
    //1、check
    /*
     获取电池电量
     0 .. 1.0. -1.0 if UIDeviceBatteryStateUnknown
     */
    float level = device.batteryLevel;
    NSLog(@"level = %lf",level);
    
    //2、monitor
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didChangeBatteryLevel:) name:@"UIDeviceBatteryLevelDidChangeNotification" object:device];
    [self showCurrentBatteryWithLevel:level];
}

- (void)didChangeBatteryLevel:(id)sender{
    //电池电量发生改变时调用
    UIDevice *myDevice = [UIDevice currentDevice];
    [myDevice setBatteryMonitoringEnabled:YES];
    float batteryLevel = [myDevice batteryLevel];
    [self showCurrentBatteryWithLevel:batteryLevel];
    
    NSLog(@"电池剩余比例：%@", [NSString stringWithFormat:@"%f",batteryLevel*100]);
    
    
}

#pragma mark - 低电量模式切换
-(void)checkAndMonitorPowerMode{
    //1、check
    //是否处于低电量模式
    if ([[NSProcessInfo processInfo] isLowPowerModeEnabled]) {
        NSLog(@"处在低电量模式");
    }
    else{
        NSLog(@"未处于低电量模式");
    }
    
    //2、monitor
    //低电量模式切换通知
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didChangePowerMode:)
                                                 name:NSProcessInfoPowerStateDidChangeNotification
                                               object:nil];
    
}

//收到低电量通知之后调用的方法
//PS:手动设置低电量模式时，程序会回到后台，当程序从后台回到前台时就会调用该方法
- (void)didChangePowerMode:(NSNotification *)notification {
    if ([[NSProcessInfo processInfo] isLowPowerModeEnabled]) {
        NSLog(@"打开低电量模式");
    } else {
        NSLog(@"关闭低电量模式");
    }
}
- (IBAction)settingAction:(UIButton *)sender {
    NSString * storyboardName = @"Main";
    NSString * viewControllerID = @"SettingViewController";
    UIStoryboard * storyboard = [UIStoryboard storyboardWithName:storyboardName bundle:nil];
    SettingViewController * settingVC = (SettingViewController *)[storyboard instantiateViewControllerWithIdentifier:viewControllerID];
    WeakSelf
    settingVC.lowBlock = ^(CGFloat level) {
        weakSelf.lowBattery = level;
        NSLog(@"最低电量：%.0f",weakSelf.lowBattery);
    };
    settingVC.lagerBlock = ^(CGFloat level) {
        weakSelf.lagerBattery = level;
        NSLog(@"最高电量：%.0f",weakSelf.lagerBattery);
    };
    
    [self presentViewController:settingVC animated:YES completion:nil];
    
}

//点击屏幕停止震动
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    AudioServicesRemoveSystemSoundCompletion(kSystemSoundID_Vibrate);
}

- (IBAction)clearLogs:(UIButton *)sender {
    NSData *logsData = [NSData dataWithContentsOfFile:LogFile];
    if(logsData){
        [[NSFileManager defaultManager]removeItemAtPath:LogFile error:nil];
        self.myTextView.text = nil;
    }
}

@end









