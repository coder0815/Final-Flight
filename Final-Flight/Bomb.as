package  {
	
	import flash.display.MovieClip;
	import flash.utils.getTimer;
	
	
	public class Bomb extends MovieClip {
		
		// speed and direection
		private var dy:Number; 
		
		// animation timer
		private var lastTimeCount:int;
		
		public function Bomb(speed:Number, x,y:int) {
			// set up bomb location and speed
			this.x = x;
			this.y = y;
			dy = speed;
		}
		
		// move bomb
		public function moveBomb(){
			var timePassed:int = getTimer() - lastTimeCount;
			lastTimeCount += timePassed;
			
			this.y += dy * timePassed / 1000;
		}
		
		// remove bomb if off screen
		public function bombBoundaries(){
			
			if(this.y + this.height/2 > stage.stageHeight){
				this.deleteBomb();
			}
		}
		
		// delete bomb
		public function deleteBomb(){
			
			parent.removeChild(this);
		}
	}
	
}
