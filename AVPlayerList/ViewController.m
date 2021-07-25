//
//  ViewController.m
//  AVPlayerList
//
//  Created by Turboks on 2021/4/9.
//
#import "ViewController.h"
#import <AVKit/AVKit.h>
#import <AVFoundation/AVFoundation.h>
#import <AFNetworking/AFNetworking.h>
#import <AFNetworking/AFHTTPSessionManager.h>
//#import <SVProgressHUD/SVProgressHUD.h>
//#import <SDWebImage/UIImageView+WebCache.h>
#import "Movie.h"

@interface ViewController ()<UITableViewDelegate,UITableViewDataSource>
{
    NSInteger indexNum;
    NSInteger oldNum;
    NSInteger oldY;
    NSInteger screenHeight;
    NSURL * videoUrl;
    BOOL isPlaying;
}
@property (nonatomic, strong) UITableView * tableview;
@property (nonatomic, strong) NSMutableArray * arr;
@property (nonatomic, strong) AVPlayer * avplayer;
@property (nonatomic, strong) AVPlayerItem * avPlayerItem;
@property (nonatomic, strong) AVPlayerLayer * avView;
@property (nonatomic, strong) NSMutableArray<AVPlayerItem *> * itemArr;
@property (nonatomic, strong) UIImageView * imageV;
@end

@implementation ViewController

- (UIImageView *)imageV{
    if (!_imageV) {
        _imageV = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
    }
    return _imageV;
}
- (AVPlayerItem *)avPlayerItem{
    if (!_avPlayerItem) {
        Movie * mo = self.arr[indexNum];
        _avPlayerItem = [[AVPlayerItem alloc] initWithURL:[NSURL URLWithString:mo.mp4_url]];
        [_avPlayerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
    }
    return _avPlayerItem;
}
- (AVPlayerLayer *)avView{
    if (!_avView) {
        _avView = [AVPlayerLayer playerLayerWithPlayer:self.avplayer];
        _avView.frame = CGRectMake(0, 0, self.view.bounds.size.width, screenHeight);
        _avView.videoGravity = AVLayerVideoGravityResizeAspectFill;
    }
    return _avView;
}
- (AVPlayer *)avplayer{
    if (!_avplayer) {
        _avplayer = [[AVPlayer alloc] initWithPlayerItem:self.avPlayerItem];
    }
    return _avplayer;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    
    self.arr = [[NSMutableArray alloc] init];
    self.itemArr = [[NSMutableArray alloc] init];
    
    _imageV = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
    
    indexNum = 0;
    oldNum = 0;
    oldY = 0;
    screenHeight = self.view.bounds.size.height;
    isPlaying = YES;
    
    _tableview = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, screenHeight)];
    _tableview.dataSource = self;
    _tableview.delegate = self;
    //开启分页滑动
    _tableview.pagingEnabled = YES;
    _tableview.estimatedRowHeight = 0;
    _tableview.estimatedSectionFooterHeight = 0;
    _tableview.estimatedSectionHeaderHeight = 0;
    if (@available(iOS 11.0, *)) {
        [_tableview setContentInsetAdjustmentBehavior:UIScrollViewContentInsetAdjustmentNever];
    }
    [self.view addSubview:_tableview];
    
    [self getdata];
}
-(void)getdata{
    NSString *urlString = @"http://c.m.163.com/nc/video/list/V9LG4B3A0/y/1-20.html";
    AFHTTPSessionManager  *manager = [AFHTTPSessionManager manager];
    [manager GET:urlString parameters:nil headers:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"获取到数据了");
        NSArray *arr = responseObject[@"V9LG4B3A0"];
        for (int i = 0; i < 5; i++) {
            NSDictionary * dic = arr[i];
            Movie *mo = [[Movie alloc]init];
            [mo setValuesForKeysWithDictionary:dic];
            [self.arr addObject:mo];
            AVPlayerItem * item = [[AVPlayerItem alloc] initWithURL:[NSURL URLWithString:mo.mp4_url]];
            [self.itemArr addObject:item];
        }
        [self.tableview reloadData];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"请求失败");
    }];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _arr.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return screenHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
//    cell.backgroundColor = [UIColor whiteColor];
    //    Movie * mo = _arr[indexPath.row];
    if (indexPath.row == indexNum) {
        [cell.layer addSublayer:self.avView];
    }
    else{
        [cell addSubview:self.imageV];
        //        self.imageV.image = [self getVideoFirstViewImage:[NSURL URLWithString:mo.cover]];
        self.imageV.image = [UIImage imageNamed:@"video"];
    }
    return cell;
}
// 获取视频第一帧图片
//- (UIImage*)getVideoFirstViewImage:(NSURL *)path {
//    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:path options:nil];
//    AVAssetImageGenerator *assetGen = [[AVAssetImageGenerator alloc] initWithAsset:asset];
//
//    assetGen.appliesPreferredTrackTransform = YES;
//    CMTime time = CMTimeMakeWithSeconds(0.0, 600);
//    NSError *error = nil;
//    CMTime actualTime;
//    CGImageRef image = [assetGen copyCGImageAtTime:time actualTime:&actualTime error:&error];
//    UIImage *videoImage = [[UIImage alloc] initWithCGImage:image];
//    CGImageRelease(image);
//    return videoImage;
//}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if (fabs(scrollView.contentOffset.y - oldY) > screenHeight) {
        if (_avplayer != nil) {
            NSLog(@"暂停");
            [self.avplayer pause];
            [self.avPlayerItem removeObserver:self forKeyPath:@"status"];
            [self.avView removeFromSuperlayer];
            self.avplayer = nil;
            self.avView = nil;
            self.avPlayerItem = nil;
        }
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    BOOL scrollToScrollStop = !scrollView.tracking && !scrollView.dragging && !scrollView.decelerating;
    if (scrollToScrollStop) {
        [self scrollViewDidEndScroll:scrollView.contentOffset.y];
    }
}
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (!decelerate) {
        BOOL dragToDragStop = scrollView.tracking && !scrollView.dragging && !scrollView.decelerating;
        if (dragToDragStop) {
            [self scrollViewDidEndScroll:scrollView.contentOffset.y];
        }
    }
}

#pragma mark - scrollView 滚动停止
- (void)scrollViewDidEndScroll:(NSInteger)y {
    NSArray * array = [_tableview visibleCells];
    NSLog(@" ----- %@",array);
    UITableViewCell * cell = array[0];
    indexNum = [_tableview indexPathForCell:cell].row;
    if (indexNum == oldNum) {
        return;
    }
    oldNum = indexNum;
    oldY = indexNum * screenHeight;
    NSArray * ar = [NSArray arrayWithObjects:[_tableview indexPathForCell:cell],nil];
    //刷新单个cell
    [self.avplayer pause];
    [self.avPlayerItem removeObserver:self forKeyPath:@"status"];
    [self.avView removeFromSuperlayer];
    self.avplayer = nil;
    self.avView = nil;
    self.avPlayerItem = nil;
    [_tableview reloadRowsAtIndexPaths:ar withRowAnimation:UITableViewRowAnimationNone];
    
    //提前加载数据
    if (indexNum > self.arr.count - 3) {
        [self getdata];
    }
}
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context{
    if ([keyPath isEqualToString:@"status"]) {
        AVPlayerStatus status = [[change objectForKey:@"new"] intValue];
        switch (status) {
            case AVPlayerStatusReadyToPlay:
            {
                [self.avplayer play];
            }
                break;
            default:
                break;
        }
    }
}
@end
