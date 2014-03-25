//
//  MainGameController.m
//  Project Fieldlord
//
//  Created by Jason Fieldman on 2/24/14.
//  Copyright (c) 2014 Jason Fieldman. All rights reserved.
//

#import "MainGameController.h"

//#define SCORELABEL_FONT @"Dosis-Regular"
#define SCORELABEL_FONT @"MuseoSansRounded-300"
#define GUNLABEL_FONT   @"MuseoSansRounded-700"
#define SCORELABEL_SIZE 20

@interface MainGameController ()

@end


@implementation MainGameController

SINGLETON_IMPL(MainGameController);

- (id) init {
	if ((self = [super init])) {
		
		self.view = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
		self.view.backgroundColor = [UIColor colorWithWhite:238/255.0 alpha:1];
		
		_dontAnimateIndex = -1;
		
		/* Add background */
		UIImageView *background = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"game_background"]];
		[self.view addSubview:background];
		
		/* Initialize monsters */
		_activeMonsters = [NSMutableArray array];
		
		/* Create the monster field */
		_monsterField = [[UIView alloc] initWithFrame:CGRectMake(0, 66, 320, ([UIScreen mainScreen].bounds.size.height > 481) ? (516-20-40) : (426-20-40))];
		_monsterField.backgroundColor = [UIColor clearColor];
		[self.view addSubview:_monsterField];
		
		/* Add monsters to field */
		[MonsterInfo monsterAtIndex:0];
		for (int i = 0; i < [MonsterInfo maxMonsterCount]; i++) {
			MonsterView *v = [MonsterInfo monsterAtIndex:i].view;
			[_monsterField addSubview:v];
		}
		
		_burstView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 320)];
		_burstView.image = [UIImage imageNamed:@"burst"];
		_burstView.alpha = 0;
		[_monsterField addSubview:_burstView];
		
		/*
		UILabel *lab = [[UILabel alloc] initWithFrame:CGRectMake(10, 200, 200, 50)];
		lab.text = @"Hello World!";
		lab.font = [UIFont fontWithName:@"Dosis-Regular" size:20];
		[self.view addSubview:lab];
		 */
		
		/* --------- Views --------- */
		
		//_statsView = [[UIView alloc] initWithFrame:CGRectMake(5, self.view.bounds.size.height-48, 310, 40)];
		_statsView = [[UIView alloc] initWithFrame:CGRectMake(5, 20, 310, 40)];
		_statsView.backgroundColor = [UIColor clearColor];
		#if 1
		_statsView.backgroundColor = [UIColor colorWithWhite:1 alpha:0.95];
		_statsView.layer.cornerRadius = 16;
		_statsView.layer.borderColor = [UIColor colorWithWhite:0 alpha:0.75].CGColor;
		_statsView.layer.borderWidth = 1.0;
		_statsView.layer.shadowOpacity = 0.5;
		_statsView.layer.shadowColor = [UIColor blackColor].CGColor;
		_statsView.layer.shadowOffset = CGSizeMake(0, 0);
		_statsView.layer.shadowRadius = 2;
		_statsView.layer.shouldRasterize = YES;
		_statsView.layer.rasterizationScale = [UIScreen mainScreen].scale;
		#endif
		[self.view addSubview:_statsView];
		
		_reticuleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"reticule"]];
		_reticuleView.frame = CGRectMake(4, 7, 24, 24);
		[_statsView addSubview:_reticuleView];
		
		_shotsLabel = [[UILabel alloc] initWithFrame:CGRectMake(30, 7, 200, 24)];
		_shotsLabel.text = @"0 / 0";
		_shotsLabel.font = [UIFont fontWithName:SCORELABEL_FONT size:SCORELABEL_SIZE];
		[_statsView addSubview:_shotsLabel];
		
		_scoreLabel = [[UILabel alloc] initWithFrame:CGRectMake(160, 7, 133, 24)];
		_scoreLabel.text = @"0 pts";
		_scoreLabel.textAlignment = NSTextAlignmentRight;
		_scoreLabel.font = [UIFont fontWithName:SCORELABEL_FONT size:SCORELABEL_SIZE];
		[_statsView addSubview:_scoreLabel];
		 
		
		
		/* Menu buttons */
		
		_menuView = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height-40, 320, 40)];
		[self.view addSubview:_menuView];
		
		const float buttonScale = 1.0;
		
		_helpButton = [UIButton buttonWithType:UIButtonTypeCustom];
		_helpButton.frame = CGRectMake(280, 0, 40, 40);
		_helpButton.alpha = 1;
		[_helpButton addTarget:self action:@selector(pressedHelp:) forControlEvents:UIControlEventTouchUpInside];
		[_menuView addSubview:_helpButton];
		
		UIImageView *helpIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_question"]];
		helpIcon.center = CGPointMake(22,18);
		helpIcon.alpha = 0.75;
		[_helpButton addSubview:helpIcon];
		helpIcon.transform = CGAffineTransformMakeScale(buttonScale, buttonScale);
		
		
		_restartButton = [UIButton buttonWithType:UIButtonTypeCustom];
		_restartButton.frame = CGRectMake(320-110, 0, 40, 40);
		_restartButton.alpha = 1;
		[_restartButton addTarget:self action:@selector(pressedRestart:) forControlEvents:UIControlEventTouchUpInside];
		[_menuView addSubview:_restartButton];
		
		UIImageView *restartIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_restart"]];
		restartIcon.center = CGPointMake(22,18);
		restartIcon.alpha = 0.75;
		[_restartButton addSubview:restartIcon];
		restartIcon.transform = CGAffineTransformMakeScale(buttonScale, buttonScale);
		
		
		_gcButton = [UIButton buttonWithType:UIButtonTypeCustom];
		_gcButton.frame = CGRectMake(70, 0, 40, 40);
		_gcButton.alpha = 1;
		[_gcButton addTarget:self action:@selector(pressedGamecenter:) forControlEvents:UIControlEventTouchUpInside];
		[_menuView addSubview:_gcButton];
		
		UIImageView *gcIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_gc"]];
		gcIcon.center = CGPointMake(22,18);
		gcIcon.alpha = 0.75;
		[_gcButton addSubview:gcIcon];
		gcIcon.transform = CGAffineTransformMakeScale(buttonScale, buttonScale);

		
		
		_shotgunButton = [UIButton buttonWithType:UIButtonTypeCustom];
		_shotgunButton.frame = CGRectMake(140, 0, 40, 40);
		_shotgunButton.alpha = 1;
		[_shotgunButton addTarget:self action:@selector(pressedShotgun:) forControlEvents:UIControlEventTouchUpInside];
		[_menuView addSubview:_shotgunButton];
		
		_shotgunRingLayer = [CALayer layer];
		_shotgunRingLayer.frame = CGRectMake(0, 0, 28, 28);
		_shotgunRingLayer.position = CGPointMake(22,18);
		_shotgunRingLayer.opacity = 0.75;
		_shotgunRingLayer.backgroundColor = [UIColor clearColor].CGColor;
		_shotgunRingLayer.cornerRadius = 14;
		_shotgunRingLayer.borderColor = [UIColor colorWithHue:193/360.0 saturation:0.31 brightness:0.85 alpha:1].CGColor;
		_shotgunRingLayer.borderWidth = 4;
		_shotgunRingLayer.shadowColor = [UIColor colorWithHue:0/360.0 saturation:0.51 brightness:1 alpha:1].CGColor;
		_shotgunRingLayer.shadowOffset = CGSizeMake(0, 0);
		_shotgunRingLayer.shadowOpacity = 0;
		_shotgunRingLayer.shadowRadius = 1;
		_shotgunRingLayer.rasterizationScale = [UIScreen mainScreen].scale;
		_shotgunRingLayer.shouldRasterize = YES;
		[_shotgunButton.layer addSublayer:_shotgunRingLayer];

		_shotgunCountLabel = [[UILabel alloc] initWithFrame:CGRectMake(-40, 0, 120, 40)];
		_shotgunCountLabel.center = CGPointMake(22,18);
		_shotgunCountLabel.text = @"0";
		_shotgunCountLabel.textAlignment = NSTextAlignmentCenter;
		_shotgunCountLabel.font = [UIFont fontWithName:GUNLABEL_FONT size:10];
		[_shotgunButton addSubview:_shotgunCountLabel];
		
		
		_muteButton = [UIButton buttonWithType:UIButtonTypeCustom];
		_muteButton.frame = CGRectMake(0, 0, 40, 40);
		_muteButton.alpha = 1;
		[_muteButton addTarget:self action:@selector(pressedMute:) forControlEvents:UIControlEventTouchUpInside];
		[_menuView addSubview:_muteButton];
		
		UIImageView *muteIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_speaker"]];
		muteIcon.center = CGPointMake(18,18);
		muteIcon.alpha = 0.75;
		[_muteButton addSubview:muteIcon];
		muteIcon.transform = CGAffineTransformMakeScale(buttonScale, buttonScale);
		
		_muteXout = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_xout"]];
		_muteXout.center = CGPointMake(18,18);
		_muteXout.alpha = 0.75;
		[_muteButton addSubview:_muteXout];
		_muteXout.hidden = [PreloadedSFX isMute] ? NO : YES;
		_muteXout.transform = CGAffineTransformMakeScale(buttonScale, buttonScale);
		
		
		
		/* --------- Setup level -------- */
		
		/* This is grossly incompetent */
		
		NSArray *positions = [[GameState sharedInstance] loadState];
		if (positions) {
			
			NSLog(@"loading");
			
			int i = 0;
			for (NSDictionary *mDic in positions) {
				MonsterInfo *mi = [MonsterInfo monsterAtIndex:i];
				mi.active = [mDic[@"active"] intValue];
								
				if (mi.active) {
					[_activeMonsters addObject:mi];
					double ang = (rand()%360) * M_PI / 180.0 ;
					mi.view.center = CGPointMake( _monsterField.bounds.size.width/2 + 480*cos(ang), _monsterField.bounds.size.height/2 + 480*sin(ang) );
					CGPoint center = CGPointMake([mDic[@"x"] floatValue], [mDic[@"y"] floatValue]);
					dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(floatBetween(0, 0.5) * NSEC_PER_SEC)), dispatch_get_main_queue(), ^(void){
						[mi.view animateToNewCenter:center];
					});
				}
				
				i++;
			}
			
		} else {
			[self setMonsterCountTo:self.monstersForScore];
					
			dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^(void){
				[self animateMonstersNewPositions];
			});
		}
		[self setNewIt];
		
		
		/* Add guesture pad last */
		_gesturePad = [[UIView alloc] initWithFrame:_monsterField.bounds];
		_gesturePad.backgroundColor = [UIColor clearColor];
		[_monsterField addSubview:_gesturePad];
		
		UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGuesture:)];
		[_gesturePad addGestureRecognizer:recognizer];
		
		[self updateStats];
		
		
		/* -- Help on top -- */
		_helpView = [[HelpView alloc] initWithFrame:self.view.bounds];
		_helpView.alpha = 0;
		_helpView.userInteractionEnabled = NO;
		[self.view addSubview:_helpView];
		
		/* GC */
		//if ([GKLocalPlayer localPlayer].authenticated) { /* Do nothing */ _helpView.alpha = 0; };
		_achReport = [NSMutableDictionary dictionary];
	}
	return self;
}

- (void) pressedMute:(id)sender {
	[PreloadedSFX setMute:![PreloadedSFX isMute]];
	_muteXout.hidden = [PreloadedSFX isMute] ? NO : YES;
	[PreloadedSFX playSFX:PLSFX_MENUTAP];
}

- (void) pressedHelp:(id)sender {
	[PreloadedSFX playSFX:PLSFX_MENUTAP];
	
	[Flurry logEvent:@"Used_Help"];
	
	[_helpView animateIn];
}

- (void) pressedRestart:(id)sender {
	[PreloadedSFX playSFX:PLSFX_MENUTAP];
	[[[UIAlertView alloc] initWithTitle:@"Restart Game?" message:@"Are you sure you want to restart?  This will reset your hit/attempt record and power shot inventory." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Reset", nil] show];
}

- (void) pressedGamecenter:(id)sender {
	[PreloadedSFX playSFX:PLSFX_MENUTAP];
	
	[Flurry logEvent:@"Accessed_Gamecenter"];
	
	_wantsGCShow = YES;
	
	/* Authorize if needed */
	if (![GKLocalPlayer localPlayer].authenticated) {
		
		if ([[GKLocalPlayer localPlayer] respondsToSelector:@selector(setAuthenticateHandler:)]) {
			[GKLocalPlayer localPlayer].authenticateHandler = ^(UIViewController *viewController, NSError *error) {
				if (viewController) {
					[self presentViewController:viewController animated:YES completion:^{
						[self updateGCStats];
						[self showGamecenterInfo];
					}];
				} else {
					[self updateGCStats];
					[self showGamecenterInfo];
				}
			};
		}
		
	} else {
		[self updateGCStats];
		[self showGamecenterInfo];
	}
	
	/* Debug stuff */
	#if 0
	[GKAchievement resetAchievementsWithCompletionHandler:^(NSError *error) {
	}];
	[GKAchievement loadAchievementsWithCompletionHandler:^(NSArray *achievements, NSError *error) {
		NSLog(@"ach: %@ %@", achievements, error);
	}];
	#endif
}

- (void) showGamecenterInfo {
	if (![GKLocalPlayer localPlayer].authenticated) {
		return;
	}
	
	if (!_wantsGCShow) return;
	_wantsGCShow = NO;
	
	GKGameCenterViewController *vc = [[GKGameCenterViewController alloc] init];
	vc.gameCenterDelegate = self;
	vc.viewState = GKGameCenterViewControllerStateAchievements;
	[self presentViewController:vc animated:YES completion:nil];
}

- (void)gameCenterViewControllerDidFinish:(GKGameCenterViewController *)gameCenterViewController {
	[self dismissViewControllerAnimated:YES completion:nil];
}

- (void) updateGCStats {
	if (![GKLocalPlayer localPlayer].authenticated) return;
	
	GKScore *score = [[GKScore alloc] initWithLeaderboardIdentifier:@"SCORE"];
	score.value = [GameState sharedInstance].score;
	
	GKScore *total = [[GKScore alloc] initWithLeaderboardIdentifier:@"TOTALHITS"];
	total.value = [GameState sharedInstance].totalHitsMade;
	
	[GKScore reportScores:@[score, total] withCompletionHandler:^(NSError *error) {}];
}

- (void) reportAchievement:(NSString*)ach {
	if (![GKLocalPlayer localPlayer].authenticated) return;
	if ([[_achReport objectForKey:ach] boolValue]) return;
	
	GKAchievement *a = [[GKAchievement alloc] initWithIdentifier:ach];
	a.percentComplete = 100.0;
	a.showsCompletionBanner = YES;
	[GKAchievement reportAchievements:@[ a ] withCompletionHandler:^(NSError *error) {}];
	_achReport[ach] = [NSNumber numberWithBool:YES];
}

- (void) pressedShotgun:(id)sender {
	//[PreloadedSFX playSFX:PLSFX_MENUTAP];
	
	if ([GameState sharedInstance].shotgunsLeft > 0) {
	
		[PreloadedSFX playSFX:_shotgunArmed?PLSFX_DISARMPOWERSHOT:PLSFX_ARMPOWERSHOT];
		
		[self armShotgun:!_shotgunArmed];
		
	} else {
		[PreloadedSFX playSFX:PLSFX_EMPTYPOWERSHOT];
	}
	
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (buttonIndex != alertView.cancelButtonIndex) [self doRestart];
}

- (void) doRestart {
	[Flurry logEvent:@"Restarted"];
	
	[GameState sharedInstance].hitsMade = 0;
	[GameState sharedInstance].shotsAttempted = 0;
	[GameState sharedInstance].shotgunsLeft = DEFAULT_SHOTGUNS;
	
	[self animateMonstersNewPositions];
	[self setNewIt];
	
	[self updateStats];
}

- (void) armShotgun:(BOOL)arm {
	_shotgunArmed = arm;
	if (arm) {
		_shotgunRingLayer.borderWidth = 6;
		_shotgunRingLayer.transform = CATransform3DMakeScale(1.5, 1.5, 1);
		_shotgunRingLayer.borderColor = [UIColor colorWithHue:0/360.0 saturation:0.31 brightness:0.85 alpha:1].CGColor;
		_shotgunRingLayer.shadowOpacity = 1;

	} else {
		_shotgunRingLayer.borderWidth = 4;
		_shotgunRingLayer.transform = CATransform3DIdentity;
		_shotgunRingLayer.borderColor = [UIColor colorWithHue:193/360.0 saturation:0.31 brightness:0.85 alpha:1].CGColor;
		_shotgunRingLayer.shadowOpacity = 0;
	}
}

- (void) applyEarthquakeToView:(UIView*)v duration:(float)duration delay:(float)delay offset:(int)offset {
	CAKeyframeAnimation *transanimation;
	transanimation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
	transanimation.duration = duration;
	transanimation.cumulative = YES;
	int offhalf = offset / 2;
	
	int numFrames = 10;
	NSMutableArray *positions = [NSMutableArray array];
	NSMutableArray *keytimes  = [NSMutableArray array];
	NSMutableArray *timingfun = [NSMutableArray array];
	[positions addObject:[NSValue valueWithCATransform3D:CATransform3DIdentity]];
	[keytimes addObject:@(0)];
	for (int i = 0; i < numFrames; i++) {
		[positions addObject:[NSValue valueWithCATransform3D:CATransform3DMakeTranslation(rand()%offset-offhalf, rand()%offset-offhalf,0)]];
		[keytimes addObject:@( ((float)(i+1))/(numFrames+2) )];
		[timingfun addObject:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
	}
	[positions addObject:[NSValue valueWithCATransform3D:CATransform3DIdentity]];
	[keytimes addObject:@(1)];
	[timingfun addObject:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
	
	transanimation.values = positions;
	transanimation.keyTimes = keytimes;
	transanimation.calculationMode = kCAAnimationCubic;
	transanimation.timingFunctions = timingfun;
	transanimation.beginTime = CACurrentMediaTime() + delay;
	[v.layer addAnimation:transanimation forKey:nil];
}

- (void) updateStats {
	_shotsLabel.text = [NSString stringWithFormat:@"%lld / %lld", [GameState sharedInstance].hitsMade, [GameState sharedInstance].shotsAttempted];
	_scoreLabel.text = [NSString stringWithFormat:@"%lld pts", [GameState sharedInstance].score];
	_shotgunCountLabel.text = [NSString stringWithFormat:@"%d", [GameState sharedInstance].shotgunsLeft];
}

- (int) it { return _indexIt; }

- (float) affinityChance {
	float rating = (1000.0 - [GameState sharedInstance].score) / 1000.0;
	if (rating < 0) rating = 0;
	if (rating > 1) rating = 1;
	return 0.5 * rating;
}

- (float) affinityStrength {
	return self.affinityChance;
}

- (float) fearRadius {
	return 60;
}

- (float) fearMultiplier {
	return 5;
}

- (int) monstersForScore {
	return NUM_MONSTERS;
	#if 0
	float rating = [GameState sharedInstance].score / 1000.0;
	if (rating < 0) rating = 0;
	if (rating > 1) rating = 1;
	return (int)(12 + 12*rating);
	#endif
	
	float rad = M_PI / 100.0 * [GameState sharedInstance].score - (M_PI/4);
	return (int)(12 + 12 * sin(rad));
}

- (void) setNewIt {
	_indexIt = rand() % ([_activeMonsters count]);
}

- (void) setMonsterCountTo:(int)numMonsters {
	EXLog(ANY, DBG, @"Changing count to %d", numMonsters);
	if ([_activeMonsters count] < numMonsters) {
		for (long i = [_activeMonsters count]; i < numMonsters; i++) {
			
			int mIndex = [MonsterInfo indexForRandomMonsterWithActiveState:NO];
			MonsterInfo *newMonster = [MonsterInfo monsterAtIndex:mIndex];
			
			/* Add to array */
			[_activeMonsters addObject:newMonster];
			newMonster.active = YES;
			
			/* Set to point off screen for next lead in */
			MonsterView *m = newMonster.view;
			double ang = (rand()%360) * M_PI / 180.0 ;
			m.center = CGPointMake( _monsterField.bounds.size.width/2 + 480*cos(ang), _monsterField.bounds.size.height/2 + 480*sin(ang) );			
		}
	} else if ([_activeMonsters count] > numMonsters) {
		for (long i = [_activeMonsters count]; i > numMonsters; i--) {
						
			int rIdx = (rand()%[_activeMonsters count]);
			while (rIdx != _indexIt) rIdx = (rand()%[_activeMonsters count]);
			MonsterInfo *newMonster = _activeMonsters[rIdx];
			
			/* Add to array */
			[_activeMonsters removeObject:newMonster];
			newMonster.active = NO;
			
			/* Update it */
			if (rIdx < _indexIt) _indexIt--;
			
			/* Set to point off screen for next lead in */
			double ang = (rand()%360) * M_PI / 180.0 ;
			CGPoint newCenter = CGPointMake( _monsterField.bounds.size.width/2 + 480*cos(ang), _monsterField.bounds.size.height/2 + 480*sin(ang) );
			[newMonster.view animateToNewCenter:newCenter];
		}
	}
}

- (void) animateMonstersNewPositions {
	int i = 0;
	for (MonsterInfo *activeMonster in _activeMonsters) {
		/* Ugly hack to not animate the it monster */
		if (_dontAnimateIndex == i) { i++; continue; }
						
		CGPoint center = [self newRandomCenterForActiveMonsterAtIndex:i];
		activeMonster.destination = center;
		
		dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(floatBetween(0, 0.5) * NSEC_PER_SEC)), dispatch_get_main_queue(), ^(void){
			[activeMonster.view animateToNewCenter:center];
		});
		
		i++;
	}
}

- (CGPoint) newRandomCenterForActiveMonsterAtIndex:(int)index {
	MonsterInfo *monster = _activeMonsters[index];
	CGPoint point = [monster randomValidCenterInSize:_monsterField.bounds.size];
	
	if (index > 0) {
		/* If we need to create affinity to another monster, do so */
		if (self.affinityChance > floatBetween(0, 1)) {
			MonsterInfo *otherMonster = _activeMonsters[rand()%index];
			point.x += (self.affinityStrength) * (otherMonster.destination.x - point.x);
			point.y += (self.affinityStrength) * (otherMonster.destination.y - point.y);
		}
	}
	
	return point;
}

- (void) animateMonstersToAvoidTouchAt:(CGPoint)point {
	float fRadius = self.fearRadius;
	float fMulti  = self.fearMultiplier;
	
	if (_shotgunArmed) {
		fRadius *= 3;
		fMulti *= 1;
	}
	
	for (MonsterInfo *activeMonster in _activeMonsters) {
		CGPoint currentMonsterCenter = ((CALayer*)activeMonster.view.layer.presentationLayer).position;
		float xdiff = currentMonsterCenter.x - point.x;
		float ydiff = currentMonsterCenter.y - point.y;
		float dist = sqrtf(xdiff * xdiff + ydiff * ydiff);
		//NSLog(@"dist: %f", dist);
		if (dist < fRadius) {
			CGSize monsterSize = activeMonster.view.bounds.size;
			if (fabs(xdiff) < 1) xdiff = 1;
			if (fabs(ydiff) < 1) ydiff = 1;
			float fear = fMulti * (fRadius - dist) / fRadius;
			CGPoint newPoint = CGPointMake(currentMonsterCenter.x + xdiff*fear, currentMonsterCenter.y + ydiff*fear);
			if (newPoint.x < monsterSize.width/2)  newPoint.x = monsterSize.width/2;
			if (newPoint.y < monsterSize.height/2) newPoint.y = monsterSize.height/2;
			if (newPoint.x > (_monsterField.bounds.size.width  - monsterSize.width/2))  newPoint.x = (_monsterField.bounds.size.width  - monsterSize.width/2);
			if (newPoint.y > (_monsterField.bounds.size.height - monsterSize.height/2)) newPoint.y = (_monsterField.bounds.size.height - monsterSize.height/2);
			dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(floatBetween(0, 0.1) * NSEC_PER_SEC)), dispatch_get_main_queue(), ^(void){
				[activeMonster.view animateToNewCenter:newPoint];
			});
		}
	}
}

- (void)handleTapGuesture:(UIGestureRecognizer *)gestureRecognizer {
	CGPoint p = [gestureRecognizer locationInView:_gesturePad];
	//NSLog(@"tapped at %f %f", p.x, p.y);
	
	/* I don't like this effect */
	#if 0
	[self animateTapAtPoint:p];
	#endif
	
	NSArray *monstersTapped = [self monsterIndexesOverlappingPoint:p];
	BOOL     itTapped = [self doesIndexArrayContainIt:monstersTapped];
	
	[Flurry logEvent:@"Tapped_Screen" withParameters:@{@"hit_it":( itTapped ? @(1) : @(0) ), @"touch_count":@([monstersTapped count])}];
	
	long mTapCount = [monstersTapped count];
	if (mTapCount > 1 && !_shotgunArmed) {
		[self reportAchievement:@"ONESHOTTWO"];		
	}
	if (mTapCount > 3 && !_shotgunArmed) {
		[self reportAchievement:@"ONESHOTFOUR"];
	}
	if (mTapCount > 9 && !_shotgunArmed) {
		[self reportAchievement:@"ONESHOTTEN"];
	}
	if (mTapCount > 11 && _shotgunArmed) {
		[self reportAchievement:@"POWEROVER"];
	}
	
	
	if (!itTapped) {
		[self animateMonstersToAvoidTouchAt:p];
	} else {
		/* Record hit */
		[GameState sharedInstance].hitsMade++;
		[GameState sharedInstance].totalHitsMade++;
		
		/* Give more shotguns */
		if ([GameState sharedInstance].hitsMade % 10 == 0) {
			[GameState sharedInstance].shotgunsLeft++;
			[Flurry logEvent:@"Earned_Powershot"];
		}
		
		/* Scatter */
		_dontAnimateIndex = _indexIt;
		[self animateMonstersNewPositions];
		_dontAnimateIndex = -1;
		
		/* Present it */
		[self animateIt];
		
		/* Change count - not working blah */
		//[self setMonsterCountTo:self.monstersForScore];
				
		/* New it */
		[self setNewIt];
			
	}
	
	/* Play tap sound */
	if (!_shotgunArmed) {
		[PreloadedSFX playSFX:PLSFX_TAPFIELD];
	}
	
	/* Shotgun? */
	if (_shotgunArmed) {
		[Flurry logEvent:@"Used_Powershot"];
		
		[PreloadedSFX playSFX:PLSFX_POWERSHOT1 + rand()%NUM_POWERSHOT_VARIETY];
		
		[self animateShotgunAtPoint:p];
		[self armShotgun:NO];
		[GameState sharedInstance].shotgunsLeft--;
		
		[self applyEarthquakeToView:self.view duration:0.4 delay:0 offset:14];
		
		float du = 1;
		float de = 0.3;
		float of = 2;
		[self applyEarthquakeToView:_muteButton    duration:du delay:de offset:of];
		[self applyEarthquakeToView:_gcButton      duration:du delay:de offset:of];
		[self applyEarthquakeToView:_shotgunButton duration:du delay:de offset:of];
		[self applyEarthquakeToView:_restartButton duration:du delay:de offset:of];
		[self applyEarthquakeToView:_helpButton    duration:du delay:de offset:of];
		[self applyEarthquakeToView:_statsView     duration:du delay:de offset:of];
		
		AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
	}
	
	/* Update stats */
	[GameState sharedInstance].shotsAttempted++;
	[self updateStats];
	
	int64_t score = [GameState sharedInstance].score;
	if (score == 42) {
		[self reportAchievement:@"MEANINGLIFE"];
	} else if (score > 9000) {
		[self reportAchievement:@"OVER9000"];
	}
}

- (NSArray*) monsterIndexesOverlappingPoint:(CGPoint)point {
	NSMutableArray *monsters = [NSMutableArray array];
	
	int radius = _shotgunArmed ? -60 : -4;
	
	int i = 0;
	for (MonsterInfo *activeMonster in _activeMonsters) {
		CGRect monsterFrame = ((CALayer*)activeMonster.view.layer.presentationLayer).frame;
		if (CGRectContainsPoint(CGRectInset(monsterFrame, radius, radius), point)) {
			[monsters addObject:@(i)];
		}
		i++;
	}
	
	return monsters;
}

- (BOOL) doesIndexArrayContainIt:(NSArray*)indexArray {
	for (NSNumber *n in indexArray) {
		//NSLog(@"%d %d %d", [n intValue], _indexIt, [_activeMonsters count]);
		if ([n intValue] == _indexIt) return YES;
	}
	return NO;
}


- (void) animateShotgunAtPoint:(CGPoint)point {
	UIView *tapView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 140, 140)];
	tapView.center = point;
	tapView.backgroundColor = [UIColor clearColor];
	tapView.userInteractionEnabled = NO;
	tapView.alpha = 0.5;
	tapView.layer.borderWidth = 30;
	tapView.layer.borderColor = [UIColor colorWithHue:(0)/256.0 saturation:0.5 brightness:1 alpha:1].CGColor;
	tapView.layer.cornerRadius = 70;
	tapView.layer.shadowColor = [UIColor colorWithHue:0/360.0 saturation:0.51 brightness:1 alpha:1].CGColor;
	tapView.layer.shadowOffset = CGSizeMake(0, 0);
	tapView.layer.shadowOpacity = 0;
	tapView.layer.shadowRadius = 5;
	tapView.layer.shouldRasterize = YES;
	tapView.layer.rasterizationScale = [UIScreen mainScreen].scale;
	
	tapView.transform = CGAffineTransformMakeScale(0.1, 0.1);
	const float duration = 0.3;
	[UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
		tapView.transform = CGAffineTransformIdentity;
		tapView.alpha = 0;
	} completion:nil];
	
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)((duration+0.2) * NSEC_PER_SEC)), dispatch_get_main_queue(), ^(void){
		[tapView removeFromSuperview];
	});

	
	[_monsterField addSubview:tapView];
}

- (void) animateIt {
	MonsterInfo *monster = _activeMonsters[_indexIt];
	CGPoint curCenter = ((CALayer*)monster.view.layer.presentationLayer).position;
	CGPoint newCenter = [self newRandomCenterForActiveMonsterAtIndex:_indexIt];
	
	//NSLog(@"moving: %.0f %.0f %.0f %.0f", curCenter.x, curCenter.y, newCenter.x, newCenter.y);
	
	monster.view.center = curCenter;
	_burstView.center = monster.view.center;
	_burstView.transform = CGAffineTransformIdentity;
	[monster.view.layer removeAnimationForKey:@"moveMonster"];
	[monster.view.layer removeAnimationForKey:@"bobbleW"];
	[monster.view.layer removeAnimationForKey:@"bobbleH"];
	
	
	//dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^(void){
	//	[monster.view.layer removeAnimationForKey:@"moveMonster"];
	//});
	
	const float zoom_duration = 0.6;
	
	_monsterField.userInteractionEnabled = NO;
	[_monsterField bringSubviewToFront:_burstView];
	[_monsterField bringSubviewToFront:monster.view];
	[_monsterField bringSubviewToFront:_gesturePad];
	[UIView animateWithDuration:zoom_duration delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
		monster.view.center = CGPointMake(curCenter.x+(newCenter.x-curCenter.x)/2, curCenter.y+(newCenter.y-curCenter.y)/2);
		monster.view.transform = CGAffineTransformScale(CGAffineTransformMakeRotation(floatBetween(-0.1, 0.1)*M_PI), 3, 3);
		_burstView.center = monster.view.center;
		_burstView.alpha = 1;
	} completion:^(BOOL finished) {
		[UIView animateWithDuration:zoom_duration delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
			monster.view.transform = CGAffineTransformIdentity;
			monster.view.center = newCenter;
			_burstView.center = monster.view.center;
			_burstView.alpha = 0;
		} completion:^(BOOL finished) {
			_monsterField.userInteractionEnabled = YES;
		}];
	}];
	
	[UIView animateWithDuration:(zoom_duration*2) delay:0 options:0 animations:^{
		_burstView.transform = CGAffineTransformMakeRotation(M_PI/4 * ((rand()%2)?-1:1));
	} completion:nil];
}


@end
