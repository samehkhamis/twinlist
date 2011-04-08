package twinlist
{
	import spark.components.Group;
	import flash.display.Sprite;
	import flare.display.TextSprite;
	import flare.flex.vis.FlareCanvas;
	import mx.events.FlexEvent;
	
	public class ListViewerFlareClass extends Group
	{
		[Bindable]
		protected var model:Model = Model.Instance;
		[Bindable]
		public var fc:FlareCanvas;
		
		public function ListViewerFlareClass()
		{
			super();
		}
		
		protected function onInitialize(event:FlexEvent):void
		{
			var round:Sprite = new Sprite();
			round.graphics.beginFill(0x0000cc, 0.25);
			round.graphics.lineStyle(1, 0x000000);
			round.graphics.drawRoundRect(20, 50, 100, 100, 5, 5);
			fc.visualization.addChild(round);
			
			var text:TextSprite = new TextSprite("It Works!");
			text.color = 0xffff0000;
			text.size = 32;
			text.x = 40;
			text.y = 100;
			fc.visualization.addChild(text);
		}
	}
}