package  {
	
	import flash.display.*;
	import flash.text.*;
	import flash.events.*;
	import flash.utils.getTimer;
	import flash.text.*;
	import flash.utils.Timer;
	import flash.media.SoundChannel;
	import flash.geom.Point;
	import fl.transitions.Rotate;
	
		
	public class Final_Flight extends MovieClip{
		
		// variables ***************************************************************************************************
		
		// bonus points
		private var alienBonus:int = 1;
		private var asteroidBonus:int = 1;
		// player ship
		private var player:Player_Ship;	
		
		// player health bar
		private var playerHP:Player_Health;

		
		
		// level background
		private var levelBG:Level_Background;	
		// hold alien ships
		private var alien:Array;	
		// hold player lasers
		private var playerLasers:Array;	
		// hold alien lasers
		private var alienLasers:Array;
		
		// current number of asteroids in play
		private var numAsteroids:Number;
		
		// arrays of asteroids
		private var asteroids:Array;
		// when to spawn next enemy ship
		private var nextShip:Timer; 
		
		
		// delay laser firing
		private var laserDelay:Timer;
		// when to spawn next asteroid
		private var nextAsteroid:Timer;
		// timer for when aliens should fire lasers
		private var alienFire:Timer; 
		
		// timer to delay victory screen
		private var winTimer:Timer;
		
		// timer to delay defeat screen
		private var defeatTimer:Timer;
		
		// timer for how long immune after death
		private var immuneTimer:Timer;
		
		
		
		// text fields for score, lives, level
		private var score:TextField;
		private var level:TextField;
		private var lives:TextField;
		private var wave:TextField;
		private var health:TextField;
		
		// custom text format
		var tFormat:TextFormat;
		
		// track lives, level, score
		private var curScore:int;
		private var curLevel:int;
		private var curLives:int;
		private var curWave:int;
		
		// wave number
		private var aWave:int = 1;
		private var rWave:int = 1;
		
		// number of enemies in level
		private var numEnemies:int = 0;
		private var numRocks:int = 0;
		
		// sound
		var channel:SoundChannel;
		
	// main function***********************************************************************************************	
		private function Start_Final_Flight():void{
			curScore = 0;
			curLevel = 1;
			curLives = 3;
			curWave = 1;
			setupTextFields();
			numEnemies = 0;
			numRocks = 0
			aWave = 1;
			rWave = 1;
			
			// create background and display
			levelBG = new Level_Background;
			levelBG.gotoAndStop("One");
			addChild(levelBG);
			// create player and display
			player = new Player_Ship();
			addChild(player);
			
			playerHP = new Player_Health();
			playerHP.x = stage.stageWidth/2;
			playerHP.y = stage.stageHeight - 10;
			addChild(playerHP);
			
			
			
			// hold list of lasers and alien ships
			alien = new Array();
			playerLasers = new Array();
			asteroids = new Array();
			alienLasers = new Array();
			numAsteroids = 0;
			addChild(score);
			addChild(lives);
			addChild(level);
			addChild(wave);
			addChild(health);
			// background music
			playBGMusic();
			
			
			
			// initialize continuous firing of lasers by holding mouse button down
			stage.addEventListener(MouseEvent.MOUSE_DOWN, mouseDown);
			
			stage.addEventListener(Event.ENTER_FRAME, asteroidPlayerCollision);
			stage.addEventListener(Event.ENTER_FRAME, asteroidAlienCollision);
			stage.addEventListener(Event.ENTER_FRAME, laserAsteroidCollision);
			stage.addEventListener(Event.ENTER_FRAME, alienPlayerCollision);
			stage.addEventListener(Event.ENTER_FRAME, laserAlienCollision);
			stage.addEventListener(Event.ENTER_FRAME, alienLaserPlayerCollision);
			
			
			
			
			setNextShip();
			
			
			
			
		
		}
		
		//*********************************************************************************************************************************
		
		// play background music
		public function playBGMusic(){
			channel = (new bensound_house()).play();
			channel.addEventListener(Event.SOUND_COMPLETE, songDone);
		}
		public function songDone(e:Event){
			channel.removeEventListener(Event.SOUND_COMPLETE, songDone);
			playBGMusic();
		}
		// set immune timer
		public function setImmuneTimer(){
			immuneTimer = new Timer(3000,1);
			immuneTimer.addEventListener(TimerEvent.TIMER_COMPLETE, immuneGone);
			immuneTimer.start()
		}
		
		
		// set defeat timer
		public function setDefeatTimer(){
			defeatTimer = new Timer(500,1);
			defeatTimer.addEventListener(TimerEvent.TIMER_COMPLETE, endGame);
			defeatTimer.start();
		}
		
		// set win timer
		public function setWinTimer(){
			winTimer = new Timer(3500,1);
			winTimer.addEventListener(TimerEvent.TIMER_COMPLETE, winGame);
			winTimer.start();
		}
		
		// stagger the creating of new enemy ships
		public function setNextShip(){
			nextShip = new Timer(750 + Math.random() * 750,1);
			nextShip.addEventListener(TimerEvent.TIMER_COMPLETE, newShip);
			nextShip.start();
		}
		
		// stagger the creation of asteroids
		public function setNextAsteroid(){
			nextAsteroid = new Timer(1000 + Math.random() * 1000, 1);
			nextAsteroid.addEventListener(TimerEvent.TIMER_COMPLETE, newAsteroids);
			nextAsteroid.start();
		}
		
		// timer for alien shooting lasers
		public function setAlienFire(){
			
			
			
				alienFire = new Timer(750 + Math.random() * 1000,1);
				alienFire.addEventListener(TimerEvent.TIMER_COMPLETE, fireAlienLasers);
				alienFire.start();
			
			
		}
		
		// timer for the delay between laser shots
		public function laserTimer(){
			laserDelay = new Timer(350,1);
			laserDelay.addEventListener(TimerEvent.TIMER_COMPLETE, fireLaser);
			laserDelay.start();
		}
/***********************************************************************************************************************************************************************/		
		/* This function checks to see what level we are currently on (1,2,3 etc).  It then checks within each level to see what wave we are on (1,2,3)
		** after each wave we increase the wave number for alien ship and then move on to sending the corresponding wave of asteroids. once the asterdoid 
		** wave is over we increase the wave number for the asteroids and then start the next wave of aliens. we continue this process until all three waves
		** have been completed.  At this point we make sure all the waves are reset to 1 and then increase the level number by 1.  After x number of levels
		** we play the wonGame() function to display the winning game screen and the player's final score. 
		*/
		
		// create a new alien ship
		public function newShip(e:TimerEvent){
			var horizontal:Number = Math.random() * stage.stageWidth;
			if (horizontal < 25){
				horizontal = 25;
			}
			var speed:Number = Math.random() * 100 + 100;
			var wNum1, wNum2, wNum3:int
			
			if (curLevel == 1){
				wNum1 = 10;
				wNum2 = 15;
				wNum3 = 20;
				if (aWave == 1){
					if (numEnemies < wNum1){
						var a:Alien_Ship = new Alien_Ship(speed, horizontal);
						addChild(a);
						alien.push(a);
						numEnemies++;
						setAlienFire();
						setNextShip();
						
					}
					else{
						numEnemies = 0;
						setNextAsteroid();
						nextShip.stop();
						trace("rock wave: ", rWave);
					}
				
				}
				if (aWave == 2){
					if (numEnemies < wNum2){
						var a:Alien_Ship = new Alien_Ship(speed, horizontal);
						addChild(a);
						alien.push(a);
						numEnemies++;
						setAlienFire();
						setNextShip();
						
					}
					else{
						numEnemies = 0;
						setNextAsteroid();
						nextShip.stop();					
						trace("rock wave: ", rWave);
					}
				
				}
				if (aWave == 3){
					if (numEnemies < wNum3){
						var a:Alien_Ship = new Alien_Ship(speed, horizontal);
						addChild(a);
						alien.push(a);
						numEnemies++;
						setAlienFire();
						setNextShip();
						trace("rock wave: ", rWave);
						
					}
					else{
						numEnemies = 0;
						nextShip.stop();
						setNextAsteroid();
											
					}
				
				}
			}
			else if (curLevel == 2){
				wNum1 = 20;
				wNum2 = 25;
				wNum3 = 30;
				if (aWave == 1){
					
					if (numEnemies < wNum1){
						var a:Alien_Ship = new Alien_Ship(speed, horizontal);
						addChild(a);
						alien.push(a);
						numEnemies++;
						setAlienFire();
						setNextShip();
						
					}
					else{
						numEnemies = 0;
						setNextAsteroid();
						nextShip.stop();
					}
				}
				else if (aWave == 2){
					
					if (numEnemies < wNum2){
						var a:Alien_Ship = new Alien_Ship(speed, horizontal);
						addChild(a);
						alien.push(a);
						numEnemies++;
						setAlienFire();
						setNextShip();
						
					}
					else{
						numEnemies = 0;
						
						setNextAsteroid();
						nextShip.stop();
					}
				}
				else if (aWave == 3){
					
					if (numEnemies < wNum3){
						var a:Alien_Ship = new Alien_Ship(speed, horizontal);
						addChild(a);
						alien.push(a);
						numEnemies++;
						setAlienFire();
						setNextShip();
						
					}
					else{
						numEnemies = 0;
						
						setNextAsteroid();
						nextShip.stop();
					}
				}
		}
		else if (curLevel == 3){
			wNum1 = 30;
			wNum2 = 35;
			wNum3 = 40;
			if (aWave == 1){
				
				if (numEnemies < wNum1){
					var a:Alien_Ship = new Alien_Ship(speed, horizontal);
					addChild(a);
					alien.push(a);
					numEnemies++;
					setAlienFire();
					setNextShip();
					
				}
				else{
					numEnemies = 0;
					setNextAsteroid();
					nextShip.stop();
				}
			}
			
			else if (aWave == 2){
				
				if (numEnemies < wNum2){
					var a:Alien_Ship = new Alien_Ship(speed, horizontal);
					addChild(a);
					alien.push(a);
					numEnemies++;
					setAlienFire();
					setNextShip();
					
				}
				else{
					numEnemies = 0;
					
					setNextAsteroid();
					nextShip.stop();
					
				}
			}
			
			else if (aWave == 3){
				
				if (numEnemies < wNum3){
					var a:Alien_Ship = new Alien_Ship(speed, horizontal);
					addChild(a);
					alien.push(a);
					numEnemies++;
					setAlienFire();
					setNextShip();
					
				}
				else{
					numEnemies = 0;
					
					setNextAsteroid();
					nextShip.stop();
					
				}
			}						
		}
	}
		// create new asteroids
		public function newAsteroids(e:TimerEvent){
			var speedX:Number = Math.random() * 100 + 100;
			var speedY:Number = Math.random() * 100 + 100;
			
			// random side to spawn asteroids
			if(Math.random() > .5){
				var side:String = "left"
			}
			else{
				side = "right";
			}
			// random height to spawn asteroid above bottom of screen
			var altitude1:Number = Math.random() * (stage.stageHeight - (.25 * stage.stageHeight));
			var wNum1, wNum2, wNum3:int
				
			if (curLevel == 1){
				wNum1 = 10;
				wNum2 = 15;
				wNum3 = 20;
				if (rWave == 1){					
					if (numRocks < wNum1){
						var a1:Asteriod_2 = new Asteriod_2(speedX, speedY, side, altitude1);
						addChild(a1);
						asteroids.push(a1);
						numRocks++;
						setNextAsteroid();
						
					}
					else{
						aWave++;
						curWave++;
						rWave++;
						updateTextFields();
						numRocks = 0;
						setNextShip();
						nextAsteroid.stop();
						
						
					}
				}
				else if (rWave == 2){
					
					if (numRocks < wNum2){
						var a1:Asteriod_2 = new Asteriod_2(speedX, speedY, side, altitude1);
						addChild(a1);
						asteroids.push(a1);
						numRocks++;
						setNextAsteroid();
						
					}
					else{
						numRocks = 0;
						aWave++;
						curWave++;
						rWave++;
						updateTextFields();
						setNextShip();
						nextAsteroid.stop();
						
						
					}
				}
				else if (rWave == 3){
					
					if (numRocks < wNum3){
						var a1:Asteriod_2 = new Asteriod_2(speedX, speedY, side, altitude1);
						addChild(a1);
						asteroids.push(a1);
						numRocks++;
						setNextAsteroid();
						
					}
					else{
						numRocks = 0;
						aWave = 1;
						rWave = 1;
						curWave = 1;
						curLevel++;
						updateTextFields();
						setNextShip();
						nextAsteroid.stop();
						
					}						
				
			}
		}
		else if (curLevel == 2){
			wNum1 = 20;
			wNum2 = 25;
			wNum3 = 30;
			if (rWave == 1){					
					if (numRocks < wNum1){
						var a1:Asteriod_2 = new Asteriod_2(speedX, speedY, side, altitude1);
						addChild(a1);
						asteroids.push(a1);
						numRocks++;
						setNextAsteroid();
						
					}
					else{
						aWave++;
						rWave++;
						curWave++;
						updateTextFields();
						numRocks = 0;
						nextAsteroid.stop();
						setNextShip();
						
					}
				}
				else if (rWave == 2){
					
					if (numRocks < wNum2){
						var a1:Asteriod_2 = new Asteriod_2(speedX, speedY, side, altitude1);
						addChild(a1);
						asteroids.push(a1);
						numRocks++;
						setNextAsteroid();
						
					}
					else{
						numRocks = 0;
						aWave++;
						rWave++;
						curWave++;
						updateTextFields();
						setNextShip();
						nextAsteroid.stop();
					}
				}
				else if (rWave == 3){
					
					if (numRocks < wNum3){
						var a1:Asteriod_2 = new Asteriod_2(speedX, speedY, side, altitude1);
						addChild(a1);
						asteroids.push(a1);
						numRocks++;
						setNextAsteroid();
						
					}
					else{
						numRocks = 0;
						aWave = 1;
						rWave = 1;
						curWave = 1;
						curLevel++;
						updateTextFields();
						setNextShip();
						nextAsteroid.stop();
						
					}						
				
			}
		}
		else if (curLevel == 3){
				wNum1 = 30;
				wNum2 = 35;
				wNum3 = 40;
				if (rWave == 1){					
					if (numRocks < wNum1){
						var a1:Asteriod_2 = new Asteriod_2(speedX, speedY, side, altitude1);
						addChild(a1);
						asteroids.push(a1);
						numRocks++;
						setNextAsteroid();
						
					}
					else{
						aWave++;
						rWave++;
						curWave++;
						updateTextFields();
						numRocks = 0;
						nextAsteroid.stop();
						setNextShip();
						
					}
				}
				else if (rWave == 2){
					
					if (numRocks < wNum2){
						var a1:Asteriod_2 = new Asteriod_2(speedX, speedY, side, altitude1);
						addChild(a1);
						asteroids.push(a1);
						numRocks++;
						setNextAsteroid();
						
					}
					else{
						numRocks = 0;
						aWave++;
						rWave++;
						curWave++;
						updateTextFields();
						setNextShip();
						nextAsteroid.stop();
					}
				}
				else if (rWave == 3){
					
					if (numRocks < wNum3){
						var a1:Asteriod_2 = new Asteriod_2(speedX, speedY, side, altitude1);
						addChild(a1);
						asteroids.push(a1);
						numRocks++;
						setNextAsteroid();
						
					}
					else{
						setWinTimer();
					}
					
				
			}
					
				
			
		}
	}

		
/********************************************************************************************************************************************************************/		
	
		// fire lasers
		public function fireLaser(e:Event){
			
			var channel:SoundChannel = (new Laser()).play();
			var l:Lasers = new Lasers(player.x + player.width/2,player.y, -300,1, player);
			addChild(l);
			playerLasers.push(l);
			laserTimer();
		
							
			
		}
		// fire alien lasers
		public function fireAlienLasers(e:Event){
			
			if (alienLasers.length <= 1){
				for (var i in alien){
					var l:Lasers = new Lasers(alien[i].x ,alien[i].y, 300,2, player);
					addChild(l);
					alienLasers.push(l);
					var channel:SoundChannel = (new Laser()).play();
				}
					
			}
			
			setAlienFire();
			
							
			
		}
		
		// remove asteroid from list
		public function removeAsteroid(a:Asteriod_2){
			for (var i in asteroids){
				if (a == asteroids[i]){
					asteroids.splice(i,1);
					numAsteroids--;
					break;
				}
			}
		}
		// remove ship from list
		public function removeShip(ship:Alien_Ship){
			for (var i in alien){
				if (ship == alien[i]){
					alien.splice(i,1);
					break;
				}
			}
		}
		// remove laser from list
		public function removeLaser(laser:Lasers){
			for (var i in playerLasers){
				if (laser == playerLasers[i]){
					playerLasers.splice(i,1);
					break;
				}
			}
		}
		// remove laser from list
		public function removeAlienLasers(laser:Lasers){
			for (var i in alienLasers){
				if (laser == alienLasers[i]){
					alienLasers.splice(i,1);
					break;
				}
				
			}
		}
		
		
		// capture mouse button held down
		public function mouseDown(e:MouseEvent){
			// listen for mouse button release
			stage.addEventListener(MouseEvent.MOUSE_UP, mouseUp);
			// set timer for laser delay
			laserTimer();
		}
		// capture mouse button released
		public function mouseUp(e:MouseEvent){
			
			stage.removeEventListener(MouseEvent.MOUSE_UP,mouseUp);
			stage.removeEventListener(Event.ENTER_FRAME,fireLaser);
			laserDelay.stop();
		}
		
		// restart collision detection
		public function immuneGone(e:TimerEvent){
			stage.addEventListener(Event.ENTER_FRAME, alienPlayerCollision);
			stage.addEventListener(Event.ENTER_FRAME, alienLaserPlayerCollision);
			stage.addEventListener(Event.ENTER_FRAME, asteroidPlayerCollision);
			immuneTimer.stop();
		}
		
		//*****************************************************************************************************
		
		// collision detection functions **********************************************************************
		
		
		
		
		public function laserAlienCollision(e:Event){
			// check to see if a laser hit an alien
			for(var l:int = playerLasers.length-1; l >= 0; l--){
				for(var a:int = alien.length-1; a >= 0; a--){
					if (playerLasers[l].hitTestObject(alien[a])){
						playerLasers[l].deleteLasers();
						alien[a].shipHit();
						if (alienBonus == 1){
							curScore += 10;
							alienBonus++;
							
						}else{
							curScore += alienBonus * 10;
							alienBonus++;
						}
						updateTextFields();
						var channel:SoundChannel = (new explosion()).play();
					}
				}
			}
		}
		
		public function alienPlayerCollision(e:Event){
			// check to see if an alien hit the player
			for (var b:int = alien.length-1; b >= 0; b--){
				if(player.hitTestObject(alien[b])){
					playerHP.scaleX -= .05;
					
					if(playerHP.scaleX <= 0){
						playerHP.scaleX = 0;
						player.shipHit();
						alien[b].shipHit();
						var channel:SoundChannel = (new explosion()).play();
						curLives--;	
						updateTextFields();
						
						if(curLives > 0){
							playerHP.scaleX = 1;						
							player = new Player_Ship;
							stage.addChild(player);
							stage.removeEventListener(Event.ENTER_FRAME, alienPlayerCollision);
							setImmuneTimer();
						}
						else if (curLives <= 0){
							
							setDefeatTimer();
						}
					}
				}
			}	
		}
		public function alienLaserPlayerCollision(e:Event){
			// check to see if alien laser hits player
			for (var a:int = alienLasers.length -1; a >= 0; a--){
				if(alienLasers[a].hitTestObject(player)){
					playerHP.scaleX -= .05;
					if(playerHP.scaleX <= 0){
						playerHP.scaleX = 0;
						player.shipHit();
						alienLasers[a].deleteAlienLasers();
						var channel:SoundChannel = (new explosion()).play();
						curLives--;
						updateTextFields();
						if(curLives > 0){
							playerHP.scaleX = 1;						
							player = new Player_Ship;
							stage.addChild(player);
							stage.removeEventListener(Event.ENTER_FRAME, alienLaserPlayerCollision);
							setImmuneTimer();
						}
						else if (curLives <= 0){
							
							setDefeatTimer();
						}
					}
					
				}
			}
		}


		
		public function laserAsteroidCollision(e:Event){
			// check to see if a laser hit an asteroid
			for(var l:int = playerLasers.length-1; l >= 0; l--){
				for(var a:int = asteroids.length-1; a >= 0; a--){
					if (playerLasers[l].hitTestObject(asteroids[a])){
						playerLasers[l].deleteLasers();
						asteroids[a].rockHit();
						numAsteroids--;
						if (asteroidBonus == 1){
							curScore += 10;
							asteroidBonus++;
							
						}else{
							curScore += asteroidBonus * 10;
							asteroidBonus++;
						}
						updateTextFields();
						var channel:SoundChannel = (new explosion()).play();
						
						
					}
						
				}
			}
		}
		
		public function asteroidAlienCollision(e:Event){
			// check to see if an asteroid hit an alien
			for(var l:int = asteroids.length-1; l >= 0; l--){
				for(var a:int = alien.length-1; a >= 0; a--){
					if (asteroids[l].hitTestObject(alien[a])){
						asteroids[l].rockHit();
						alien[a].shipHit();
						numAsteroids--;
						var channel:SoundChannel = (new explosion()).play();
					}
						
				}
			}
		}
		
		public function asteroidPlayerCollision(e:Event){
			// check to see if an asteroid hit the player
			for (var b:int = asteroids.length-1; b >= 0; b--){
				if(player.hitTestObject(asteroids[b])){
					playerHP.scaleX -= .05;
					if (playerHP.scaleX <= 0){
						playerHP.scaleX = 0;
						player.shipHit();
						var channel:SoundChannel = (new explosion()).play();
						curLives--;
						updateTextFields();
						if(curLives > 0){
							playerHP.scaleX = 1;						
							player = new Player_Ship();
							stage.addChild(player);
							stage.removeEventListener(Event.ENTER_FRAME, asteroidPlayerCollision);
							setImmuneTimer();
						}
						else if (curLives <= 0){
							
							setDefeatTimer();
						}
					}
			
				}
			}
		}
		//*************************************************************************************************************************************************
		
		// text field functions ***************************************************************************************************************************
		public function setupTextFields(){
			
			
			tFormat = new TextFormat();
			tFormat.color = 8002352;
			tFormat.bold = true;
			tFormat.size = 20;
			
			
			
			score = new TextField();			
			score.x =  .80 * stage.stageWidth;
			score.y =  5;
			score.defaultTextFormat = tFormat;
			score.autoSize = "left";
			
			
		
			lives = new TextField();
			lives.x = 5
			lives.y = stage.stageHeight - 25;
			lives.defaultTextFormat = tFormat;
			
			
			level = new TextField();
			level.x = .80 * stage.stageWidth;
			level.y = stage.stageHeight -25;
			level.defaultTextFormat = tFormat;
						
			wave = new TextField();
			wave.x = 5;
			wave.y = 5;
			wave.defaultTextFormat = tFormat;
			
			health = new TextField();
			health.x = stage.stageWidth/2 - 200;
			health.y = stage.stageHeight - 25;
			health.defaultTextFormat = tFormat;
			
			score.text = "Score: " + String(curScore);
			lives.text = "Lives: " + String(curLives);
			level.text = "Level: " + String(curLevel);
			wave.text = "Wave: " + String(curWave);
			health.text = "Health: "
			
			
		}
		
		public function updateTextFields(){
			
			score.text = "Score: " + String(curScore);
			if (curLives > 0){
				lives.text = "Lives: " + String(curLives);
			}
			else{
				lives.text = "Lives: " + 0;
			}
			level.text = "Level: " + String(curLevel);
			wave.text = "Wave: " + String(curWave);
			
			
		}
		
			
	//*************************************************************************************************************************************************		
		
		
		// win game screen
		public function winGame(e:TimerEvent){
			winTimer.stop()
			// show victory screen
			gotoAndStop("Win");
			
			// stop spawning enemies
			nextShip.stop();
			nextAsteroid.stop();
			winTimer.stop();
			
			// show final score
			score.x = stage.stageWidth/2 - 60;
			score.y = stage.stageHeight/2 - 20;
			score.text = "Score: " + String(curScore);
			
			removeChild(lives);
			removeChild(level);
			removeChild(wave);
			removeChild(player);
			removeChild(playerHP);
			removeChild(health);
			playerHP = null;
			nextShip = null;
			nextAsteroid = null;
			laserDelay = null;
			player = null;
			alien = null;
			playerLasers = null;
			asteroids = null;
			stage.removeEventListener(MouseEvent.MOUSE_DOWN, mouseDown);
			stage.removeEventListener(Event.ENTER_FRAME, laserAlienCollision);
			stage.removeEventListener(Event.ENTER_FRAME, alienPlayerCollision);
			stage.removeEventListener(Event.ENTER_FRAME, laserAlienCollision);
			stage.removeEventListener(Event.ENTER_FRAME, asteroidPlayerCollision);
			stage.removeEventListener(Event.ENTER_FRAME, laserAsteroidCollision);
			stage.removeEventListener(Event.ENTER_FRAME, alienLaserPlayerCollision);
			stop();
		}
		
		// end game 
		public function endGame(e:TimerEvent){
			gotoAndStop("Lose");
			
			// stop music
			channel.stop();
			// stop spawing enemies
			nextShip.stop();
			nextAsteroid.stop();
			defeatTimer.stop();
			
			
			
			
			
			
			playerHP = null
			nextShip = null;
			nextAsteroid = null;
			laserDelay = null;
			player = null;
			alien = null;
			playerLasers = null;
			asteroids = null;
			stop();
			stage.removeEventListener(MouseEvent.MOUSE_DOWN, mouseDown);
			
			
			
			
			
		}
		
		
				
		
		
	}
}