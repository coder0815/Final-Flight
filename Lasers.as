package  {
	
	import flash.display.*;
	import flash.events.*;
	import flash.utils.getTimer;
	import Final_Flight;
	
	public class Lasers extends MovieClip {
		
		private var dy:Number; // vertical speed
		private var dx:Number; // horizontal speed
		private var lastTime:int; // time for animation of lasers
		private var typeOfLaser:int;  // holds the type of laser, 1 for player, 2 for alien
		private var tShip:Player_Ship;	// target for getting angles for alien lasers
		
		public function Lasers(x, y :Number, speed: Number, laserType:int, ship:Player_Ship) {
			
			
			
			//set the starting position for the lasers
			this.x = x; 
			this.y = y;
		
			// speed of the lasers movement
			dy = speed;
			
			// get the type of laser being created
			typeOfLaser = laserType;
			this.gotoAndStop(typeOfLaser);
			
			if (laserType == 1){
				// prepare animation sequence
				lastTime = getTimer();
				addEventListener(Event.ENTER_FRAME, moveLasers);
			}
			else {
				tShip = ship
				// prepare animation sequence
				lastTime = getTimer();
				addEventListener(Event.ENTER_FRAME, moveAlienLasers);
			}
		}
		
		
		
		
		public function moveLasers(e:Event){
			
			// get time passed 
			var timePassed:int = getTimer() - lastTime;
			lastTime += timePassed;
			
			// move the lasers
			this.y += dy * timePassed / 1000;
			
			// laser goes past top of screen
			if(this.y  < 0) {
				deleteLasers();
			}
			// laser goes past bottom of the screen
			if (this.y > stage.stageHeight){
				deleteLasers();
			}
			
			
			
		}
		
		public function moveAlienLasers(e:Event){
				
			
			
			
			
			var timePassed:int = getTimer() - lastTime;
			lastTime += timePassed;
			
			// move the lasers
			this.y += dy * timePassed / 1000;
			
			
			// check boundaries
			if(this.y < 0) {
				deleteAlienLasers();
			}
			if(this.y > stage.stageHeight){
				deleteAlienLasers();
			}
		}
		
		// delete lasers from the stage and list
		public function deleteLasers(){
			
			MovieClip(parent).removeLaser(this);
			parent.removeChild(this);
			removeEventListener(Event.ENTER_FRAME, moveLasers);
		}
		public function deleteAlienLasers(){
			MovieClip(parent).removeAlienLasers(this);
			parent.removeChild(this);
			removeEventListener(Event.ENTER_FRAME, moveAlienLasers);
		}
	}
	
}
