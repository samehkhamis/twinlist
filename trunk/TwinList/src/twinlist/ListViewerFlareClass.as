package twinlist
{
	import flare.animate.Parallel;
	import flare.animate.TransitionEvent;
	import flare.animate.Tween;
	import flare.display.LineSprite;
	import flare.display.RectSprite;
	import flare.display.TextSprite;
	import flare.vis.Visualization;
	import flare.vis.data.DataSprite;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.geom.Rectangle;
	import flash.utils.Timer;
	
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
		private var columnList:ArrayCollection;
		
		private var selectedSprite:DataSprite = null;
		private var popup:RectSprite;
		private var timer:Timer;
		
		private var columnWidth:int = 0;
		private var columnHeight:int = 0;
		private var textHeight:int = 16;
		private var textSpacing:int = 12;
		private var fontString:String = "Sans Serif";
		
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
			visList = CreateVisList(model.ListViewerData, RowHeight);
			
			var sprite:DataSprite;
			
			// Calculate column dimensions
			var calculatedColumnWidth:int = 0;
			for each (sprite in visList) {
				if (sprite.getChildAt(0).width > calculatedColumnWidth)
					calculatedColumnWidth = sprite.getChildAt(0).width;
			}
			columnWidth = 180;//Math.max(calculatedColumnWidth, 180);
			columnHeight = HeaderHeight + model.ListViewerData.length * RowHeight + textSpacing;
			
			// Set up the visualization
			vis.bounds = new Rectangle(0, 0, 5 * columnWidth, columnHeight);
			columnList = new ArrayCollection();
			vis.addChild(CreateColumn(0, 0xffffffff, ''));
			vis.addChild(CreateColumn(1, 0xffdddddd, model.VisibleLists[0].Name));
			vis.addChild(CreateColumn(2, 0xffffffff, ''));
			vis.addChild(CreateColumn(3, 0xffdddddd, model.VisibleLists[1].Name));
			vis.addChild(CreateColumn(4, 0xffffffff, ''));
			vis.addChild(CreateHorizontalLine(1));
			vis.addChild(CreateHorizontalLine(textHeight + textSpacing));
			
			// Fix x values and draw sprites
			for each (sprite in visList)
			{
				sprite.data.properties.x1 *= columnWidth;
				sprite.data.properties.x2 *= columnWidth;
				sprite.x = sprite.data.properties.x1;
				sprite.y = sprite.data.properties.y1;
				vis.addChild(sprite);
			}
			
			// Create the popup sprite
			var acceptBtn:TextSprite = new TextSprite("Accept?");
			acceptBtn.size = textHeight;
			acceptBtn.color = 0xffff0000;
			acceptBtn.buttonMode = true;
			var rejectBtn:TextSprite = new TextSprite("Reject?");
			rejectBtn.size = textHeight;
			rejectBtn.color = 0xffff0000;
			rejectBtn.buttonMode = true;
			rejectBtn.x = acceptBtn.width;
			
			popup = new RectSprite(0, 0, rejectBtn.x + rejectBtn.width, rejectBtn.height);
			popup.fillColor = popup.lineColor = 0x55ffffff;
			popup.alpha = 0;
			popup.addChild(acceptBtn);
			popup.addChild(rejectBtn);
			vis.addChild(popup);
			
			// Create the timer
			timer = new Timer(250);
			timer.addEventListener(TimerEvent.TIMER, ClickTimer);
			
			// Create the two animation sequences
			UpdateButtonAnimations();
		}
		
		private function OnViewUpdate(event:Event):void
		{
			// Get new visList
			var newVisList:ArrayCollection = CreateVisList(model.ListViewerData, RowHeight);
			
			var sprite:DataSprite;
			
			// create transition animation
			var animUpdate:Parallel = new Parallel();
			
			// fade out old sprites
			for each (sprite in visList) {
				animUpdate.add(new Tween(sprite, 0.5, {alpha: 0}));
			}
			// fade in new sprites
			for each (sprite in newVisList) {
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
			var l1y:int = HeaderHeight;
			var l2y:int = HeaderHeight;
			var ry:int = HeaderHeight;
			
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
		
		private function CreateColumn(index:int, color:int, title:String):RectSprite
		{
			var header:TextSprite = new TextSprite(title);
			header.color = 0xff000000;
			header.size = textHeight;
			header.font = fontString;
			header.bold = true;
			header.letterSpacing = 4;
			header.horizontalAnchor = TextSprite.CENTER;
			header.x = columnWidth / 2;
			header.y = 0;
			header.buttonMode = true;
			
			var rect:RectSprite = new RectSprite(index * columnWidth, 0, columnWidth, columnHeight);
			rect.fillColor = rect.lineColor = color;
			rect.addChild(header);
			columnList.addItem(rect);
			
			return rect;
		}
		
		private function CreateHorizontalLine(y:int):LineSprite
		{
			var line:LineSprite = new LineSprite();
			line.lineColor = 0xff000000;
			line.x1 = 0;
			line.y1 = y;
			line.x2 = columnWidth * 5;
			line.y2 = y;
			line.lineWidth = 2;
			
			return line;
		}
		
		private function CreateItemSprite(item:ListItem, properties:Object):DataSprite
		{
			var nameText:TextSprite = new TextSprite(item.Name);
			nameText.color = 0xff000000;
			nameText.size = textHeight;
			nameText.font = fontString;
			nameText.doubleClickEnabled = true;
			
			var attrText:TextSprite = new TextSprite(item.AttributesString());
			attrText.color = 0xff000000;
			attrText.size = textHeight - 4;
			attrText.font = fontString;
			attrText.doubleClickEnabled = true;
			attrText.y = nameText.y + textHeight;
			
			var sprite:DataSprite = new DataSprite();
			sprite.addChild(nameText);
			sprite.addChild(attrText);
			sprite.renderer = null;
			sprite.data = {properties: properties, item: item};
			sprite.buttonMode = true;
			sprite.doubleClickEnabled = true;
			sprite.addEventListener(MouseEvent.CLICK, ItemClick);
			sprite.addEventListener(MouseEvent.DOUBLE_CLICK, ItemDoubleClick);
			sprite.addEventListener(MouseEvent.MOUSE_DOWN, ItemMouseDown);
			sprite.addEventListener(MouseEvent.MOUSE_UP, ItemMouseUp);
			sprite.addEventListener(MouseEvent.MOUSE_MOVE, ItemMouseMove);
			sprite.addEventListener(MouseEvent.ROLL_OVER, ItemRollOver);
			sprite.addEventListener(MouseEvent.ROLL_OUT, ItemRollOut);
			
			return sprite;
		}
		
		private function UpdateButtonAnimations():void
		{
			animReconcile = new Parallel();
			animSeparate = new Parallel();
			
			// Animate the items
			for each (var sprite:DataSprite in visList)
			{
				animReconcile.add(new Tween(sprite, 1, {x: sprite.data.properties.x1}));
				animReconcile.add(new Tween(sprite, 1, {y: sprite.data.properties.y1}));
				animSeparate.add(new Tween(sprite, 1, {x: sprite.data.properties.x2}));
				animSeparate.add(new Tween(sprite, 1, {y: sprite.data.properties.y2}));
			}
			
			// Animate the column colors
			animSeparate.add(new Tween(columnList[0], 1, {fillColor: 0xffffcfcf, lineColor: 0xffffcfcf}));
			animSeparate.add(new Tween(columnList[1], 1, {fillColor: 0xffffecd5, lineColor: 0xffffecd5}));
			animSeparate.add(new Tween(columnList[2], 1, {fillColor: 0xffb3fec5, lineColor: 0xffb3fec5}));
			animSeparate.add(new Tween(columnList[3], 1, {fillColor: 0xffffecd5, lineColor: 0xffffecd5}));
			animSeparate.add(new Tween(columnList[4], 1, {fillColor: 0xffffcfcf, lineColor: 0xffffcfcf}));
			
			animReconcile.add(new Tween(columnList[0], 1, {fillColor: 0xffffffff, lineColor: 0xffffffff}));
			animReconcile.add(new Tween(columnList[1], 1, {fillColor: 0xffdddddd, lineColor: 0xffdddddd}));
			animReconcile.add(new Tween(columnList[2], 1, {fillColor: 0xffffffff, lineColor: 0xffffffff}));
			animReconcile.add(new Tween(columnList[3], 1, {fillColor: 0xffdddddd, lineColor: 0xffdddddd}));
			animReconcile.add(new Tween(columnList[4], 1, {fillColor: 0xffffffff, lineColor: 0xffffffff}));
			
			// Animate the column headers
			animSeparate.add(new Tween(columnList[0].getChildAt(0), 1, {text: model.VisibleLists[0].Name + ' - Unique', font: fontString}));
			animSeparate.add(new Tween(columnList[1].getChildAt(0), 1, {text: model.VisibleLists[0].Name + ' - Similar', font: fontString}));
			animSeparate.add(new Tween(columnList[2].getChildAt(0), 1, {text: 'Identical', font: fontString}));
			animSeparate.add(new Tween(columnList[3].getChildAt(0), 1, {text: model.VisibleLists[1].Name + ' - Similar', font: fontString}));
			animSeparate.add(new Tween(columnList[4].getChildAt(0), 1, {text: model.VisibleLists[1].Name + ' - Unique', font: fontString}));
			
			animReconcile.add(new Tween(columnList[0].getChildAt(0), 1, {text: ''}));
			animReconcile.add(new Tween(columnList[1].getChildAt(0), 1, {text: model.VisibleLists[0].Name, font: fontString}));
			animReconcile.add(new Tween(columnList[2].getChildAt(0), 1, {text: ''}));
			animReconcile.add(new Tween(columnList[3].getChildAt(0), 1, {text: model.VisibleLists[1].Name, font: fontString}));
			animReconcile.add(new Tween(columnList[4].getChildAt(0), 1, {text: ''}));
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
		
		private function ItemMouseDown(event:MouseEvent):void
		{
			var sprite:DataSprite = event.currentTarget as DataSprite;
			selectedSprite = sprite;
			popup.x = sprite.x + event.localX;
			popup.y = sprite.y + event.localY;
			timer.start();
		}
		
		private function ItemMouseUp(event:MouseEvent):void
		{
			var sprite:DataSprite = event.currentTarget as DataSprite;
			timer.reset();
			popup.alpha = 0;
		}
		
		private function ItemMouseMove(event:MouseEvent):void
		{
			var sprite:DataSprite = event.currentTarget as DataSprite;
			timer.reset();
			popup.alpha = 0;
		}
		
		private function ClickTimer(event:TimerEvent):void
		{
			if (popup.alpha == 0)
			{
				var tween:Tween = new Tween(popup, 0.5, {alpha: 1});
				tween.play();
			}
		}
		
		private function ItemRollOver(event:MouseEvent):void
		{
			var sprite:DataSprite = event.currentTarget as DataSprite;
			if (sprite != selectedSprite)
			{
				timer.reset();
				popup.alpha = 0;
			}
			
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
		
		private function get HeaderHeight():int
		{
			return textHeight + 2 * textSpacing;
		}
		
		private function get RowHeight():int
		{
			return 2 * textHeight - 4 + textSpacing;
		}
	}
}