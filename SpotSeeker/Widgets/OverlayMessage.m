//
//  OverlayMessage.m
//  SpaceScout
//
//  Created by Patrick Michaud on 3/12/14.
//
//

#import "OverlayMessage.h"
#import <QuartzCore/QuartzCore.h>

@implementation OverlayMessage

@synthesize overlay;

const float MAX_ALPHA = 1;

-(id) init {
    self = [super init];
    self.overlay = [[[NSBundle mainBundle] loadNibNamed:@"OverlayMessage" owner:self options:nil] objectAtIndex:0];
    self.overlay.hidden = TRUE;
    return self;
}

-(void)addTo:(UIView *)view {
    [view addSubview:self.overlay];
}

-(void)setImage:(UIImage *)image {
    [self hideActivityIndicator];
    UIImageView *img_view = (UIImageView *)[self.overlay viewWithTag:300];
    img_view.image = image;
    img_view.hidden = NO;
}

-(void)showActivityIndicator {
    UIImageView *img_view = (UIImageView *)[self.overlay viewWithTag:300];
    img_view.hidden = YES;
    
    UIActivityIndicatorView *spinner = (UIActivityIndicatorView *)[self.overlay viewWithTag:1000];
    spinner.hidden = NO;
}

-(void)hideActivityIndicator {
    UIActivityIndicatorView *spinner = (UIActivityIndicatorView *)[self.overlay viewWithTag:1000];
    spinner.hidden = YES;
}

-(void)showOverlay:(NSString *)text animateDisplay:(BOOL)animate_display afterShowBlock:(void (^)(void))showCallback {
    UIImageView *img_view = (UIImageView *)[self.overlay viewWithTag:300];
    img_view.hidden = YES;
    UITextView *label = (UITextView *)[overlay viewWithTag:100];

    UIView *panel = [self.overlay viewWithTag:200];
    UIView *background_color = [self.overlay viewWithTag:500];
    
    background_color.layer.cornerRadius = 15.0;

    [label setText:text];
    
    if (animate_display) {
        panel.alpha = 0.0;
        overlay.hidden = FALSE;

        [UIView animateWithDuration:1.0 animations:^(void) {
            panel.alpha = MAX_ALPHA;
        } completion:^(BOOL finished) {
            showCallback();
        }];
    }
    else {
        panel.alpha = MAX_ALPHA;
        overlay.hidden = FALSE;
        showCallback();
    }
    
}

-(void)hideOverlayAfterDelay:(NSTimeInterval)delay animateHide:(BOOL)animate_hide afterHideBlock:(void (^)(void))hideCallback {
    float duration = 0.0;
    if (animate_hide) {
        duration = 0.5;
    }
    
    UIView *panel = [self.overlay viewWithTag:200];
    
    [UIView animateWithDuration:duration delay:delay options:UIViewAnimationOptionCurveEaseOut animations:^(void) {
        panel.alpha = 0.0;
    } completion:^(BOOL finished) {
        if (finished) {
            overlay.hidden = TRUE;
            hideCallback();
        }
    }];

}


@end
