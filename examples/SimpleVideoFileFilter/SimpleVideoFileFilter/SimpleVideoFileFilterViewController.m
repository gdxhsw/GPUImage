#import "SimpleVideoFileFilterViewController.h"

@implementation SimpleVideoFileFilterViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
  
    NSURL *sampleURL = [[NSBundle mainBundle] URLForResource:@"sample_iPod" withExtension:@"m4v"];
    
    movieFile = [[GPUImageMovie alloc] initWithURL:sampleURL];
    pixellateFilter = [[GPUImagePixellateFilter alloc] init];
    GPUImageRotationFilter *rotationFilter = [[GPUImageRotationFilter alloc] initWithRotation:kGPUImageRotateRight];
    
    [movieFile addTarget:rotationFilter];
    [rotationFilter addTarget:pixellateFilter];
    GPUImageView *filterView = (GPUImageView *)self.view;
    [pixellateFilter addTarget:filterView];

    // In addition to displaying to the screen, write out a processed version of the movie to disk
    NSString *pathToMovie = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/Movie.m4v"];
    unlink([pathToMovie UTF8String]); // If a file already exists, AVAssetWriter won't let you record new frames, so delete the old movie
    NSURL *movieURL = [NSURL fileURLWithPath:pathToMovie];

    movieWriter = [[GPUImageMovieWriter alloc] initWithMovieURL:movieURL size:CGSizeMake(480.0, 640.0)];
    [pixellateFilter addTarget:movieWriter];
    
    [movieWriter startRecording];
    [movieFile startProcessing];
    
    double delayInSeconds = 5.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [pixellateFilter removeTarget:movieWriter];
        [movieWriter finishRecording];
        NSLog(@"Done recording");
    });
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)updatePixelWidth:(id)sender
{
    pixellateFilter.fractionalWidthOfAPixel = [(UISlider *)sender value];
}

@end
