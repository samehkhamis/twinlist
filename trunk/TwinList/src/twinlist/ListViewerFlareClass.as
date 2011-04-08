package twinlist
{
	import flare.animate.Parallel;
	import flare.animate.Sequence;
	import flare.animate.Tween;
	import flare.display.TextSprite;
	import flare.flex.vis.FlareCanvas;
	import flare.vis.Visualization;
	
	import flash.display.Sprite;
	
	import mx.events.FlexEvent;
	
	import spark.components.Group;
	
	public class ListViewerFlareClass extends Group
	{
		[Bindable]
		protected var model:Model = Model.Instance;
		[Bindable]
		protected var vis:Visualization;
		
		public function ListViewerFlareClass()
		{
			super();
			vis = new Visualization();
		}
		
		protected function OnInitialize(event:Event):void
		{
			vis.addChild(CreateCircles());
			vis.addChild(CreateRectangle("Whaddup, bitches!"));
		}
		
		protected function SpinIt(event:Event):void
		{
			RotateAndStretch(Sprite(vis.getChildByName("circles")));
		}
		
		private function CreateCircles():Sprite
		{
			var container:Sprite = new Sprite();
			container.name = "circles";
			container.x = 300;
			container.y = 200;
			for (var i:int = 0; i < 10; i++) {
				var x:Number = (i/5<1 ? 1 : -1) * (13 + 26 * (i%5));
				var circle:Sprite = CreateCircle(x, 0);
				circle.alpha = 1.0 - i * 0.05;
				container.addChild(circle);
			}
			return container;
		}
		
		private function CreateCircle(x:Number, y:Number):Sprite
		{
			var sprite:Sprite = new Sprite();
			sprite.graphics.beginFill(0xcccccc, 0.5);
			sprite.graphics.lineStyle(1, 0x000000);
			sprite.graphics.drawCircle(0, 0, 10);
			sprite.x = x;
			sprite.y = y;
			return sprite;
		}
		
		private function RotateAndStretch(sprite:Sprite):void
		{
			var rot:Tween = new Tween(sprite, 1, {rotation:360});
			var t1:Tween = new Tween(sprite, 1, {y:200});
			var t2:Tween = new Tween(sprite, 1, {scaleX:2});
			var t3:Tween = new Tween(sprite, 1, {y:300});
			var t4:Tween = new Tween(sprite, 1, {scaleX:1});
			var seq:Sequence = new Sequence(
				new Parallel(t1, t2, rot),
				new Parallel(t3, t4, rot)
			);
			seq.play();		
		}
		
		private function CreateRectangle(string:String):Sprite
		{
			var round:Sprite = new Sprite();
			round.name = "rectangle";
			round.graphics.beginFill(0x0000cc, 0.25);
			round.graphics.lineStyle(1, 0x000000);
			round.graphics.drawRoundRect(20, 50, 100, 100, 5, 5);
			
			var text:TextSprite = new TextSprite(string);
			text.color = 0xffff0000;
			text.size = 32;
			text.x = 40;
			text.y = 100;
			round.addChild(text);
			
			return round;
		}
	}
}