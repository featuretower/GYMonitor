# GYMonitor
GYMonitor是用于监控iOS app性能状况的代码库，目前包括有FPS监控，发现FPS过低会自动产生堆栈，便于在开发过程中发现卡顿问题。

## 安装
* 拖动`GYMonitor`整个文件夹到已有的Xcode工程。值得注意的是`GYMonitor`里面有`CrashReporter.framework`这个库。
* 包含头文件`#import "GYMonitor.h"`
* 将`dsymInfo`文件夹拷贝到工程文件的同一个目录，然后在工程文件中的`Build Phases`最后加上一个`Run Script`，脚本内容为`python ${PROJECT_DIR}/dsymInfo/backup.py`
![(Run Script)](https://raw.githubusercontent.com/featuretower/GYMonitor/master/GYMonitorExample/Screenshots/run_script.jpg)

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
* 在模拟器/真机（真机只能看到部分符号）

<img src="https://raw.githubusercontent.com/featuretower/GYMonitor/master/GYMonitorExample/Screenshots/slow.png" width = "30%" height = "30%" alt="fps低" align=center />
<img src="https://github.com/featuretower/GYMonitor/blob/master/GYMonitorExample/Screenshots/stuck.png?raw=true" width = "30%" height = "30%" alt="fps卡顿" align=center />
<img src="https://github.com/featuretower/GYMonitor/blob/master/GYMonitorExample/Screenshots/stack_sim.png?raw=true" width = "30%" height = "30%" alt="模拟器上的堆栈" align=center />

* 在mac上反解

![(反解堆栈菜单)](https://github.com/featuretower/GYMonitor/blob/master/GYMonitorExample/Screenshots/symblic.jpg?raw=true)
![(mac上反解结果)](https://github.com/featuretower/GYMonitor/blob/master/GYMonitorExample/Screenshots/stack_mac.jpg?raw=true)

## 原理
* 通过`CADisplayLink`获取屏幕刷新频率，输出FPS的值
* 在子线程开启定时器监控FPS的值
* 当FPS的值过低时，通过`CrashReporter`获取全部线程的堆栈，保存为`$currentController.crash`文件
* 编译项目成功后通过`dsymutil`产生dSYM文件然后保存，为了节省空间最多保存5个。还有为它们在所的目录添加Spotlight索引，反解堆栈时能让mac os自动找到它们
* 在手机可通过点击监控条，然后用AirDrop把crash文件传输到mac上，在mac使用`symbolicatecrash`反解堆栈，为了方便，我使用了`Automator`为右键点击*.crash文件时添加服务项`反解堆栈`，点击后会运行脚本去反解堆栈。


