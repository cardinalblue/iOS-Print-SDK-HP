//
// HP Inc.
// All rights reserved.
//
// This file, its contents, concepts, methods, behavior, and operation
// (collectively the "Software") are protected by trade secret, patent,
// and copyright laws. The use of the Software is governed by a license
// agreement. Disclosure of the Software to third parties, in any form,
// in whole or in part, is expressly prohibited except as authorized by
// the license agreement.
//

#import "MPLayoutFit.h"
#import "MPLayoutPrepStepAdjust.h"
#import "MPLayoutPrepStepRotate.h"
#import "MPLayoutAlgorithmFit.h"

@interface MPLayoutComposite (protected)

@property (strong, nonatomic) MPLayoutAlgorithm *algorithm;

@end

@interface MPLayoutFit()

@property (strong, nonatomic, readonly) MPLayoutPrepStepAdjust *adjustStep;
@property (strong, nonatomic, readonly) MPLayoutPrepStepRotate *rotateStep;

@end

@implementation MPLayoutFit

- (id)initWithOrientation:(MPLayoutOrientation)orientation assetPosition:(CGRect)position;
{
    return [self initWithOrientation:orientation assetPosition:position shouldRotate:YES];
}

- (id)initWithOrientation:(MPLayoutOrientation)orientation assetPosition:(CGRect)position shouldRotate:(BOOL)shouldRotate
{
    MPLayoutAlgorithmFit *algorithm = [[MPLayoutAlgorithmFit alloc] init];
    _horizontalPosition = algorithm.horizontalPosition;
    _verticalPosition = algorithm.verticalPosition;
    
    _adjustStep = [[MPLayoutPrepStepAdjust alloc] initWithAdjustment:position];
    _rotateStep = [[MPLayoutPrepStepRotate alloc] initWithOrientation:orientation];
    NSArray *prepSteps = shouldRotate ? @[ _adjustStep, _rotateStep ] : @[ _adjustStep ];
    
    return self = [super initWithAlgorithm:algorithm andPrepSteps:prepSteps];
}

- (CGRect)assetPosition
{
    return self.adjustStep.adjustment;
}

- (MPLayoutOrientation)orientation
{
    return self.rotateStep.orientation;
}

#pragma mark - Rotation handling

- (void)drawContentImage:(UIImage *)image inRect:(CGRect)rect
{
    MPLayoutHorizontalPosition layoutHorizontalPosition = self.horizontalPosition;
    MPLayoutVerticalPosition layoutVerticalPosition = self.verticalPosition;
    [self.rotateStep imageForImage:image inContainer:rect];
    if (self.rotateStep.rotated) {
        layoutHorizontalPosition = [self rotatedVerticalPosition:self.verticalPosition];
        layoutVerticalPosition = [self rotatedHorizontalPosition:self.horizontalPosition];
    }

    self.algorithm = [[MPLayoutAlgorithmFit alloc] initWithHorizontalPosition:layoutHorizontalPosition andVerticalPosition:layoutVerticalPosition];
    
    [super drawContentImage:image inRect:rect];
}

- (void)layoutContentView:(UIView *)contentView inContainerView:(UIView *)containerView
{
    MPLayoutHorizontalPosition layoutHorizontalPosition = self.horizontalPosition;
    MPLayoutVerticalPosition layoutVerticalPosition = self.verticalPosition;
    [self.rotateStep contentRectForContent:contentView.bounds inContainer:containerView.bounds];
    if (self.rotateStep.rotated) {
        layoutHorizontalPosition = [self rotatedVerticalPosition:self.verticalPosition];
        layoutVerticalPosition = [self rotatedHorizontalPosition:self.horizontalPosition];
    }
    
    self.algorithm = [[MPLayoutAlgorithmFit alloc] initWithHorizontalPosition:layoutHorizontalPosition andVerticalPosition:layoutVerticalPosition];
    
    [super layoutContentView:contentView inContainerView:containerView];
}

- (MPLayoutHorizontalPosition)rotatedVerticalPosition:(MPLayoutVerticalPosition)verticalPosition
{
    MPLayoutHorizontalPosition rotatedPosition = MPLayoutHorizontalPositionMiddle;
    if (MPLayoutVerticalPositionTop == verticalPosition) {
        rotatedPosition = MPLayoutHorizontalPositionLeft;
    } else if (MPLayoutVerticalPositionBottom == verticalPosition) {
        rotatedPosition = MPLayoutHorizontalPositionRight;
    }
    return rotatedPosition;
}

- (MPLayoutVerticalPosition)rotatedHorizontalPosition:(MPLayoutHorizontalPosition)horizontalPosition
{
    MPLayoutVerticalPosition rotatedPosition = MPLayoutVerticalPositionMiddle;
    if (MPLayoutHorizontalPositionLeft == horizontalPosition) {
        rotatedPosition = MPLayoutVerticalPositionBottom;
    } else if (MPLayoutHorizontalPositionRight == horizontalPosition) {
        rotatedPosition = MPLayoutVerticalPositionTop;
    }
    return rotatedPosition;
}

@end
