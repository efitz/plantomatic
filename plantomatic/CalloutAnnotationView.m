//
//  CalloutAnnotationView.m
//  CustomCalloutSample
//
//  Created by tochi on 11/05/17.
//  Copyright 2011 aguuu,Inc. All rights reserved.
//

#import "CalloutAnnotationView.h"
#import "CalloutAnnotation.h"

@implementation CalloutAnnotationView

- (id)initWithAnnotation:(id<MKAnnotation>)annotation
         reuseIdentifier:(NSString *)reuseIdentifier
{
  self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
  
  if (self) {
      self.frame = CGRectMake(0.0f, 0.0f, 300, 80);
      self.backgroundColor = [UIColor colorWithRed:0.9411 green:0.9411 blue:0.9411 alpha:1.0];
      UIColor* color=[[UIColor lightGrayColor] colorWithAlphaComponent:0.5];
      self.layer.borderColor = color.CGColor; //[UIColor colorWithRed:0.3254 green:0.5843 blue:0.9019 alpha:1.0].CGColor;
      self.layer.borderWidth = 1.0f;
      
      self.layer.cornerRadius = 5.0;
      self.clipsToBounds = true;
    
      _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(15.0f, 5.0f, 240.0f, 50.0f)];
      self.titleLabel.textColor = [UIColor blackColor];
      self.titleLabel.textAlignment = NSTextAlignmentLeft;
      self.titleLabel.backgroundColor = [UIColor clearColor];//[UIColor colorWithRed:0.8f green:0.8f blue:0.8f alpha:1.0];
      self.titleLabel.font = [UIFont systemFontOfSize:16];
      self.titleLabel.text = @"";
      self.titleLabel.numberOfLines = 0;
      [self addSubview:self.titleLabel];
    
      _button = [UIButton buttonWithType:UIButtonTypeCustom];
      [self.button setFrame:CGRectMake(15, 50, 240, 30)];
      [self.button setTitle:@"More options" forState:UIControlStateNormal];
//      [self.button setTitleColor:[UIColor colorWithRed:0.3254 green:0.5843 blue:0.9019 alpha:0.6] forState:UIControlStateNormal];
      
      [self.button setTitleColor:[UIColor colorWithRed:65.0/255.0 green:159.0/255.0 blue:221.0/255.0 alpha:1.0] forState:UIControlStateNormal];

      [self.button addTarget:self action:@selector(moreInfoButtonClicked) forControlEvents:UIControlEventTouchUpInside];
      self.button.backgroundColor = [UIColor clearColor];
      [self addSubview:self.button];
      
      _goButton = [UIButton buttonWithType:UIButtonTypeCustom];
      [self.goButton setFrame:CGRectMake(255, 0, 45, 80)];
      [self.goButton setTitle:@"Go" forState:UIControlStateNormal];
      [self.goButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
      self.goButton.titleLabel.font = [UIFont boldSystemFontOfSize:20];
      
      [self.goButton addTarget:self action:@selector(goButtonClicked) forControlEvents:UIControlEventTouchUpInside];
      self.goButton.backgroundColor = [UIColor colorWithRed:65.0/255.0 green:159.0/255.0 blue:221.0/255.0 alpha:1.0];
      [self addSubview:self.goButton];

  }
  return self;
}


-(void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    
    if ([self.title isKindOfClass:[NSNull class]])
    {
        self.titleLabel.text = @"";
    }
    else
    {
        self.titleLabel.text = self.title;
    }
}


#pragma mark - Button clicked
- (void)moreInfoButtonClicked
{
  CalloutAnnotation *annotation = self.annotation;
  [self.delegate moreInfoButtonClicked:annotation];
}

- (void)goButtonClicked
{
    CalloutAnnotation *annotation = self.annotation;
    [self.delegate goButtonClicked:annotation];
}


@end