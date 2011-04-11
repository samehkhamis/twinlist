package twinlist
{
	import flare.animate.Parallel;
	import flare.animate.Sequence;
	import flare.animate.Tween;
	import flare.display.TextSprite;
	import flare.display.RectSprite;
	import flare.vis.Visualization;
	import flare.vis.data.DataSprite;
	import flare.vis.data.Data;
	
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	
	import mx.controls.Alert;
	import mx.collections.ArrayCollection;
	
	import spark.components.Group;
	
	public class ListViewerFlareClass extends Group
	{
		[Bindable]
		protected var model:Model = Model.Instance;
		[Bindable]
		protected var vis:Visualization;
		
		private var textLists:Object = null;
		
		public function ListViewerFlareClass()
		{
			super();
			vis = new Visualization();
		}
		
		protected function OnInitialize(event:Event):void
		{
			var columnLength:int = 0;
			var columnWidth:int = 0;
			var textHeight:int = 24;
			
			textLists = new Object();
			for each (var list:List in model.Lists)
			{
				if (list.length > columnLength)
					columnLength = list.length;
				
				textLists[list.Id] = new ArrayCollection();
				for each (var item:ListItem in list)
				{
					var text:TextSprite = new TextSprite(item.Name);
					text.color = 0xff0000ff;
					text.size = textHeight;
					text.buttonMode = true;
					text.addEventListener(MouseEvent.CLICK,
						function(event:MouseEvent):void { Alert.show(event.currentTarget.text); }
					);
					
					if (text.width > columnWidth)
						columnWidth = text.width;
					textLists[list.Id].addItem(text);
				}
			}
			
			var columnHeight:int = columnLength * textHeight * 2;
			vis.bounds = new Rectangle(0, 0, 5 * columnWidth, columnHeight);
			
			var x:int = columnWidth;
			var y:int = 0;
			for (var id:* in textLists)
			{
				var rect:RectSprite = new RectSprite(x, 0, columnWidth, columnHeight);
				rect.fillColor = rect.lineColor = 0xffcccccc;
				vis.addChild(rect);
				
				for each (var t:TextSprite in textLists[id])
				{
					t.x = x;
					t.y = y;
					vis.addChild(t);
					
					y += textHeight * 2;
				}
				x += columnWidth * 2;
				y = 0;
			}
		}
		
		private function RotateAndStretch(sprite:DataSprite):void
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
	}
}