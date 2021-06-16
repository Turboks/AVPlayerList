//
//  Movie.h
//  AVPlayerList
//
//  Created by Turboks on 2021/4/9.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Movie : NSObject
@property (nonatomic, copy) NSString *mp4_url;
@property (nonatomic, copy) NSString *cover;
@property (nonatomic, assign) float  time;
@end

NS_ASSUME_NONNULL_END
