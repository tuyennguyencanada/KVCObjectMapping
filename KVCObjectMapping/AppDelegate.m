//
//  AppDelegate.m
//  KVCObjectMapping
//
//  Created by Tuyen Nguyen on 12-11-07.
//  Copyright (c) 2012 SiliconSpots. All rights reserved.
//

#import "AppDelegate.h"
#import "Person.h"

#define IS_WIDESCREEN ( fabs( ( double )[ [ UIScreen mainScreen ] bounds ].size.height - ( double )568 ) < DBL_EPSILON )

#pragma mark -
#pragma mark - AutoLayout

/***********************************************************************************************************************/
@interface UIView (AutoLayout)

- (void)applyFullExpansionWithSubview:(UIView*)subview;

@end
@implementation UIView (AutoLayout)

- (void)applyFullExpansionWithSubview:(UIView*)subview
{
    subview.translatesAutoresizingMaskIntoConstraints = FALSE;
    NSDictionary *viewsDictionary = NSDictionaryOfVariableBindings(subview);
    NSArray *constraint = nil;
    constraint = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[subview]|"
                                                         options:0
                                                         metrics:nil
                                                           views:viewsDictionary];
    [self addConstraints:constraint];
    
    constraint = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[subview]|"
                                                         options:0
                                                         metrics:nil
                                                           views:viewsDictionary];
    [self addConstraints:constraint];
}
@end

#pragma mark -
#pragma mark - RootViewController

/***********************************************************************************************************************/

@implementation RootViewController

- (void)viewDidLoad
{
    //Path to JSON text file
    NSString *personPath = [[NSBundle mainBundle] pathForResource:@"Person" ofType:@"txt"];
    //Read to NSString object
    NSString *personContent = [NSString stringWithContentsOfFile:personPath encoding:NSUTF8StringEncoding error:NULL];
    //Convert to NSDictionary
    NSDictionary *personDataDictionary = [NSJSONSerialization JSONObjectWithData:[personContent dataUsingEncoding:NSUTF8StringEncoding]
                                                                         options:NSJSONReadingMutableContainers
                                                                           error:nil];
    //Create a |person| object
    Person *person = [[Person alloc] init];
    //Populate information to |person| object
    [person setValuesForKeysWithDictionary:personDataDictionary];
    //Convert |person| object to NSDictionary and then NSData
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:[person toDictionary] options:NSJSONReadingMutableContainers error:nil];
    //Convert to NSString to display result
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];

    //Prepare data to display
    _displayText = [NSArray arrayWithObjects:personContent, [[person toDictionary] description], jsonString, nil];
    
    //Prepare table
    _tblObjectMapping = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 320, 416) style:UITableViewStyleGrouped];
    _tblObjectMapping.dataSource = self;
    _tblObjectMapping.delegate = self;
    [self.view addSubview:_tblObjectMapping];    
    if (IS_WIDESCREEN)
    {
        [self.view applyFullExpansionWithSubview:_tblObjectMapping];
    }
}


#pragma mark -
#pragma mark - UITableViewDatasource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellId = @"CellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
        cell.textLabel.font = [UIFont systemFontOfSize:15];
        cell.textLabel.lineBreakMode = UILineBreakModeWordWrap;
        cell.textLabel.numberOfLines = 0;//unlimited lines
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.textLabel.contentMode = UIViewContentModeTop;
    }
    cell.textLabel.text = _displayText[indexPath.section];
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return _displayText.count;
}

#pragma mark -
#pragma mark - UITableViewDelegate

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *result = nil;
    if (section==0) result = @"Orginal Person JSON string";
    if (section==1) result = @"Converted Person Dictionary";
    if (section==2) result = @"Converted Person JSON string";
    return result;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGSize maximumLabelSize = CGSizeMake(320,9999);
    CGSize expectedLabelSize = [_displayText[indexPath.section] sizeWithFont:[UIFont boldSystemFontOfSize:16] constrainedToSize:maximumLabelSize];
    return expectedLabelSize.height;    
}

@end

#pragma mark -
#pragma mark - AppDelegate

/***********************************************************************************************************************/
@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    _vcRoot = [[RootViewController alloc] init];
    _vcRoot.view.backgroundColor = [UIColor grayColor];
    self.window.rootViewController = _vcRoot;
    [self.window makeKeyAndVisible];

    return YES;
}
@end


