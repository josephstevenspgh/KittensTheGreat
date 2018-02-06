package{

	import org.flixel.*;
	import flash.ui.Keyboard;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	
	public class PunchCard extends FlxSprite{
	
		//graphics
		[Embed(source="Visual/PunchCardBG.png")] 			private var ImgPunchCard:Class;
		[Embed(source="Visual/PunchCardIcons.png")] 		private var ImgPunchCardIcons:Class;
		//sound
		[Embed(source="Audio/GoodHit.mp3")]			protected var SfxGoodHit:Class;
		[Embed(source="Audio/MissHit.mp3")]			protected var SfxMissHit:Class;
		
		//sound
//		[Embed(source="Audio/Jump.wav.mp3")]			private var SfxJump:Class;

		//Icon Arrays
		private var Stage1Icons:Array = new Array(
			1, 3, 4, 2, 1, 3, 1, 2, 3, 2, 
			1, 3, 1, 4, 4, 3, 3, 2, 3, 4, 
			1, 4 ,2 ,1 ,1 ,1 ,2, 2, 1, 2, 
			1, 1, 2, 2, 3, 3, 4, 4, 3, 3,
			2, 2, 1, 1, 2, 3, 4, 3, 2, 4,
			2, 3, 1, 3, 2, 2, 4, 1, 3, 2,
			3, 4, 1, 2, 2, 2, 3, 3, 2, 1,
			4, 4, 1, 1, 3, 3, 2, 2, 3, 2);
		
		private var CurrentStage:Array;
		public var FullCard:FlxSprite;
		
		//Pause
		private var Paused:Boolean = false;
		public var Ready:Boolean = false;
		private var StageStarted:Boolean = false;
		private var PID:uint;
		
		//Stage Speed
		private var speed:uint	= 60;
		
		//constructor
		public function PunchCard(PunchCardID:uint = 0){
			super(0,0);
			FullCard = new FlxSprite();
			CurrentStage = GetCurrentStage();
			PID = PunchCardID;
			var NewHeight:uint = CurrentStage.length;
			FullCard.makeGraphic(5*16, NewHeight*16, 0x00ffffff);
			makeGraphic(5*16, NewHeight*16, 0x00ffffff);
			x = FlxG.width/2 - width/2;
			y = FlxG.height - height - 8 - NewHeight*16;
			CreateBlankSlate();
			CreateIcons();
			stamp(FullCard, 0, 0);
		}
		
		public function Hit(Area:uint):Boolean{
			//This function throws a hit to punch card
			//1 - 4 for the different punches
			if(Ready){				
				if(Area == Stage1Icons[(height/16) - 1]){
					makeGraphic(width, height-16, 0x00FFFFFF);
					stamp(FullCard, 0, 0);
					Ready = false;
					FlxG.play(SfxGoodHit);
					return true;
				}
			}
			return false;
		}
		
		private function CreateIcons():void{
			var StampySprite:FlxSprite = new FlxSprite();
			StampySprite.loadGraphic(ImgPunchCardIcons, false, false, 16);
			for(var i:uint = 0; i < CurrentStage.length; i++){
				switch(CurrentStage[i]){
					case 1:
						StampySprite.frame = 0;
						FullCard.stamp(StampySprite, 8, i*16+1);
						break;
					case 2:
						StampySprite.frame = 1;
						FullCard.stamp(StampySprite, 8+16, i*16+1);
						break;
					case 3:
						StampySprite.frame = 2;
						FullCard.stamp(StampySprite, 8+32, i*16+1);
						break;
					case 4:
						StampySprite.frame = 3;
						FullCard.stamp(StampySprite, 8+48, i*16+1);
						break;
				}
			}			
		}
		
		private function CreateBlankSlate():void{
			//Do top row first
			var StampySprite:FlxSprite = new FlxSprite();
			StampySprite.loadGraphic(ImgPunchCard, false, false, 16, 16);
			StampySprite.frame = 0;
			FullCard.stamp(StampySprite, 0, 0);
			StampySprite.frame = 1;
			FullCard.stamp(StampySprite, 16, 0);
			FullCard.stamp(StampySprite, 32, 0);
			FullCard.stamp(StampySprite, 48, 0);
			StampySprite.frame = 2;
			FullCard.stamp(StampySprite, 64, 0);
			
			//Now, do ALL THE ROWS
			for(var i:uint = 1; i < CurrentStage.length; i++){
				StampySprite.frame = 3;
				FullCard.stamp(StampySprite, 0, i*16);
				StampySprite.frame = 4;
				FullCard.stamp(StampySprite, 16, i*16);
				FullCard.stamp(StampySprite, 32, i*16);
				FullCard.stamp(StampySprite, 48, i*16);
				StampySprite.frame = 5;
				FullCard.stamp(StampySprite, 64, i*16);
			}
		}
		
		private function GetCurrentStage():Array{
			switch(PID){
				case 1:
					return Stage1Icons;
				default:
					return Stage1Icons;
			}
		}
		
		
		//update
		public override function update():void{
			if(!Paused){
				if(!StageStarted){
					y += FlxG.elapsed*speed*10;
				}
				if (y+height < 189){
					y += FlxG.elapsed*speed;
					Ready = false;
				}else{
					StageStarted = true;
					Ready = true;
				}
			}
			super.update();
		}
	}
}
