//
//  UIScrollView+ScalabelCover.m
//  ScalableCover
//
//  Created by Amay on 4/18/16.
//  Copyright © 2016 Beddup. All rights reserved.
//

#import "UIScrollView+ScalabelCover.h"
#import <objc/runtime.h>

NSString* const BeddupScalableCoverKey = @"BeddupScalableCoverKey";
NSString* const ContentOffsetKey = @"contentOffset";
NSString* const Bounds = @"bounds";

@interface BeddupScalableCoverView : UIImageView


@end

@implementation BeddupScalableCoverView

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.clipsToBounds = YES;
        self.contentMode = UIViewContentModeScaleAspectFill;
    }
    return self;
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context{

    UIScrollView* scrollView = (UIScrollView*) object;

    if ([keyPath isEqualToString:Bounds] ) {
        CGRect bounds = [change[NSKeyValueChangeNewKey] CGRectValue];
        if (CGRectGetWidth(bounds) != CGRectGetWidth(self.frame)) {
            self.frame = CGRectMake(scrollView.contentOffset.x, scrollView.contentOffset.y, CGRectGetWidth(scrollView.bounds), self.image.size.height / self.image.size.width * CGRectGetWidth(scrollView.bounds));
        }
    }

    if ([keyPath isEqualToString:ContentOffsetKey]) {
        CGPoint offset = [change[NSKeyValueChangeNewKey] CGPointValue];
        if (offset.y <= 0) {

            self.frame = CGRectMake(offset.x, offset.y, CGRectGetWidth(scrollView.bounds), self.image.size.height / self.image.size.width * CGRectGetWidth(self.bounds) - offset.y);
            CGFloat ratio =  - offset.y / CGRectGetHeight(scrollView.bounds);
            self.layer.contentsRect = CGRectMake(0.1 + ratio / 2, 0.1, 0.8 - ratio, 0.8 - ratio);
        }else if (offset.y > scrollView.contentSize.height - CGRectGetHeight(scrollView.bounds)){

            self.frame = CGRectMake(offset.x, CGRectGetMinY(self.frame), CGRectGetWidth(self.frame), CGRectGetHeight(self.frame));
            CGFloat ratio = (offset.y - (scrollView.contentSize.height - CGRectGetHeight(scrollView.bounds)))  / CGRectGetHeight(scrollView.bounds);
            self.layer.contentsRect = CGRectMake(0.1 - ratio / 2 > 0 ? 0.1 - ratio / 2 : 0.0, 0.1, 0.8 + ratio > 1.0 ? 1.0 : 0.8 + ratio, 0.8 + ratio > 1.0 ? 1.0 : 0.8 + ratio);
        }
    }
}

-(void)removeFromSuperview{

    [self.superview removeObserver:self forKeyPath:ContentOffsetKey];
    [self.superview removeObserver:self forKeyPath:Bounds];

}

@end

@implementation UIScrollView (ScalabelCover)

-(void)addScalableCoverWithImage:(UIImage *)coverImage{

    BeddupScalableCoverView* cover = objc_getAssociatedObject(self, &BeddupScalableCoverKey);

    if (cover != nil) {
        // 如果已经有了cover image view， 则变更其image，重设其frame
        cover.image = coverImage;

        cover.frame = CGRectMake(self.contentOffset.x, self.contentOffset.y, CGRectGetWidth(self.bounds), coverImage.size.height / coverImage.size.width * CGRectGetWidth(self.bounds));
        cover.layer.contentsRect = CGRectMake(0.1, 0.1, 0.8, 0.8);
        [self sendSubviewToBack:cover];
    }else{

        cover = [[BeddupScalableCoverView alloc]initWithFrame:CGRectMake(self.contentOffset.x, self.contentOffset.y, CGRectGetWidth(self.bounds), coverImage.size.height / coverImage.size.width * CGRectGetWidth(self.bounds))];
        cover.image = coverImage;
        [self addSubview:cover];
        [self sendSubviewToBack:cover];
        objc_setAssociatedObject(self, &BeddupScalableCoverKey, cover, OBJC_ASSOCIATION_ASSIGN);
        [self addObserver:cover forKeyPath:ContentOffsetKey options:NSKeyValueObservingOptionNew context:nil];
        [self addObserver:cover forKeyPath:Bounds options:NSKeyValueObservingOptionNew context:nil];
    }
}
-(void)removeScalableCover{
    // 实际上并没有移除，只是将image 设置为nil；如果介意保留imageview带来的开销，可在这里将imageView移除，清除AssociatedObject并移除panGesture对应的tagert 和action
    BeddupScalableCoverView* cover = objc_getAssociatedObject(self, &BeddupScalableCoverKey);
    cover.image = nil;
}


@end
