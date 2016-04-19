//
//  ViewController.m
//  ScalableCover
//
//  Created by Amay on 4/18/16.
//  Copyright © 2016 Beddup. All rights reserved.
//

#import "ViewController.h"
#import "UIScrollView+ScalabelCover.h"
@interface ViewController ()
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.scrollView.contentSize = CGSizeMake(CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds) );
    [self.scrollView addScalableCoverWithImage:[UIImage imageNamed:@"user-background-320"]];

    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
