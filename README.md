# GYMonitor
GYMonitor是用于监控iOS app性能状况的代码库，目前包括有FPS监控，发现FPS过低会自动产生堆栈，便于在开发过程中发现卡顿问题。

## 安装
* 拖动`GYMonitor`整个文件夹到已有的Xcode工程。值得注意的是`GYMonitor`里面有`CrashReporter.framework`这个库。
* 包含头文件`#import "GYMonitor.h"`
* 将`dsymInfo`文件夹拷贝到工程文件的同一个目录，然后在工程文件中的`Build Phases`最后加上一个`Run Script`，脚本内容为`python ${PROJECT_DIR}/dsymInfo/backup.py`
![(Run Script)](https://github.com/featuretower/GYMonitor/tree/master/GYMonitorExample/Screenshots/run_script.jpg)

## 使用
```objc
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    // normal code...
    
    [self startMonitor];
    
    return YES;
}

- (void)startMonitor {
    [GYMonitor sharedInstance].monitorFPS = YES;
    [GYMonitor sharedInstance].showDebugView = YES;
    [[GYMonitor sharedInstance] startMonitor];
}

- (void)stopMonitor {
    [GYMonitor sharedInstance].monitorFPS = NO;
    [GYMonitor sharedInstance].showDebugView = NO;
    [[GYMonitor sharedInstance] startMonitor];
}
```

## 运行效果
![(fps低)](https://github.com/featuretower/GYMonitor/tree/master/GYMonitorExample/Screenshots/slow.png)
![(fps卡顿)](https://github.com/featuretower/GYMonitor/tree/master/GYMonitorExample/Screenshots/stuck.png)
![(模拟器上的堆栈)](https://github.com/featuretower/GYMonitor/tree/master/GYMonitorExample/Screenshots/stack_sim.png)
![(反解堆栈菜单)](https://github.com/featuretower/GYMonitor/tree/master/GYMonitorExample/Screenshots/symblic.jpg)
![(mac上反解结果)](https://github.com/featuretower/GYMonitor/tree/master/GYMonitorExample/Screenshots/stack_mac.jpg)


