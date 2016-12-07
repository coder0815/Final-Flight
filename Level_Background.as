package  {
	
	import flash.display.MovieClip;
	
	
	public class Level_Background extends MovieClip {
		
		
		public function Level_Background() {
			// constructor code
		}
		public function deleteBackground(){
			parent.removeChild(this);
		}
	}
	
}
