package twinlist
{
	import flare.animate.Parallel;
	import flare.animate.Tween;
	import flare.display.RectSprite;
	import flare.display.TextSprite;
	import flare.vis.Visualization;
	import flare.vis.data.DataSprite;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	
	import mx.collections.ArrayCollection;
	
	import spark.components.Group;
	
	public class ListViewerFlareClass extends Group
	{
		[Bindable]
		protected var model:Model = Model.Instance;
		[Bindable]
		protected var vis:Visualization;
		
		private var visList:ArrayCollection;
		private var columnWidth:int = 0;
		private var columnHeight:int = 0;
		private var textHeight:int = 24;
		private var textSpacing:int = 12;
		private var reconciled:Boolean = false;
		
		public function ListViewerFlareClass()
		{
			super();
			vis = new Visualization();
			model.addEventListener(Model.DATA_LOADED, OnInitialize);
		}
		
		protected function OnInitialize(event:Event):void
		{
			// TODO: Fix this when we settle on multi-list reconciliation
			var l1y:int = textSpacing;
			var l2y:int = textSpacing;
			var ry:int = textSpacing;
			var rowHeight = textHeight + textSpacing;
			
			visList = new ArrayCollection();
			for each (var item:ListViewerItem in model.ListViewerData)
			{
				if (item.Identical)
				{
					visList.addItem(CreateItemSprite(item.Identical, {x1: 1, y1: l1y, x2: 2, y2: ry}));
					visList.addItem(CreateItemSprite(item.Identical, {x1: 3, y1: l2y, x2: 2, y2: ry}));
					l1y += rowHeight;
					l2y += rowHeight;
					ry += rowHeight;
				}
				else if (item.L1Similar)
				{
					visList.addItem(CreateItemSprite(item.L1Similar, {x1: 1, y1: l1y, x2: 1, y2: ry}));
					visList.addItem(CreateItemSprite(item.L2Similar, {x1: 3, y1: l2y, x2: 3, y2: ry}));
					l1y += rowHeight;
					l2y += rowHeight;
					ry += rowHeight;
				}
				else if (item.L1Unique)
				{
					visList.addItem(CreateItemSprite(item.L1Unique, {x1: 1, y1: l1y, x2: 0, y2: ry}));
					l1y += rowHeight;
					ry += rowHeight;
				}
				else if (item.L2Unique)
				{
					visList.addItem(CreateItemSprite(item.L2Unique, {x1: 3, y1: l2y, x2: 4, y2: ry}));
					l2y += rowHeight;
					ry += rowHeight;
				}
			}
			
			// Calculate column width
			for each (var sprite:DataSprite in visList)
				if (sprite.getChildAt(0).width > columnWidth)
					columnWidth = sprite.getChildAt(0).width;
			
			// Set up the visualization
			columnHeight = model.ListViewerData.length * rowHeight;
			vis.bounds = new Rectangle(0, 0, 5 * columnWidth, columnHeight);
			
			for (var x:int = 1; x <= 3; x += 2)
			{
				var rect:RectSprite = new RectSprite(x * columnWidth, 0, columnWidth, columnHeight);
				rect.fillColor = rect.lineColor = 0xffcccccc;
				vis.addChild(rect);
			}
			
			// Fix x values and draw sprites
			for each (var sprite:DataSprite in visList)
			{
				sprite.data.properties.x1 *= columnWidth;
				sprite.data.properties.x2 *= columnWidth;
				sprite.x = sprite.data.properties.x1;
				sprite.y = sprite.data.properties.y1;
				vis.addChild(sprite);
			}
			
			vis.update();
		}
		
		private function CreateItemSprite(item:ListItem, properties:Object):DataSprite
		{
			var text:TextSprite = new TextSprite(item.Name);
			text.color = 0xff0000ff;
			text.size = textHeight;
			
			var sprite:DataSprite = new DataSprite();
			sprite.renderer = null;
			sprite.data = {properties: properties, item: item};
			sprite.buttonMode = true;
			sprite.addEventListener(MouseEvent.CLICK, ItemClick);
			sprite.addEventListener(MouseEvent.ROLL_OVER, ItemRollOver);
			sprite.addEventListener(MouseEvent.ROLL_OUT, ItemRollOut);
			sprite.addChild(text);
			
			return sprite;
		}
		
		private function ItemClick(event:MouseEvent):void
		{
			//Alert.show(event.currentTarget.data.item.Name);
			
			var animation:Parallel = new Parallel();
			if (reconciled)
			{
				for each (var sprite:DataSprite in visList)
				{
					animation.add(new Tween(sprite, 1, {x: sprite.data.properties.x1}));
					animation.add(new Tween(sprite, 1, {y: sprite.data.properties.y1}));
				}
				reconciled = false;
			}
			else
			{
				for each (var sprite:DataSprite in visList)
				{
					animation.add(new Tween(sprite, 1, {x: sprite.data.properties.x2}));
					animation.add(new Tween(sprite, 1, {y: sprite.data.properties.y2}));
				}
				reconciled = true;
			}
			animation.play();
		}
		
		private function ItemRollOver(event:MouseEvent):void
		{
			var sprite:DataSprite = event.currentTarget as DataSprite;
			var text:TextSprite = sprite.getChildAt(0) as TextSprite;
			text.color = 0xffff0000;
		}
		
		private function ItemRollOut(event:MouseEvent):void
		{
			var sprite:DataSprite = event.currentTarget as DataSprite;
			var text:TextSprite = sprite.getChildAt(0) as TextSprite;
			text.color = 0xff0000ff;
		}
	}
}