#import "ViewController.h"
@import EncoreObjC;

@interface ViewController ()
@property (nonatomic, strong) UILabel *statusLabel;
@property (nonatomic, strong) UIButton *presentButton;
@property (nonatomic, strong) UIButton *checkEntitlementButton;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColor.systemBackgroundColor;
    self.title = @"EncoreObjC Demo";

    UIStackView *stack = [[UIStackView alloc] init];
    stack.axis = UILayoutConstraintAxisVertical;
    stack.spacing = 16;
    stack.alignment = UIStackViewAlignmentFill;
    stack.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:stack];

    [NSLayoutConstraint activateConstraints:@[
        [stack.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
        [stack.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor],
        [stack.widthAnchor  constraintEqualToAnchor:self.view.widthAnchor constant:-48]
    ]];

    self.statusLabel = [UILabel new];
    self.statusLabel.numberOfLines = 0;
    self.statusLabel.textAlignment = NSTextAlignmentCenter;
    self.statusLabel.text = @"Ready.";
    self.statusLabel.font = [UIFont monospacedSystemFontOfSize:13 weight:UIFontWeightRegular];
    [stack addArrangedSubview:self.statusLabel];

    self.presentButton = [self makeButtonWithTitle:@"Show placement 'paywall_demo'"
                                            action:@selector(presentPlacement:)];
    [stack addArrangedSubview:self.presentButton];

    self.checkEntitlementButton = [self makeButtonWithTitle:@"Check free-trial entitlement"
                                                     action:@selector(checkEntitlement:)];
    [stack addArrangedSubview:self.checkEntitlementButton];
}

- (UIButton *)makeButtonWithTitle:(NSString *)title action:(SEL)action {
    UIButton *b = [UIButton buttonWithType:UIButtonTypeSystem];
    [b setTitle:title forState:UIControlStateNormal];
    b.titleLabel.font = [UIFont boldSystemFontOfSize:15];
    [b addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    b.backgroundColor = UIColor.secondarySystemBackgroundColor;
    b.layer.cornerRadius = 10;
    [b.heightAnchor constraintEqualToConstant:48].active = YES;
    return b;
}

- (void)presentPlacement:(id)sender {
    [[[EncoreClient shared] placement:@"paywall_demo"]
        showWithCompletion:^(EncorePresentationResult *result, NSError *error) {
            if (error) {
                self.statusLabel.text = [NSString stringWithFormat:@"Error: %@", error.localizedDescription];
                return;
            }
            if (result.kind == EncorePresentationKindGranted) {
                self.statusLabel.text = [NSString stringWithFormat:@"Granted: kind=%ld value=%@ unit=%ld",
                                         (long)result.entitlement.kind,
                                         result.entitlement.value,
                                         (long)result.entitlement.unit];
            } else {
                self.statusLabel.text = [NSString stringWithFormat:@"Not granted. reason=%ld",
                                         (long)result.reason];
            }
        }];
}

- (void)checkEntitlement:(id)sender {
    EncoreEntitlement *ent = [EncoreEntitlement freeTrialWithValue:nil unit:EncoreEntitlementUnitUnspecified];
    [[EncoreClient shared] isActive:ent
                              scope:EncoreEntitlementScopeAll
                         completion:^(BOOL active) {
        self.statusLabel.text = active ? @"Free-trial ACTIVE" : @"Free-trial not active";
    }];
}

@end
