package{

	import org.flixel.*;
	import flash.ui.Keyboard;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	
	public class LittleJoe extends FlxSprite{
	
		//media
		//graphics
		[Embed(source="Visual/LittleJoe.png")] 			private var ImgLittleJoe:Class;
		
		//sound
//		[Embed(source="Audio/Jump.wav.mp3")]			private var SfxJump:Class;
		
		//Action Timer - So you can't cheat or whatever
		private var ActionTimer:Number = 0;
		private var Recovery:Number		= 2.5;
		
		//Current Action
		public var CurrentAction:uint = 0;
		
		//I changed my mind about punches. Do it like this
		private var OrigX:Number;
		
		//constructor
		public function LittleJoe(X:Number = 0, Y:Number = 0){
			super(X,Y);
			loadGraphic(ImgLittleJoe,true,true,48, 80);
			OrigX = x = FlxG.width/2 - width/2;
			y = FlxG.height - height;
			
			//create animations
			addAnimation("Idle", 	[0, 1], 5,	true);
			addAnimation("LeftPunch", [3], 0, false);
			addAnimation("LeftDodge", [5], 0, false);
			addAnimation("RightPunch", [2], 0, false);
			addAnimation("RightDodge", [4], 0, false);
			
			//Done
			play("Idle");
		}
		
		
		//update
		public override function update():void{
			if(ActionTimer > 0){
				ActionTimer -= FlxG.elapsed*Recovery;
				if(ActionTimer <= 0){
					CurrentAction = 0;
					play("Idle");
					x = OrigX;
				}
			}else{
				PlayerControls();
			}
			super.update();
		}
		
		private function PlayerControls():void{
			//Punching
			if(FlxG.keys.justPressed("Z")){
				if(FlxG.keys.UP){
					//Left Hook
					FlxG.log("Left Hook");
					x = OrigX - 13;
					play("LeftPunch");
					ActionTimer = .5;
					CurrentAction = 1;
				}else{
					//Left Jab
					FlxG.log("Left Jab");
					x = OrigX + 3;
					play("LeftPunch");
					ActionTimer = .5;
					CurrentAction = 2;
				}
			}else if(FlxG.keys.justPressed("X")){
				if(FlxG.keys.UP){
					//Right Hook
					FlxG.log("Right Hook");
					x = OrigX + 13;
					play("RightPunch");
					ActionTimer = .5;
					CurrentAction = 4;
				}else{
					//Right Jab
					FlxG.log("Right Jab");
					x = OrigX - 3;
					play("RightPunch");
					ActionTimer = .5;
					CurrentAction = 3;
				}
			}
			
			//Dodging
			if(FlxG.keys.justPressed("LEFT")){
				//Duck Left
				FlxG.log("Duck Left");
				CurrentAction = 5;
				ActionTimer = .5;
				x = OrigX - 13;
				play("LeftDodge");
			}else if(FlxG.keys.justPressed("RIGHT")){
				//Duck Right
				FlxG.log("Duck Right");
				CurrentAction = 6;
				x = OrigX + 13;
				ActionTimer = .5;
				play("RightDodge");
			}else if(FlxG.keys.justPressed("DOWN")){
				//Block
				FlxG.log("Block");
				CurrentAction = 7;
//				ActionTimer = .5;
			}
		}
	}
}
