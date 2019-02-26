//
//  ImageVC.m
//  RunLoop刷新图片
//
//  Created by yy on 2019/2/26.
//  Copyright © 2019年 1. All rights reserved.
//

#import "ImageVC.h"

static CFRunLoopObserverRef defaultModeObserver;
CFRunLoopRef runLoop;
//定义一个block
typedef void(^RunLoopBlock)(void);
static NSString *IDENTIFIER = @"IDENTIFIER";
static CGFloat CELL_HEIGHT = 135.f;

@interface ImageVC ()<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *exampleTableView;
//定义timer 是为了让RunLoop 一直跑 不消耗性能 因为timer方法里面 不 做任务处理
@property (nonatomic, strong) NSTimer *timer;
//装任务的数组
@property (nonatomic, strong) NSMutableArray *tasks;
//最大任务数
@property (nonatomic, assign) NSUInteger maxCount;




@end

@implementation ImageVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.exampleTableView = [[UITableView alloc]initWithFrame:self.view.bounds style:UITableViewStylePlain];
    self.exampleTableView.delegate = self;
    self.exampleTableView.dataSource = self;
    [self.view addSubview:self.exampleTableView];
    // Do any additional setup after loading the view, typically from a nib.
    _maxCount = 100;
    _tasks = [NSMutableArray array];
    [self.exampleTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:IDENTIFIER];
    [self addRunLoopObserver];
    _timer = [NSTimer scheduledTimerWithTimeInterval:0.001 target:self selector:@selector(_timerFiredMethod:) userInfo:nil repeats:YES];
    [self.exampleTableView reloadData];
}
- (void)_timerFiredMethod:(NSTimer *)timer {
    //We do nothing here
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark ---- 创建RunLoop
- (void)addTask:(RunLoopBlock)unit{
    [self.tasks addObject:unit];
    if (self.tasks.count > _maxCount) {
        //如果 tasks 大于 最大数  删除 第一个任务
        [self.tasks removeObjectAtIndex:0];
    }
}
static void CallBack(CFRunLoopObserverRef observer, CFRunLoopActivity activity, void *info){
    
    NSLog(@"打印一次");
    
    //数组里面取任务 怎么拿到数组  直接self.tasks 拿不到 得从  context 里面取
    ImageVC * vc = (__bridge ImageVC *)info;
    if (vc.tasks.count == 0) {
        //没任务 出去
        return;
    }
    
    RunLoopBlock task = vc.tasks.firstObject;
    task();
    [vc.tasks removeObjectAtIndex:0];
}
- (void)addRunLoopObserver{
    //拿到当前的RunLoop  CFRunLoopObserverRef 指针 有create 就得release
     runLoop = CFRunLoopGetCurrent();
    //定义一个上下文
    CFRunLoopObserverContext context = {
        0,
        (__bridge void *)(self),  //__bridge 桥接，void * 强制类型转换  把self 传过去
        &CFRetain,
        &CFRelease,
        NULL
    };
    //定义一个观察者
    defaultModeObserver = CFRunLoopObserverCreate(NULL, kCFRunLoopAfterWaiting, YES, 0, &CallBack, &context);
    
    //kCFRunLoopDefaultMode 是 滚动停止后 渲染
    
    //kCFRunLoopCommonModes 是 边滚动 边渲染
    
    CFRunLoopAddObserver(runLoop, defaultModeObserver, kCFRunLoopCommonModes);
//    CFRelease(defaultModeObserver);
}

#pragma mark --- delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 399;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:IDENTIFIER];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    for (NSInteger i = 1; i <= 5; i++) {
        [[cell.contentView viewWithTag:i] removeFromSuperview];
    }
    [ImageVC task_1:cell];
    [self addTask:^{
        [ImageVC task_2:cell];
    }];
    [self addTask:^{
        [ImageVC task_3:cell];
    }];
    [self addTask:^{
        [ImageVC task_4:cell];
    }];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return CELL_HEIGHT;
}
+ (void)task_1:(UITableViewCell *)cell  {
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(5, 5, 300, 25)];
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor redColor];
    label.text = [NSString stringWithFormat:@"- Drawing index is top priority"];
    label.font = [UIFont boldSystemFontOfSize:13];
    label.tag = 1;
    [cell.contentView addSubview:label];
    
    
    UILabel *label2 = [[UILabel alloc] initWithFrame:CGRectMake(5, 99, 300, 35)];
    label2.lineBreakMode = NSLineBreakByWordWrapping;
    label2.numberOfLines = 0;
    label2.backgroundColor = [UIColor clearColor];
    label2.textColor = [UIColor colorWithRed:0 green:100.f/255.f blue:0 alpha:1];
    label2.text = [NSString stringWithFormat:@" - Drawing large image is low priority. Should be distributed into different run loop passes."];
    label2.font = [UIFont boldSystemFontOfSize:13];
    label2.tag = 4;
    [cell.contentView addSubview:label2];
}
+ (void)task_2:(UITableViewCell *)cell{
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(105, 20, 85, 85)];
    imageView.tag = 2;
    NSString *path = [[NSBundle mainBundle] pathForResource:@"spaceship" ofType:@"jpg"];
    UIImage *image = [UIImage imageWithContentsOfFile:path];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    imageView.image = image;
    [cell.contentView addSubview:imageView];
    
}

+ (void)task_3:(UITableViewCell *)cell {
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(200, 20, 85, 85)];
    imageView.tag = 3;
    NSString *path = [[NSBundle mainBundle] pathForResource:@"spaceship" ofType:@"jpg"];
    UIImage *image = [UIImage imageWithContentsOfFile:path];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    imageView.image = image;
    [cell.contentView addSubview:imageView];
}

+ (void)task_4:(UITableViewCell *)cell {
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(5, 20, 85, 85)];
    imageView.tag = 5;
    NSString *path = [[NSBundle mainBundle] pathForResource:@"spaceship" ofType:@"jpg"];
    UIImage *image = [UIImage imageWithContentsOfFile:path];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    imageView.image = image;
    [cell.contentView addSubview:imageView];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self.timer invalidate];
    self.timer = nil;
    
    CFRunLoopRemoveObserver(runLoop, defaultModeObserver, kCFRunLoopCommonModes);
    CFRelease(defaultModeObserver);
    CFRelease(runLoop);
    
    
}
- (void)dealloc
{
    NSLog(@"%s",__func__);
}
@end
