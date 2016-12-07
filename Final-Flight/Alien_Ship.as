package  {
	
	import flash.display.*;
	import flash.events.*;
	import flash.utils.getTimer;
	
	
	public class Alien_Ship extends MovieClip {
		
		private var dy:Number; // speed and direction
		private var lastTime:int; // animation time
		
		public function Alien_Ship(speed:Number, horizontal:Number) {
			
			this.x = horizontal; // horizontal position
			this.y = -50;	// vertical starting point
			dy = speed;	// speed
			
			// choose a random ship
			this.gotoAndStop(Math.floor(Math.random() * 3 + 1));
			
			// set up animation
			addEventListener(Event.ENTER_FRAME, moveShip);
			lastTime = getTimer();
		}
		
		public function moveShip(e:Event){
			// get time passed
			var timePassed:int = getTimer() - lastTime;
			lastTime += timePassed;
			
			// move ship
			this.y += dy * timePassed / 1000;
			
			
			// check to see if off screen
			if (y > stage.stageHeight){
				deleteShip();
			}
			
			
		}
		
		// delete ship from stage and list
		public function deleteShip(){
			MovieClip(parent).removeShip(this);
			parent.removeChild(this);
			removeEventListener(Event.ENTER_FRAME, moveShip);
		}
		
		// ship hit, show explosion
		public function shipHit(){
			removeEventListener(Event.ENTER_FRAME, moveShip);
			MovieClip(parent).removeShip(this);
			gotoAndPlay("dead");
		}
	}

	
}
