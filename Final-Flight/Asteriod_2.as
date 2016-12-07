package  {
	
	import flash.display.*;
	import flash.utils.getTimer;
	import flash.events.Event;
	
	public class Asteriod_2 extends MovieClip {
		
		private var dx:Number; // speed and direction
		private var dy:Number; // speed and direction
		
		private var lastTimeCount:int;	// animation of asteroids
		private var leftSide:Boolean;	// left side of screen
		private var rightSide:Boolean; // right side of screen
		private var bounceX:int; // how many times has it bounced horizontally
		private var bounceY:int; // how many times has it bounced vertically
		
		public function Asteriod_2(speedX, speedY:Number, side:String, altitude:int) {
			
			// set up intitial asteroid speed and coordinates and size
			this.scaleX = this.scaleY = Math.random() * 3 + .25;
			
			
			if (side == "right"){
				this.x = 649.5;
				dx = -speedX;
				dy = speedY;
				
			}
			if(side == "left"){
				this.x = 0.5;
				dx = speedX;
				dy = speedY;
			}
			this.y = altitude;
			
			// choose a random asteroid
			this.gotoAndStop(Math.floor(Math.random()*2 + 1));
			
			lastTimeCount = getTimer();
			this.addEventListener(Event.ENTER_FRAME, moveAsteroid);
		}
		
		// movement for asteroids
		public function moveAsteroid(e:Event){
			
			var timePassed:int = getTimer() - lastTimeCount;
			lastTimeCount += timePassed;
			
			 
			this.x += dx * timePassed / 1000;
			this.y += dy * timePassed / 1000;	
			
			
			// check asteroid boundaries; do not let it go off screen unless they have bounced off walls at least 3 times
			if (this.x < 0){
				dx = -dx;
				bounceX++;
				if (bounceX >= 3 && bounceY >= 3){
					deleteAsteroid();
				}
			}
			else if (this.x > stage.stageWidth){
				dx = -dx;
				bounceX++;
				if (bounceX >= 3 && bounceY >= 3){
					deleteAsteroid();
				}
			}
			else if (this.y < 0){
				dy = -dy;
				bounceY++;
				if (bounceX >= 3 && bounceY >= 3){
					deleteAsteroid();
				}
			}
			else if (this.y > stage.stageHeight){
				dy = -dy;
				bounceY++;
				if (bounceX >= 3 && bounceY >= 3){
					deleteAsteroid();
				}
			}
			
		}
		
		
		
		// delete asteroid
		public function deleteAsteroid(){
			MovieClip(parent).removeAsteroid(this);
			parent.removeChild(this);
			this.removeEventListener(Event.ENTER_FRAME, moveAsteroid);
		}
		// ship hit, show explosion
		public function rockHit(){
			this.removeEventListener(Event.ENTER_FRAME, moveAsteroid);
			MovieClip(parent).removeAsteroid(this);
			gotoAndPlay("dead");
		}
	}
	
}
