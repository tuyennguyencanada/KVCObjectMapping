//
//  AppDelegate.h
//  KVCObjectMapping
//
//  Created by Tuyen Nguyen on 12-11-07.
//  Copyright (c) 2012 SiliconSpots. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RootViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>

@property(nonatomic, strong) UITableView *tblObjectMapping;
@property(nonatomic, strong) NSArray *displayText;
@end

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) RootViewController *vcRoot;

@end
