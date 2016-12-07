package  {
	
	import flash.display.*;
	import flash.events.*;
	import flash.utils.Timer;
	import Lasers;
	
	public class Player_Ship extends MovieClip {
		
		
		public function Player_Ship() {
			
			this.gotoAndStop("alive");
			// listen for mouse movement each frame and move ship
			this.addEventListener(Event.ENTER_FRAME, movePlayer);
			
			

			
			
		}
		
		// this function handles moving the player ship
		public function movePlayer(e:Event){
			this.x = stage.mouseX;
			this.y = stage.mouseY;
			
			// check boundaries
			
			if ( this.x > stage.stageWidth){
				this.x = stage.stageWidth - 50;
			}
			
			if(this.x  < 0) {
				this.x = 0 + this.width / 2;
			}
			if (this.y > stage.stageHeight){
				this.y = 60;
			}
			if (this.y < 0){
				this.y = 0;
			}
			
		}
		
		
		
		// delete player ship
		public function deletePlayer():void{
			
			parent.removeChild(this);
			removeEventListener(Event.ENTER_FRAME, movePlayer);
			
		}
		
		// ship hit, show explosion
		public function shipHit(){
			removeEventListener(Event.ENTER_FRAME, movePlayer);
			gotoAndPlay("dead");
		}
		
		
	}
	
}
