package{
	import org.flixel.*;

 
	public class GameStage extends FlxState{
	
		//Level Map
		[Embed(source="BoardMapmap001.txm",	mimeType="application/octet-stream")]	protected var Map_Data:Class;
		[Embed(source="BoardMapmap002.txm",	mimeType="application/octet-stream")]	protected var MapBG_Data:Class;
		[Embed(source="BoardMaptiles.png")]											protected var GfxTiles:Class;
		[Embed(source="Winthegame.png")]											protected var WinGFX:Class;
		[Embed(source="Visual/Player1.png")]										protected var PlayerImg:Class;
		[Embed(source="Visual/PEOPLES.png")]										protected var PeopleImg:Class;
		[Embed(source="Visual/BattleBackdrop.png")]									protected var BattleBGImg:Class;
		
		//Thinking about doing difficulty levels or alternative stages
		private var StageNumber:uint = 0;

		private var MaxKitties:uint			= 30;
		
		//Groups/Layers/Sprites
		private var BackgroundLayer:FlxGroup;
		private var PlayerLayer:FlxGroup;
		private var ShopLayer:FlxGroup;
		private var BattleLayer:FlxGroup;
		private var Player:FlxSprite;
		private var MapTM:FlxTilemap;
		private var GameStatus:FlxText;
		private var PlayerStatus:FlxText;
		
		//battle shit
		private var BattleNumber:uint		= 1;
		private var BattleStarted:Boolean	= false;
		private var BattleLayer1:FlxGroup;
		private var BattleLayer2:FlxGroup;
		private var BattleLayer3:FlxGroup;
		private var KittyLayer:FlxGroup;
		private var BattleInputReady:Boolean= false;
		private var BattleStatus:String		= "i like eggs";
		private var EnemyArmySize:uint		= 0;
		
		//player stats
		private var MaxDiceRoll:uint 		= 3;
		private var PlayerStrength:Number	= 1;
		private var PlayerArmySize:uint		= 1;
		private var PlayerMoney:uint		= 0;
		private var MoneyMultiplier:Number	= 1;
		private var PlayerLevel:uint		= 1;
		private var PlayerExp:uint			= 0;
		
		//shop shit
		private var ArmyCost:uint			= 500;
		private var StrengthCost:uint		= 1000;
		
		
		//Tile Data
		private var MapWidth:uint			= 0;
		private var MapHeight:uint			= 0;
		private var LastMovedDirection:String;
		private var LastThreeSpaces:Array;
		private var LastRandom:String		= "Not Last Three";
		private var MovingBackwards:Boolean	= false;
		private var ThirdSpaceBackLastDirection:String = "WAT";
		
		//Gameplay Variables
		private var ReadyForInput:Boolean 	= false;
		private var DiceRolled:Boolean		= false;
		private var DiceNumber:uint			= 0;
		private var CurrentGameState:String = new String("This text is unused");
		private var CanGoUp:Boolean			= false;
		private var CanGoDown:Boolean		= false;
		private var CanGoLeft:Boolean		= false;
		private var CanGoRight:Boolean		= false;
		private var NewX:uint				= 0;
		private var NewY:uint				= 0;

		public function GameStage(StageNum:uint = 0):void{
			StageNumber = StageNum;
		}
		
		override public function create():void{
			initGame();
		}			
		
		
		//this is the update() function
		override public function update():void{
			//army size cap
			if(PlayerArmySize > MaxKitties){
				PlayerArmySize = MaxKitties;
			}			
			if(ReadyForInput){
				//Do Input
				PlayerInput();
			}else{
				switch(CurrentGameState){
					case "Movement":
						DoMovement();
						break;
					case "Get Money":
						GameStatus.text = "Press X to collect catnip.";
						DoMoneyGet();
						break;
					case "Buy Things":
						GameStatus.text = "Press X To Open Shop!";
						DoShop();
						break;
					case "BATTLE TIME YO":
						if(!BattleStarted){
							GameStatus.text = "Press X To FIGHT!";
						}
						DoBattle();
						break;
					case "Random":
						GameStatus.text = "Press X To Decide your fate!";
						DoRandom();
						break;
					case "Army Recruits":
						GameStatus.text = "Press X To recruit kitten warriors!";
						DoArmyRecruit();
						break;
					case "Training":
						GameStatus.text = "Press X To get stronger!";
						DoTraining();
						break;
						
					//These are all the random events
					case "Back Three Spaces":
						GameStatus.text = "Go Back Three Spaces";
						BackThreeSpaces();
						break;
					case "Gamble Strength":
						GameStatus.text = "GAMBLE THAT STRONGTH YO";
						break;
					case "Gamble Army":
						GameStatus.text = "Get ALL THE CATS";
						
						break;
					case "Gamble Money":
						GameStatus.text = "Double or Halve your catnip!";
						break;
						
				}
			}
			super.update();
		}
		
		
		private function DoArmyRecruit():void{
			Player.play("Happy");
			if(!DiceRolled){
				if(FlxG.keys.justPressed("X")){
					RollDice();
					PlayerArmySize++;
					GameStatus.text = "Your army size has increased by 1! Press X to continue";
					DiceRolled = false;
					ReadyForInput = true;
					UpdatePlayerStatus();
					Player.play("Neutral");
				}
			}
		}
		
		private function AdjustExp():void{
			switch(PlayerLevel){
				default:
					PlayerLevel = 1;
					PlayerExp	= 0;
					break;
				case 2:
					PlayerExp	= 10;
					break;
				case 3:
					PlayerExp	= 30;
					break;
				case 4:
					PlayerExp	= 60;
					break;
			}
		}
		
		private function DoBattle():void{
			if(!BattleStarted){
				//BATTLE SHIT HERE YO
				if(BattleLayer.members[0].alpha == 0){
					if(FlxG.keys.justPressed("X")){
						ShowBattleLayer();
						BattleStarted = true;
						initBattle();
						GameStatus.text = "Press X to attack";
					}
				}
			}else{
				//battle logic
				if(BattleInputReady){
					if(FlxG.keys.justPressed("X")){
						//ROLL THOSE DICE!
						RollDice();
						var EnemyRoll:uint = DiceNumber;
						RollDice();
						var PlayerRoll:uint = uint(DiceNumber * PlayerStrength * (1 + (PlayerLevel+.2)));
						
						//compare enemy and player rolls
						if(EnemyRoll > PlayerRoll){
							//Enemy won!
							PlayerArmySize--;
							//update kitties
							for(var i:uint = 0; i < KittyLayer.length; i++){
								KittyLayer.members[i].alpha = 0;
							}
							for(i = 0; i < PlayerArmySize; i++){
								KittyLayer.members[i].alpha = 1;
							}
							GameStatus.text = "You lost that round. X to Attack";
							if(PlayerArmySize < 1){
								BattleStatus = "Lose";
							}
						}else if(PlayerRoll > EnemyRoll){
							GameStatus.text = "You Damaged the enemy. Press X to Attack!";
							//you won the game! kinda
							switch(BattleNumber){
								case 1:
									//only one enemy, so win by default
									BattleStatus = "win";
									break;
								case 2:
									if(EnemyArmySize > 1){
										EnemyArmySize--;
										//update enemy armies
										for(i = 0; i < BattleLayer2.length; i++){
											BattleLayer2.members[i].alpha = 0;											
										}
										for(i = 0; i < EnemyArmySize; i++){
											BattleLayer2.members[i].alpha = 1;
										}
									}else{
										//win!
										BattleStatus = "win";
									}
									break;
								case 3:
									if(EnemyArmySize > 1){
										EnemyArmySize--;
										//update enemy armies
										for(i = 0; i < BattleLayer3.length; i++){
											BattleLayer3.members[i].alpha = 0;											
										}
										for(i = 0; i < EnemyArmySize; i++){
											BattleLayer3.members[i].alpha = 1;
										}
									}else{
										//win!
										BattleStatus = "win";
									}
									break;
							}
						}else{
							//TIE
							GameStatus.text = "You tied. Press X to Attack!";
						}
					}
				}
			}
			if(BattleStatus == "win"){
				BattleStatus = "wat";
				//you won the battle! update shit
				BattleNumber++;
				BattleStarted = false;
				FlxG.log("Battle Number: "+BattleNumber);
				//change tile
				switch(BattleNumber-1){
					case 1:
						MapTM.setTileByIndex(258, 1);
						MaxDiceRoll = 6;
						break;
					case 2:
						//tile id = 287
						MapTM.setTileByIndex(338, 1);
						MaxDiceRoll = 9;
						break;
					case 3:
						//tile id = 10
						MapTM.setTileByIndex(34, 1);
						//fuck it, find out the easy way
						GameWon();
						break;
				}
				//hide battle layers
				HideBattleLayer();
				HideBattleLayer1();
				HideBattleLayer2();
				HideBattleLayer3();
				HideKittyLayer();
				
				//status text
				GameStatus.text = "You won. Press X to Roll!";
				RollDice();
				PlayerExp += DiceNumber*2;
				LevelCheck();
				DiceRolled = false;
				ReadyForInput = true;
				UpdatePlayerStatus();
				Player.play("Happy");
			}else if(BattleStatus == "Lose"){
				//hide layers
				HideBattleLayer();
				HideBattleLayer1();
				HideBattleLayer2();
				HideBattleLayer3();
				HideKittyLayer();
				GameStatus.text = "You lost the game. Press Z to return to title";
				if(FlxG.keys.justPressed("Z")){
					FlxG.switchState(new GameState());
				}
			}
		}
		
		private function GameWon():void{
			//YOU WON THE GAME!!!!!
			var winspr:FlxSprite = new FlxSprite(0, 0, WinGFX);
			winspr.scrollFactor = new FlxPoint(0, 0);
			add(winspr);
			ReadyForInput = false;
			
		}
		
		private function initBattle():void{
			//set up amount of kitties
			for(var i:uint = 0; i < PlayerArmySize; i++){
				KittyLayer.members[i].alpha = 1;
			}
			//set up the battle, yo!
			switch(BattleNumber){
				case 1:
					//only one player
					ShowBattleLayer1();
					EnemyArmySize = 1;
					break;
				case 2:
					//only one player
					ShowBattleLayer2();
					EnemyArmySize = 5;
					break;
				case 3:
					//only one player
					ShowBattleLayer3();
					EnemyArmySize = 10;
					break;
			}
			BattleInputReady = true;
		}
		
		private function DoRandom():void{
			if(!DiceRolled){
				if(FlxG.keys.justPressed("X")){
					RollDice();
					CurrentGameState = "It's OK to continue :)";
					switch(DiceNumber){
						case 2:
							GameStatus.text = "1000 Cubic Catnip Units! X To continue";
							PlayerMoney += 1000;
							Player.play("Happy");
							LastRandom = "Not Last 3";
							break;
						case 3:
							GameStatus.text = "You yawn. X To continue";
							Player.play("Yawn");
							LastRandom = "Not Last 3";
							break;
						case 4:
							GameStatus.text = "Gain 10% Strength. X To Continue";
							PlayerStrength += 0.1;
							Player.play("Happy");
							LastRandom = "Not Last 3";
							break;
						case 5:
							GameStatus.text = "Get 5 Kitties. X To Continue";
							PlayerArmySize += 5;
							Player.play("Happy");
							LastRandom = "Not Last 3";
							break;
						case 6:
							GameStatus.text = "Lose 5% Strength, Gain 2 Kitties. X To continue";
							PlayerStrength -= 0.05;
							PlayerArmySize += 2;
							Player.play("Yawn");
							LastRandom = "Not Last 3";
							break;
						case 7:
							GameStatus.text = "Catnip! Fuck yeah! X To continue";
							PlayerMoney += 5000;
							Player.play("Yawn");
							LastRandom = "Not Last 3";
							break;
						case 8:
							GameStatus.text = "Lose 1000 Catnip! X To Continue";
							PlayerMoney -= 1000;
							Player.play("Angry");
							LastRandom = "Not Last 3";
							break;
						case 9:
							GameStatus.text = "Lose 1 level. X To continue";
							PlayerLevel -= 1;
							AdjustExp();
							Player.play("Angry");
							LastRandom = "Not Last 3";
							break;
						default:
							if(LastRandom == "Last 3"){
								GameStatus.text = "Lose 500 Catnip! X To continue";
								PlayerMoney -= 500;
								CurrentGameState = "Movement";
							}else{
								GameStatus.text = "Go back 3 spaces";
								CurrentGameState = "Back Three Spaces";
							}
							Player.play("Angry");
							break;
					}
					if(CurrentGameState == "It's OK to continue :)"){
						ReadyForInput = true;
						DiceRolled = false;
						UpdatePlayerStatus();
					}
				}
			}
		}
		
		private function DoTraining():void{
		Player.play("Happy");
			if(!DiceRolled){
				if(FlxG.keys.justPressed("X")){
					RollDice();
					PlayerExp += DiceNumber*2;
					GameStatus.text = LevelCheck();
					DiceRolled = false;
					ReadyForInput = true;
					UpdatePlayerStatus();
					Player.play("Neutral");
				}
			}
		}
		
		private function DoShop():void{
			//buy things here
			//Things you can buy: Strength and Army Size
			//Prices increase by 500 each time
			if(ShopLayer.members[0].alpha == 0){
				if(FlxG.keys.justPressed("X")){
					ShowShopLayer();
				}
			}else{
				if(FlxG.keys.justPressed("Z")){
					if(PlayerMoney >= ArmyCost){
						PlayerArmySize++;
						PlayerMoney -= ArmyCost;
						ArmyCost += 250;		
						//close shop and continue				
						HideShop();
					}
				}else if(FlxG.keys.justPressed("X")){
					HideShop();				
				}else if(FlxG.keys.justPressed("C")){
					if(PlayerMoney >= StrengthCost){
						PlayerStrength += .1;
						PlayerMoney -= StrengthCost;
						StrengthCost += 500;
						HideShop();
					}			
				}
				//if shop was hidden, continue with the game
				if(ShopLayer.members[0].alpha == 0){
					DiceRolled = false;
					ReadyForInput = true;
					UpdatePlayerStatus();
					Player.play("Neutral");
					GameStatus.text = "Press X To Roll Dice";
				}
			}
		}
		
		private function DoMoneyGet():void{
		Player.play("Happy");
			if(!DiceRolled){
				if(FlxG.keys.justPressed("X")){
					RollDice();
					var NewMoney:uint = uint(((DiceNumber * 100) * MoneyMultiplier) * ((PlayerLevel*0.2) + 1));
					PlayerMoney += NewMoney;
					GameStatus.text = NewMoney+" raised. Press X to continue";
					DiceRolled = false;
					ReadyForInput = true;
					UpdatePlayerStatus();
					Player.play("Neutral");
				}
			}
		}
		
		private function RollDice():void{
			DiceNumber = (FlxG.random()*(MaxDiceRoll))+1;
			DiceRolled = true;
		}
		
		private function LevelCheck():String{
			switch(PlayerLevel){
				case 1:
					if(PlayerExp >= 10){
						PlayerLevel++;
						return ("You are now level 2! Press X to continue");
					}else{
						return ("You have "+(10 - PlayerExp)+" Exp to the next level. Press X to continue");
					}
				case 2:
					if(PlayerExp >= 30){
						PlayerLevel++;
						return ("You are now level 3! Press X to continue");
					}else{
						return ("You have "+(30 - PlayerExp)+" Exp to the next level. Press X to continue");
					}
				case 3:
					if(PlayerExp >= 60){
						PlayerLevel++;
						return ("You are now level 4! Press X to continue");
					}else{
						return ("You have "+(60 - PlayerExp)+" Exp to the next level. Press X to continue");
					}
				case 4:
					if(PlayerExp >= 150){
						PlayerLevel++;
						return ("You are now level 5! Press X to continue");
					}else{
						return ("You have "+(150 - PlayerExp)+" Exp to the next level. Press X to continue");
					}
				case 5:
					return ("You're already at level 5. Press X to continue");
			}
			return ("THIS SHOULD NOT HAPPEN");
		}
		
		private function DoMovement():void{
			if(Player.x > NewX){
				Player.x -= 1;
			}else if(Player.x < NewX){
				Player.x += 1;
			}else if(Player.y > NewY){
				Player.y -= 1;
			}else if(Player.y < NewY){
				Player.y += 1;
			}else{
				if(MapTM.getTile(uint((Player.x)/32), uint((Player.y)/32)) == 4){
					//fuck it, BATTLE TIME YO
					DiceNumber = 1;
					Player.play("Yawn");
				}
				if(!MovingBackwards){
					//Done moving: re-set some variables and set ready for input again
					DiceNumber--;
					GameStatus.text = DiceNumber+" Moves Left";		
					Player.play("Neutral");
					CheckDirections();
					//Set the action to whatever tile you land on
					if(DiceNumber == 0){
						DiceRolled = false;
						switch(MapTM.getTile(uint((Player.x)/32), uint((Player.y)/32))){
							case 1:
								CurrentGameState = "Movement";
								break;
							case 2:
								CurrentGameState = "Get Money";
								break;
							case 3:
								CurrentGameState = "Buy Things";
								break;
							case 4:
								CurrentGameState = "BATTLE TIME YO";
								break;
							case 5:
								CurrentGameState = "Random";
								break;
							case 6:
								CurrentGameState = "Army Recruits";
								break;
							case 7:
								CurrentGameState = "Training";
								break;
						}
					}else{
						ReadyForInput = true;
					}
				}else{
					Player.play("Angry");
					BackThreeSpaces();
				}
			}
		}
		
		private function BackThreeSpaces():void{
			MovingBackwards = true;
			//go back your last three Moves.
			if(LastThreeSpaces[2] != "Done"){
				GameStatus.text = "Go Back 3 spaces";
				switch(LastThreeSpaces[2]){
					case "Up":
						if(FlxG.keys.justPressed("DOWN")){
							ReadyForInput = false;
							CurrentGameState = "Movement";
							NewX = Player.x;
							NewY = Player.y + 32;
							Player.play("WalkDown");
							LastMovedDirection = "Down";
							LastThreeSpaces[2] = "Done";
						}
						break;
					case "Down":
						if(FlxG.keys.justPressed("UP")){
							ReadyForInput = false;
							CurrentGameState = "Movement";
							NewX = Player.x;
							NewY = Player.y - 32;
							Player.play("WalkUp");
							LastMovedDirection = "Up";
							LastThreeSpaces[2] = "Done";
						}
						break;
					case "Left":
						if(FlxG.keys.justPressed("RIGHT")){
							ReadyForInput = false;
							CurrentGameState = "Movement";
							NewX = Player.x + 32;
							NewY = Player.y;
							Player.play("WalkRight");
							LastMovedDirection = "Right";
							LastThreeSpaces[2] = "Done";
						}
						break;
					case "Right":
						if(FlxG.keys.justPressed("LEFT")){
							ReadyForInput = false;
							CurrentGameState = "Movement";
							NewX = Player.x - 32;
							NewY = Player.y;
							Player.play("WalkLeft");
							LastMovedDirection = "Left";
							LastThreeSpaces[2] = "Done";
						}
						break;
				}
			} else if(LastThreeSpaces[1] != "Done"){
				GameStatus.text = "Go Back 2 spaces";
				switch(LastThreeSpaces[1]){
					case "Up":
						if(FlxG.keys.justPressed("DOWN")){
							ReadyForInput = false;
							CurrentGameState = "Movement";
							NewX = Player.x;
							NewY = Player.y + 32;
							Player.play("WalkDown");
							LastMovedDirection = "Down";
							LastThreeSpaces[1] = "Done";
						}
						break;
					case "Down":
						if(FlxG.keys.justPressed("UP")){
							ReadyForInput = false;
							CurrentGameState = "Movement";
							NewX = Player.x;
							NewY = Player.y - 32;
							Player.play("WalkUp");
							LastMovedDirection = "Up";
							LastThreeSpaces[1] = "Done";
						}
						break;
					case "Left":
						if(FlxG.keys.justPressed("RIGHT")){
							ReadyForInput = false;
							CurrentGameState = "Movement";
							NewX = Player.x + 32;
							NewY = Player.y;
							Player.play("WalkRight");
							LastMovedDirection = "Right";
							LastThreeSpaces[1] = "Done";
						}
						break;
					case "Right":
						if(FlxG.keys.justPressed("LEFT")){
							ReadyForInput = false;
							CurrentGameState = "Movement";
							NewX = Player.x - 32;
							NewY = Player.y;
							Player.play("WalkLeft");
							LastMovedDirection = "Left";
							LastThreeSpaces[1] = "Done";
						}
						break;
				}
			} else if(LastThreeSpaces[0] != "Done"){
				GameStatus.text = "Go Back 1 space";
				switch(LastThreeSpaces[0]){
					case "Up":
						if(FlxG.keys.justPressed("DOWN")){
							ReadyForInput = false;
							CurrentGameState = "Movement";
							NewX = Player.x;
							NewY = Player.y + 32;
							Player.play("WalkDown");
							LastMovedDirection = "Down";
							LastThreeSpaces[0] = "Done";
						}
						break;
					case "Down":
						if(FlxG.keys.justPressed("UP")){
							ReadyForInput = false;
							CurrentGameState = "Movement";
							NewX = Player.x;
							NewY = Player.y - 32;
							Player.play("WalkUp");
							LastMovedDirection = "Up";
							LastThreeSpaces[0] = "Done";
						}
						break;
					case "Left":
						if(FlxG.keys.justPressed("RIGHT")){
							ReadyForInput = false;
							CurrentGameState = "Movement";
							NewX = Player.x + 32;
							NewY = Player.y;
							Player.play("WalkRight");
							LastMovedDirection = "Right";
							LastThreeSpaces[0] = "Done";
						}
						break;
					case "Right":
						if(FlxG.keys.justPressed("LEFT")){
							ReadyForInput = false;
							CurrentGameState = "Movement";
							NewX = Player.x - 32;
							NewY = Player.y;
							Player.play("WalkLeft");
							LastMovedDirection = "Left";
							LastThreeSpaces[0] = "Done";
						}
						break;
				}
			} else {
				//done!
				MovingBackwards = false;
				CheckDirections();
				LastMovedDirection = ThirdSpaceBackLastDirection;
				GameStatus.text = "Press X To Roll";
			}
		}
		
		private function PlayerInput():void{
			if(DiceRolled){
				//Player Movement
				if(FlxG.keys.justPressed("UP") && CanGoUp){
					ReadyForInput = false;
					CurrentGameState = "Movement";
					NewX = Player.x;
					NewY = Player.y - 32;
					Player.play("WalkUp");
					LastMovedDirection = "Up";
					LastThreeSpaces[0] = LastThreeSpaces[1];
					LastThreeSpaces[1] = LastThreeSpaces[2];
					LastThreeSpaces[2] = LastMovedDirection;
					ThirdSpaceBackLastDirection = LastThreeSpaces[0];
				}else if(FlxG.keys.justPressed("DOWN") && CanGoDown){
					ReadyForInput = false;
					CurrentGameState = "Movement";
					NewX = Player.x;
					NewY = Player.y + 32;
					Player.play("WalkDown");
					LastMovedDirection = "Down";
					LastThreeSpaces[0] = LastThreeSpaces[1];
					LastThreeSpaces[1] = LastThreeSpaces[2];
					LastThreeSpaces[2] = LastMovedDirection;
					ThirdSpaceBackLastDirection = LastThreeSpaces[0];
				}else if(FlxG.keys.justPressed("LEFT") && CanGoLeft){
					ReadyForInput = false;
					CurrentGameState = "Movement";
					NewX = Player.x - 32;
					NewY = Player.y;
					Player.play("WalkLeft");
					LastMovedDirection = "Left";
					LastThreeSpaces[0] = LastThreeSpaces[1];
					LastThreeSpaces[1] = LastThreeSpaces[2];
					LastThreeSpaces[2] = LastMovedDirection;
					ThirdSpaceBackLastDirection = LastThreeSpaces[0];
				}else if(FlxG.keys.justPressed("RIGHT") && CanGoRight){
					ReadyForInput = false;
					CurrentGameState = "Movement";
					NewX = Player.x + 32;
					NewY = Player.y;
					Player.play("WalkRight");
					LastMovedDirection = "Right";
					LastThreeSpaces[0] = LastThreeSpaces[1];
					LastThreeSpaces[1] = LastThreeSpaces[2];
					LastThreeSpaces[2] = LastMovedDirection;
					ThirdSpaceBackLastDirection = LastThreeSpaces[0];
				}
			}else{
				if(FlxG.keys.justPressed("X")){
					//ROLL THOSE DICE YO
					RollDice();
					GameStatus.text = DiceNumber+" Moves Left";
					Player.play("Neutral");
				}
			}
		}
		
		private function UpdatePlayerStatus():void{
			var NextExp:uint = 0;
			switch(PlayerLevel){
				case 1:
					NextExp = 10;
					break;
				case 2:
					NextExp = 30;
					break;
				case 3:
					NextExp = 60;
					break;
				case 4:
					NextExp = 150;
					break;
				case 5:
					NextExp = 9999;
					break;
			}
			PlayerStatus.text = "Level "+PlayerLevel+"\n"+
 			PlayerExp+"/"+NextExp+"\n"+
 			"Strength: "+PlayerStrength.toFixed(2)+"\n"+
 			"Army Size: "+PlayerArmySize+"\n"+
 			"Max Dice Roll: "+MaxDiceRoll+"\n"+
 			"Catnip: "+PlayerMoney;
		}
		
		private function CheckDirections():void{
			//check to see if you can move to tiles to the up, left, down, or right directions
			var PlayerTileX:uint = uint((Player.x)/32);
			var PlayerTileY:uint = uint((Player.y)/32);
			
			CanGoUp 	= ((MapTM.getTile(PlayerTileX, PlayerTileY - 1) > 0) 
			&& (MapTM.getTile(PlayerTileX, PlayerTileY - 1) < 8)) ? true : false;
			CanGoDown 	= ((MapTM.getTile(PlayerTileX, PlayerTileY + 1) > 0)
			&& (MapTM.getTile(PlayerTileX, PlayerTileY + 1) < 8)) ? true : false;
			CanGoLeft 	= ((MapTM.getTile(PlayerTileX - 1, PlayerTileY) > 0)
			&& (MapTM.getTile(PlayerTileX - 1, PlayerTileY) < 8)) ? true : false;
			CanGoRight 	= ((MapTM.getTile(PlayerTileX + 1, PlayerTileY) > 0)
			&& (MapTM.getTile(PlayerTileX + 1, PlayerTileY) < 8)) ? true : false;
			
			//Can't go backwards
			switch(LastMovedDirection){
				case "Up":
					CanGoDown = false;
					break;
				case "Down":
					CanGoUp = false;
					break;
				case "Left":
					CanGoRight = false;
					break;
				case "Right":
					CanGoLeft = false;
					break;
			}
			
			//Special Cases
			if(PlayerTileX == 5 && PlayerTileY == 12){
				CanGoUp = false;
			} else if(PlayerTileX == 5 && PlayerTileY == 6){
				CanGoUp = false;
			} else if(PlayerTileX == 5 && PlayerTileY == 7){
				CanGoUp = false;
			} else if(PlayerTileX == 17 && PlayerTileY == 14){
				CanGoLeft = false;
			}
		}
		
		private function CreateShopLayer():void{
			
			//black background
			var BB:FlxSprite = new FlxSprite(8, 8);
			BB.makeGraphic(FlxG.width - 16, FlxG.height - 16, 0xC0000000);
			
			var ShopText:FlxText = new FlxText(16, 16, FlxG.width - 32, "BUY SOMETHIN, WIL' YA!");
			ShopText.setFormat(null, 16, 0xFFFFFF, "center");
						
			var ShopTextB:FlxText = new FlxText(16, 40, FlxG.width - 32, "Press Z to increase Army Members. Cost:"+ArmyCost);
			ShopTextB.setFormat(null, 8, 0xFFFFFF, "center");
			
			var ShopTextC:FlxText = new FlxText(16, 70, FlxG.width - 32, "Press C to increase Strength. Cost: "+StrengthCost);
			ShopTextC.setFormat(null, 8, 0xFFFFFF, "center");
			
			var ShopTextD:FlxText = new FlxText(16, 100, FlxG.width - 32, "Press X to exit shop");
			ShopTextD.setFormat(null, 8, 0xFFFFFF, "center");
			
			var ShopTextE:FlxText = new FlxText(16, 200, FlxG.width - 32, "Catnip Left: "+PlayerMoney);
			ShopTextE.setFormat(null, 16, 0xFFFFFF, "center");
			
			
			ShopLayer = new FlxGroup();
			ShopLayer.add(BB);
			ShopLayer.add(ShopText);
			ShopLayer.add(ShopTextB);
			ShopLayer.add(ShopTextC);
			ShopLayer.add(ShopTextD);
			ShopLayer.add(ShopTextE);
			
			//fix scroll factor
			for(var i:uint = 0; i < ShopLayer.length; i++){
				ShopLayer.members[i].scrollFactor = new FlxPoint(0, 0);
			}
			
			HideShopLayer();
		}
		
		private function CreateKittyLayer():void{
			//max 30 kitties, just because
			KittyLayer = new FlxGroup();
			for(var i:uint = 0; i < MaxKitties; i++){
				var KittySprite:FlxSprite = new FlxSprite(280 - (i*5), 125);
				KittySprite.loadGraphic(PlayerImg, false, false, 32, 32);
				KittySprite.scrollFactor = new FlxPoint(0, 0);
				KittySprite.alpha = 0;
				KittySprite.frame = 2;
				KittyLayer.add(KittySprite);
			}
		}
		
		private function CreateBattleLayer():void{
			BattleLayer = new FlxGroup();
			BattleLayer1 = new FlxGroup();
			BattleLayer2 = new FlxGroup();
			BattleLayer3 = new FlxGroup();
		
			var BlackBG:FlxSprite = new FlxSprite(0, 0);
			var BattleBG:FlxSprite = new FlxSprite(0, 50, BattleBGImg);
			
			BlackBG.makeGraphic(320, 240, 0x80000000);
		
			//add things to battle layer
			BattleLayer.add(BlackBG);
			BattleLayer.add(BattleBG);
			
			//set scrollFactor to 0
			for(var i:uint = 0; i < BattleLayer.length; i++){
				BattleLayer.members[i].scrollFactor = new FlxPoint(0, 0);
			}		
			HideBattleLayer();
			
			
			
			
			//set up individual battles
			
			//battle 1 - 1 Enemy			
			var Enemy1:FlxSprite = new FlxSprite(65, 91);
			Enemy1.loadGraphic(PeopleImg, false, false, 30, 80);
			Enemy1.randomFrame();
			BattleLayer1.add(Enemy1);			
			
			//Battle 2 - 5 Enemies
			for(i = 0; i < 5; i++){
				var EnemySprite:FlxSprite = new FlxSprite(50 + (i*10), 91);
				EnemySprite.loadGraphic(PeopleImg, false, false, 30, 80);
				EnemySprite.randomFrame();
				BattleLayer2.add(EnemySprite);
			} 
			
			//Battle 3 - 10 Enemies
			for(i = 0; i < 10; i++){
				var EnemySprite3:FlxSprite = new FlxSprite(35 + (i*10), 91);
				EnemySprite3.loadGraphic(PeopleImg, false, false, 30, 80);
				EnemySprite3.randomFrame();
				BattleLayer3.add(EnemySprite3);
			} 
			
			//set scrollFactor to 0
			for(i = 0; i < BattleLayer1.length; i++){
				BattleLayer1.members[i].scrollFactor = new FlxPoint(0, 0);
			}		
			for(i = 0; i < BattleLayer2.length; i++){
				BattleLayer2.members[i].scrollFactor = new FlxPoint(0, 0);
			}		
			for(i = 0; i < BattleLayer3.length; i++){
				BattleLayer3.members[i].scrollFactor = new FlxPoint(0, 0);
			}	
			
			//hide layers
			HideBattleLayer1();
			HideBattleLayer2();
			HideBattleLayer3();	
		}
		
		private function HideBattleLayer():void{
			for(var i:uint = 0; i < BattleLayer.length; i++){
				BattleLayer.members[i].alpha = 0;
			}		
		}
		
		private function HideBattleLayer1():void{
			for(var i:uint = 0; i < BattleLayer1.length; i++){
				BattleLayer1.members[i].alpha = 0;
			}		
		}
		
		private function HideBattleLayer2():void{
			for(var i:uint = 0; i < BattleLayer2.length; i++){
				BattleLayer2.members[i].alpha = 0;
			}		
		}
		
		private function HideBattleLayer3():void{
			for(var i:uint = 0; i < BattleLayer3.length; i++){
				BattleLayer3.members[i].alpha = 0;
			}		
		}
		
		private function ShowBattleLayer():void{
			for(var i:uint = 0; i < BattleLayer.length; i++){
				BattleLayer.members[i].alpha = 1;
			}
		}
		
		private function ShowBattleLayer1():void{
			for(var i:uint = 0; i < BattleLayer1.length; i++){
				BattleLayer1.members[i].alpha = 1;
			}
		}
		
		private function ShowBattleLayer2():void{
			for(var i:uint = 0; i < BattleLayer2.length; i++){
				BattleLayer2.members[i].alpha = 1;
			}
		}
		
		private function ShowBattleLayer3():void{
			for(var i:uint = 0; i < BattleLayer3.length; i++){
				BattleLayer3.members[i].alpha = 1;
			}
		}
		
		private function ShowKittyLayer():void{
			for(var i:uint = 0; i < KittyLayer.length; i++){
				KittyLayer.members[i].alpha = 1;
			}
		}
		
		private function HideKittyLayer():void{
			for(var i:uint = 0; i < KittyLayer.length; i++){
				KittyLayer.members[i].alpha = 0;
			}
		}
		
		private function ShowShopLayer():void{
			//update values
			ShopLayer.members[2].text = "Press Z to increase Army Members. Cost:"+ArmyCost;
			ShopLayer.members[3].text = "Press C to increase Strength. Cost: "+StrengthCost;
			ShopLayer.members[5].text = "Catnip Left: "+PlayerMoney;
			for(var i:uint = 0; i < ShopLayer.length;i++){
				ShopLayer.members[i].alpha = 1;
			}		
		}
		
		private function HideShop():void{
			HideShopLayer();
		}
		
		private function HideShopLayer():void{
			for(var i:uint = 0; i < ShopLayer.length;i++){
				ShopLayer.members[i].alpha = 0;
			}
		}
		
		protected function initGame():void{
			//Set up LastThreeSpaces
			LastThreeSpaces = new Array("Blank", "Blank", "Blank");
			BackgroundLayer = new FlxGroup();
			PlayerLayer = new FlxGroup();
			
			CreateBattleLayer();
			CreateShopLayer();
			CreateKittyLayer();
			
			//Load Map			
			MapTM = new FlxTilemap();
			MapTM.loadMap(new Map_Data, GfxTiles, 32, 32, 0, 0, 1, 100);
			var BGMapTM:FlxTilemap = new FlxTilemap();
			BGMapTM.loadMap(new MapBG_Data, GfxTiles, 32, 32, 0, 0, 1, 100);
			
			BackgroundLayer.add(BGMapTM);
			BackgroundLayer.add(MapTM);
			
			
			//Find Starting Tile and etc
			MapWidth = MapTM.widthInTiles;
			MapHeight = MapTM.heightInTiles;
			var StartX:uint = MapTM.getTileCoords(1, false)[0].x;
			var StartY:uint = MapTM.getTileCoords(1, false)[0].y;
			
			Player = new FlxSprite(StartX, StartY);
			Player.loadGraphic(PlayerImg, true, true, 32, 32);
			
			//set up player animations
			Player.addAnimation("Happy", [1], 0, false);
			Player.addAnimation("Neutral", [2], 0, false);
			Player.addAnimation("Angry", [0], 0, false);
			Player.addAnimation("WalkUp", [11, 12, 13, 14], 10, true);
			Player.addAnimation("WalkDown", [3, 4, 5, 6], 10, true);
			Player.addAnimation("WalkLeft", [15, 16, 17, 18], 10, true);
			Player.addAnimation("WalkRight", [7, 8, 9, 10], 10, true);
			Player.addAnimation("Yawn", [19, 20, 21, 22, 21, 22, 22, 22, 21, 22, 21, 20, 19], 10, false);
			
			Player.play("Neutral");

			PlayerLayer.add(Player);
			
			GameStatus = new FlxText(8, FlxG.height - 48, FlxG.width - 16, "Press X To Roll the Dice");
			GameStatus.setFormat(null, 16, 0x44FFFF, "center", 0xFF000000);
			GameStatus.scrollFactor = new FlxPoint(0, 0);
			
			//make game status text easier to read
			var BBI:FlxSprite = new FlxSprite(8, FlxG.height - 48);
			BBI.makeGraphic(FlxG.width - 16, 44, 0xA0000000);
			BBI.scrollFactor = new FlxPoint(0, 0);
			BackgroundLayer.add(BBI);
			
			PlayerStatus = new FlxText(8, 8, FlxG.width/3, "hi mom");
			PlayerStatus.setFormat(null, 8, 0x44FFFF, "left", 0xFF000000);
			PlayerStatus.scrollFactor = new FlxPoint(0, 0);
			
			BBI = new FlxSprite(4, 4);
			BBI.makeGraphic((FlxG.width/4)+8, 70, 0xA0000000);
			BBI.scrollFactor = new FlxPoint(0, 0);
						
			//Add shit to the game
			add(BackgroundLayer);
			add(PlayerLayer);
			add(BattleLayer);
			add(BattleLayer1);
			add(BattleLayer2);
			add(BattleLayer3);
			add(KittyLayer);
			add(GameStatus);
			add(BBI);
			add(PlayerStatus);
			add(ShopLayer);
			
			//camera
			FlxG.camera.follow(Player, FlxCamera.STYLE_TOPDOWN);
			FlxG.camera.bounds = MapTM.getBounds();
			
			
			CheckDirections();
			UpdatePlayerStatus();
			ReadyForInput = true;
		}
	}
}
