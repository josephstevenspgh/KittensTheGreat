package{
	import org.flixel.*; 

 
	public class GameState extends FlxState{
		[Embed(source="Title.png")] protected var ImgTitleBG:Class;
	
		private var BackgroundGroup:FlxGroup;
		private var TitleGroup:FlxGroup;
	
		override public function create():void{	
			initGame();
		}
		
		private function Continue():void{
			//Difficulties: 1-3 easy - med - hard
			//for now just do hard
			var NextStage:GameStage = new GameStage(3);
			FlxG.switchState(NextStage);
		}
		
		
		//this is the update() function
		override public function update():void{		
			if(FlxG.keys.justPressed("X")){
				Continue();
			}
			super.update();
		}
		
		protected function initGame():void{
		
			//Group Initialization
			BackgroundGroup	= new FlxGroup();
			BackgroundGroup.add(new FlxSprite(0, 0, ImgTitleBG));
			//create background
			
			TitleGroup = new FlxGroup();
			var asdf:FlxText = new FlxText(0, FlxG.height - 32, FlxG.width, "Kill all humans, so you can sleep in peace");
			asdf.alignment = "center";
			asdf.shadow = 0xFF000000;
			asdf.color = 0xFFCCCCFF;
			TitleGroup.add(asdf);
			asdf = new FlxText(0, FlxG.height - 20, FlxG.width, "http://www.splixel.com");
			asdf.alignment = "center";
			asdf.shadow = 0xFF000000;
			asdf.color = 0xFFCCCCFF;
			TitleGroup.add(asdf);
			asdf = new FlxText(0, FlxG.height/2 + 50, FlxG.width, "Press X to start");
			asdf.alignment = "center";
			asdf.color = 0xFFFFEEDD;
			asdf.shadow = 0xFF000000;
			asdf.size = 16;
			TitleGroup.add(asdf);
			
			add(BackgroundGroup);
			add(TitleGroup);
		}		
	}
}
