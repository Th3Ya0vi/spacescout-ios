//
//  SpaceReviewsViewController.m
//  SpaceScout
//
//  Created by pmichaud on 4/1/14.
//
//

#import "SpaceReviewsViewController.h"

@implementation SpaceReviewsViewController

@synthesize reviews;
@synthesize rest;
@synthesize space;

NSString *STAR_SELECTED_IMAGE = @"star_selected";
NSString *STAR_UNSELECTED_IMAGE = @"star_unselected";
const float EXTRA_CELL_PADDING = 25.0;
const float EXTRA_REVIEW_PADDING = 20.0;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.loading = TRUE;
    [self drawHeader];
    
    self.rest = [[REST alloc] init];
    self.reviews = @[];
    
    NSString *reviews_url = [NSString stringWithFormat:@"/api/v1/spot/%@/reviews", self.space.remote_id];
    
    __weak ASIHTTPRequest *request = [rest getRequestForBlocksWithURL:reviews_url withCache:NO];
    
    [request setCompletionBlock:^{
        SBJsonParser *parser = [[SBJsonParser alloc] init];
        
        if (200 != [request responseStatusCode]) {
            NSLog(@"Code: %i", [request responseStatusCode]);
            NSLog(@"Body: %@", [request responseString]);
            // show an error
        }

        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss+'00:00'";

        self.reviews = [parser objectWithData:[request responseData]];
        for (NSMutableDictionary *review in reviews) {
            NSDate *date_obj = [dateFormatter dateFromString:[review objectForKey:@"date_submitted"]];
            [review setObject:date_obj forKey:@"date_object"];
        }
        self.loading = FALSE;
        [self drawHeader];

        [self.tableView reloadData];
    
        if (self.reviews.count == 0) {
            self.tableView.scrollEnabled = FALSE;
        }
    }];
    
    [request startAsynchronous];
    
    UIButton *write_review = (UIButton *)[self.view viewWithTag:603];
    write_review.layer.backgroundColor = [[UIColor whiteColor] CGColor];
    
    NSString *app_path = [[NSBundle mainBundle] bundlePath];
    NSString *plist_path = [app_path stringByAppendingPathComponent:@"ui_magic_values.plist"];
    NSDictionary *plist_values = [NSDictionary dictionaryWithContentsOfFile:plist_path];
    
    float red_value = [[plist_values objectForKey:@"default_nav_button_color_red"] floatValue];
    float green_value = [[plist_values objectForKey:@"default_nav_button_color_green"] floatValue];
    float blue_value = [[plist_values objectForKey:@"default_nav_button_color_blue"] floatValue];
    
    UIColor *border_color = [UIColor colorWithRed:red_value / 255.0 green:green_value / 255.0 blue:blue_value / 255.0 alpha:1.0];
    
    write_review.layer.borderWidth = 1.0;
    write_review.layer.borderColor = border_color.CGColor;
    write_review.layer.cornerRadius = 3.0;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.loading) {
        return 0;
    }
    // Return 1 if there are no reviews, so we can show the no reviews cell
    NSInteger count = [reviews count];
    if (count > 0) {
        return count;
    }
    return 1;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.reviews.count == 0) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"no_reviews"];
        return cell;
    }
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"review_cell"];

    UILabel *author = (UILabel *)[cell viewWithTag:200];
    UILabel *date = (UILabel *)[cell viewWithTag:201];
    UITextView *review = (UITextView *)[cell viewWithTag:202];
    
    NSString *review_content = [[self.reviews objectAtIndex:indexPath.row] objectForKey:@"review"];
    NSString *trimmed_review = [review_content stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    CGSize bound = CGSizeMake(review.frame.size.width, CGFLOAT_MAX);
    CGRect frame_size = [review_content boundingRectWithSize:bound options:(NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading) attributes:@{NSFontAttributeName: review.font} context:nil];

    review.frame = CGRectMake(review.frame.origin.x, review.frame.origin.y, review.frame.size.width, frame_size.size.height + EXTRA_REVIEW_PADDING);

    review.text = trimmed_review;
    author.text = [[self.reviews objectAtIndex:indexPath.row] objectForKey:@"reviewer"];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterLongStyle];
    
    NSDate *date_obj = (NSDate *) [[self.reviews objectAtIndex:indexPath.row] objectForKey:@"date_object"];
    
    date.text = [dateFormatter stringFromDate:date_obj];

    NSInteger rating = [[[self.reviews objectAtIndex:indexPath.row] objectForKey:@"rating"] integerValue];
    
    NSString *img_name = [NSString stringWithFormat:@"StarRating-small_%lih_fill.png", (long)rating * 2];

    UIImageView *stars = (UIImageView *)[cell viewWithTag:100];
    [stars setImage:[UIImage imageNamed:img_name]];
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.reviews.count == 0) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"no_reviews"];
        return cell.frame.size.height;
    }
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"review_cell"];
    UITextView *review = (UITextView *)[cell viewWithTag:202];

    CGFloat top = review.frame.origin.y;
    NSString *review_content = [[self.reviews objectAtIndex:indexPath.row] objectForKey:@"review"];


    CGSize bound = CGSizeMake(review.frame.size.width, CGFLOAT_MAX);
    CGRect frame_size = [review_content boundingRectWithSize:bound options:(NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading) attributes:@{NSFontAttributeName: review.font} context:nil];

    return top + frame_size.size.height + EXTRA_CELL_PADDING;
}

-(void)drawHeader {
    UILabel *space_name = (UILabel *)[self.view viewWithTag:600];
    space_name.text = self.space.name;

    // Decision on Apr/11/2014 - round up rating to int star value
    // Decision on May/8/2014 - back to half stars.
    int aggregate_rating_2x = 0;
    NSInteger review_count = 0;
    if ([self.space.extended_info valueForKey:@"review_count"]) {
        // Just to make sure we stay on .5 if the server gives us something else:
        aggregate_rating_2x = (int)([[self.space.extended_info valueForKey:@"rating"] floatValue] * 2);
        
        review_count = [[self.space.extended_info valueForKey:@"review_count"] intValue];
    }
    
    // If we have actual review data at this point, use that instead.  SPOT-1828
    if ([self.reviews count] > 0) {
        review_count = [self.reviews count];
        NSInteger total_rating = 0;
        for (NSDictionary *review in self.reviews) {
            NSInteger rating = [[review objectForKey:@"rating"] integerValue];
            total_rating += rating;
        }
        
        aggregate_rating_2x = (int)((float)total_rating / (float)review_count * 2.0);
        
    }

    // When written, we don't support 0 star ratings, so no single half star.  Just in case that changes... make it fail.
    if (aggregate_rating_2x < 2) {
        aggregate_rating_2x = 0;
    }
    
    NSString *img_name = [NSString stringWithFormat:@"StarRating-small_%ih_fill.png", aggregate_rating_2x];

    UIImageView *rating_display = (UIImageView *)[self.view viewWithTag:602];
    rating_display.image = [UIImage imageNamed:img_name];
    
    UILabel *current_rating = (UILabel *)[self.view viewWithTag:601];
    current_rating.text = [NSString stringWithFormat:@"(%li)", review_count];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"write_review"] || [[segue identifier] isEqualToString:@"write_first_review"]) {
        ReviewSpaceViewController *dest = (ReviewSpaceViewController *)[segue destinationViewController];
        dest.space = self.space;
    }
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
