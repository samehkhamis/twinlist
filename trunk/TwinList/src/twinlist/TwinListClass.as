package twinlist
{
	import spark.components.Application;
	import flash.display.Sprite;
	import flare.display.TextSprite;
	import flare.flex.vis.FlareCanvas;
	import mx.events.FlexEvent;
	
	public class TwinListClass extends Application
	{
		[Bindable]
		protected var model:Model = Model.Instance;
		[Bindable]
		public var flare:FlareCanvas;
		
		public function TwinListClass()
		{
			super();
		}
		
//		protected function onInitialize(event:FlexEvent):void
//		{
//			var round:Sprite = new Sprite();
//			round.graphics.beginFill(0x0000cc, 0.25);
//			round.graphics.lineStyle(1, 0x000000);
//			round.graphics.drawRoundRect(20, 50, 100, 100, 5, 5);
//			flare.visualization.addChild(round);
//			
//			var text:TextSprite = new TextSprite("It Works!");
//			text.color = 0xffff0000;
//			text.size = 32;
//			text.x = 40;
//			text.y = 100;
//			flare.visualization.addChild(text);
//		}
	}
}