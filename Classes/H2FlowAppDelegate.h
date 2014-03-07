//
//  H2FlowAppDelegate.h
//  H2Flow
//
//  Created by Tony Peng on 1/23/11.
//

#import <UIKit/UIKit.h>

@class RootViewController;

@interface H2FlowAppDelegate : NSObject <UIApplicationDelegate> {
	UIWindow			*window;
	RootViewController	*viewController;
	
	UIImageView *splashView;
}

- (void)startupAnimationDone:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context;

@property (nonatomic, retain) UIWindow *window;

@end
