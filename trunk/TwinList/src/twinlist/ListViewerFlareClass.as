package twinlist
{
	import flare.animate.Parallel;
	import flare.animate.TransitionEvent;
	import flare.animate.Tween;
	import flare.display.RectSprite;
	import flare.display.TextSprite;
	import flare.vis.Visualization;
	import flare.vis.data.DataSprite;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	
	import mx.collections.ArrayCollection;
	
	import spark.components.Button;
	import spark.components.Group;
	
	import twinlist.list.ListItem;
	
	public class ListViewerFlareClass extends Group
	{
		[Bindable]
		protected var model:Model = Model.Instance;
		[Bindable]
		protected var vis:Visualization;
		[Bindable]
		public var btn:Button;
		
		private var visList:ArrayCollection;
		private var columnWidth:int = 0;
		private var columnHeight:int = 0;
		private var textHeight:int = 16;
		private var textSpacing:int = 12;
		private var reconciled:Boolean;
		private var animReconcile:Parallel;
		private var animSeparate:Parallel;
		
		public function ListViewerFlareClass()
		{
			super();
			vis = new Visualization();
			reconciled = false;
			model.addEventListener(Model.DATA_LOADED, OnDataLoaded);
			model.addEventListener(Model.VIEW_UPDATED, OnViewUpdate);
		}
		
		private function OnDataLoaded(event:Event):void
		{
			// Get visList
			var rowHeight:int = textHeight + textSpacing;
			visList = CreateVisList(model.ListViewerData, rowHeight);
			
			// Calculate column dimensions
			var calculatedColumnWidth:int = 0;
			for each (var sprite:DataSprite in visList) {
				if (sprite.getChildAt(0).width > columnWidth)
					calculatedColumnWidth = sprite.getChildAt(0).width;
			}
			columnWidth = Math.min(calculatedColumnWidth, 180);
			columnHeight = model.ListViewerData.length * rowHeight + textSpacing;
			
			// Set up the visualization
			vis.bounds = new Rectangle(0, 0, 5 * columnWidth, columnHeight);
			vis.addChild(CreateColumn(0, 0xffffcfcf));
			vis.addChild(CreateColumn(1, 0xffffecd5));
			vis.addChild(CreateColumn(2, 0xffb3fec5));
			vis.addChild(CreateColumn(3, 0xffffecd5));
			vis.addChild(CreateColumn(4, 0xffffcfcf));
			
			// Fix x values and draw sprites
			for each (var sprite:DataSprite in visList)
			{
				sprite.data.properties.x1 *= columnWidth;
				sprite.data.properties.x2 *= columnWidth;
				sprite.x = sprite.data.properties.x1;
				sprite.y = sprite.data.properties.y1;
				vis.addChild(sprite);
			}
			
			// Create the two animation sequences
			UpdateButtonAnimations();
		}
		
		private function OnViewUpdate(event:Event):void
		{			
			// Get new visList
			var rowHeight:int = textHeight + textSpacing;
			var newVisList = CreateVisList(model.ListViewerData, rowHeight);
			
			// create transition animation
			var animUpdate:Parallel = new Parallel();
			// fade out old sprites
			for each (var sprite:DataSprite in visList) {
				animUpdate.add(new Tween(sprite, 0.5, {alpha: 0}));
			}
			// fade in new sprites
			for each (var sprite:DataSprite in newVisList) {
				sprite.data.properties.x1 *= columnWidth;
				sprite.data.properties.x2 *= columnWidth;
				sprite.x = reconciled ? sprite.data.properties.x2 : sprite.data.properties.x1;
				sprite.y = reconciled ? sprite.data.properties.y2 : sprite.data.properties.y1;
				sprite.alpha = 0;
				vis.addChild(sprite);
				animUpdate.add(new Tween(sprite, 0.5, {alpha: 1}));			
			}
			
			// Update display and animate
			animUpdate.addEventListener(TransitionEvent.END, function(e:Event):void {
				OnTransitionComplete(newVisList);
			});
			animUpdate.play();
		}
		
		private function OnTransitionComplete(newVisList:ArrayCollection):void
		{
			// clear old sprites from vis
			for each (var sprite:DataSprite in visList) {
				if (vis.contains(sprite))
					vis.removeChild(sprite);
			}
			visList = newVisList;
			
			// Update the two animation sequences
			UpdateButtonAnimations();			
		}
		
		private function CreateVisList(data:ArrayCollection, rowHeight:int):ArrayCollection
		{
			// TODO: Fix this when we settle on multi-list reconciliation
			var l1y:int = textSpacing;
			var l2y:int = textSpacing;
			var ry:int = textSpacing;
			
			var visList:ArrayCollection = new ArrayCollection();
			for each (var item:ListViewerItem in data)
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
			return visList;
		}
		
		private function CreateColumn(index:int, color:int):RectSprite
		{
			var rect:RectSprite = new RectSprite(index * columnWidth, 0, columnWidth, columnHeight);
			rect.fillColor = rect.lineColor = color;
			return rect;
		}
		
		private function CreateItemSprite(item:ListItem, properties:Object):DataSprite
		{
			var nameText:TextSprite = new TextSprite(item.toString());// new TextSprite(item.Name);
			nameText.color = 0xff000000;
			nameText.size = textHeight;
			nameText.doubleClickEnabled = true;
			
//			var attrText:TextSprite = new TextSprite(item.AttributesString());
//			attrText.color = 0xff000000;
//			attrText.size = textHeight - 4;
//			attrText.doubleClickEnabled = true;
			
			var sprite:DataSprite = new DataSprite();
			sprite.addChild(nameText);
//			sprite.addChild(attrText);
			sprite.renderer = null;
			sprite.data = {properties: properties, item: item};
			sprite.buttonMode = true;
			sprite.doubleClickEnabled = true;
			sprite.addEventListener(MouseEvent.CLICK, ItemClick);
			sprite.addEventListener(MouseEvent.DOUBLE_CLICK, ItemDoubleClick);
			sprite.addEventListener(MouseEvent.ROLL_OVER, ItemRollOver);
			sprite.addEventListener(MouseEvent.ROLL_OUT, ItemRollOut);
			
			return sprite;
		}
		
		private function UpdateButtonAnimations():void
		{
			animReconcile = new Parallel();
			animSeparate = new Parallel();
			for each (var sprite:DataSprite in visList)
			{
				animReconcile.add(new Tween(sprite, 1, {x: sprite.data.properties.x1}));
				animReconcile.add(new Tween(sprite, 1, {y: sprite.data.properties.y1}));
				animSeparate.add(new Tween(sprite, 1, {x: sprite.data.properties.x2}));
				animSeparate.add(new Tween(sprite, 1, {y: sprite.data.properties.y2}));
			}
		}
		
		protected function ButtonClick(event:MouseEvent):void
		{
			if (reconciled)
			{
				animReconcile.play();
				btn.label = "Reconcile";
				reconciled = false;
			}
			else
			{
				animSeparate.play();
				btn.label = "Separate";
				reconciled = true;
			}
		}
		
		private function ItemClick(event:MouseEvent):void
		{
			var sprite:DataSprite = event.currentTarget as DataSprite;
			model.SelectedItem = sprite.data.item as ListItem;
		}
		
		private function ItemDoubleClick(event:MouseEvent):void
		{
			var sprite:DataSprite = event.currentTarget as DataSprite;
			var item:ListItem = sprite.data.item as ListItem;
			if (item == null)
				return;
			if (model.ActionListContains(item) >= 0)
				model.DelActionListItem(item);
			else
				model.AddActionListItem(item);
		}
		
		private function ItemRollOver(event:MouseEvent):void
		{
			var sprite:DataSprite = event.currentTarget as DataSprite;
			for (var i:int = 0; i < sprite.numChildren; i++) {
				var text:TextSprite = sprite.getChildAt(i) as TextSprite;
				text.color = 0xff0000ff;
			}
		}
		
		private function ItemRollOut(event:MouseEvent):void
		{
			var sprite:DataSprite = event.currentTarget as DataSprite;
			for (var i:int = 0; i < sprite.numChildren; i++) {
				var text:TextSprite = sprite.getChildAt(i) as TextSprite;
				text.color = 0xff000000;
			}
		}
	}
}