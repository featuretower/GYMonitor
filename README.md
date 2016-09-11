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
![(fps低)](https://raw.githubusercontent.com/featuretower/GYMonitor/master/GYMonitorExample/Screenshots/slow.png)
![(fps卡顿)](https://github.com/featuretower/GYMonitor/blob/master/GYMonitorExample/Screenshots/stuck.png?raw=true)
![(模拟器上的堆栈)](https://github.com/featuretower/GYMonitor/blob/master/GYMonitorExample/Screenshots/stack_sim.png?raw=true)
![(反解堆栈菜单)](https://github.com/featuretower/GYMonitor/blob/master/GYMonitorExample/Screenshots/symblic.jpg?raw=true)
![(mac上反解结果)](https://github.com/featuretower/GYMonitor/blob/master/GYMonitorExample/Screenshots/stack_mac.jpg?raw=true)

## 原理
* 通过`CADisplayLink`获取屏幕刷新频率，输出FPS的值
* 在子线程开启定时器监控FPS的值
* 当FPS的值过低时，通过`CrashReporter`获取全部线程的堆栈，保存为`$currentController.crash`文件
* 编译项目成功后通过`dsymutil`产生dSYM文件然后保存，为了节省空间最多保存5个
* 在mac os使用`symbolicatecrash`反解堆栈，为了方便，我使用了`Automator`为右键点击*.crash文件时添加添加服务项`反解堆栈`


