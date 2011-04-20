package twinlist
{
	import flare.animate.Parallel;
	import flare.animate.Sequence;
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
	import spark.components.Scroller;
	
	import twinlist.list.ItemAttribute;
	import twinlist.list.ListItem;
	
	public class ListViewerFlareClass extends Group
	{
		[Bindable]
		protected var model:Model = Model.Instance;
		[Bindable]
		protected var vis:Visualization;
		[Bindable]
		public var btn:Button;
		[Bindable]
		public var scroller:Scroller;
		
		private var visList:ArrayCollection;
		private var columnList:ArrayCollection;
		
		private var selectedSprite:DataSprite = null;
		private var popup:RectSprite;
		private var timer:Timer;
		
		private var columnWidth:int = 0;
		private var columnHeight:int = 0;
		private var textHeight:int = 16;
		private var textSpacing:int = 14;
		private var fontString:String = "Sans Serif";
		
		private var reconciled:Boolean;
		private var animReconcile:Parallel;
		private var animSeparate:Parallel;
		
		private var colorList1:int = 0xffffffdd;
		private var colorList2:int = 0xffddddff;
		private var colorIdentical:int = 0xffddffdd;
		private var colorOriginal:int = 0xffdddddd;
		private var colorText:int = 0xff000000;
		private var colorTextHighlighted:int = 0xff0000ff;
		private var colorBackground:int = 0xffffffff;
		private var colorDiffHighlight1:int = 0xffffff40;
		private var colorDiffHighlight2:int = 0xffB0B0ff;
		
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
			visList = CreateVisList(model.ListViewerData);
			
			var sprite:DataSprite;
			
			// Calculate column dimensions
			var calculatedColumnWidth:int = 0;
			for each (sprite in visList) {
				if (sprite.getChildAt(0).width > calculatedColumnWidth)
					calculatedColumnWidth = sprite.getChildAt(0).width;
			}
			columnWidth = 180;//calculatedColumnWidth;
			columnHeight = HeaderHeight + model.ListViewerData.length * RowHeight + textSpacing;
			
			// Set up the visualization
			vis.bounds = new Rectangle(0, 0, 5 * columnWidth, columnHeight);
			columnList = new ArrayCollection();
			vis.addChild(CreateColumn(0, colorBackground, ''));
			vis.addChild(CreateColumn(1, colorOriginal, model.VisibleLists[0].Name));
			vis.addChild(CreateColumn(2, colorBackground, ''));
			vis.addChild(CreateColumn(3, colorOriginal, model.VisibleLists[1].Name));
			vis.addChild(CreateColumn(4, colorBackground, ''));
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
			
			// Create the popup sprite and its timer
			CreatePopup();
			
			// Make the scrolling faster
			scroller.addEventListener(MouseEvent.MOUSE_WHEEL, function(event:MouseEvent):void {
				event.delta *= 10;
			}, true);
			
			// Create the two animation sequences
			UpdateButtonAnimations();
		}
		
		private function CreatePopup():void
		{
			// Create the sprite
			var acceptBtn:TextSprite = new TextSprite("Accept?");
			acceptBtn.size = textHeight;
			acceptBtn.font = fontString;
			acceptBtn.color = 0xff330000;
			acceptBtn.buttonMode = true;
			acceptBtn.addEventListener(MouseEvent.MOUSE_OVER, ButtonRollOver);
			acceptBtn.addEventListener(MouseEvent.MOUSE_OUT, ButtonRollOut);
			acceptBtn.addEventListener(MouseEvent.MOUSE_UP, AcceptClick);
			
			var rejectBtn:TextSprite = new TextSprite("Reject?");
			rejectBtn.size = textHeight;
			rejectBtn.font = fontString;
			rejectBtn.color = 0xff330000;
			rejectBtn.buttonMode = true;
			rejectBtn.x = acceptBtn.width;
			rejectBtn.addEventListener(MouseEvent.MOUSE_OVER, ButtonRollOver);
			rejectBtn.addEventListener(MouseEvent.MOUSE_OUT, ButtonRollOut);
			rejectBtn.addEventListener(MouseEvent.MOUSE_UP, RejectClick);
			
			popup = new RectSprite(0, 0, rejectBtn.x + rejectBtn.width, rejectBtn.height);
			popup.fillColor = popup.lineColor = 0x55aaaaaa;
			popup.alpha = 0;
			popup.addChild(acceptBtn);
			popup.addChild(rejectBtn);
			
			// Create the timer
			timer = new Timer(250);
			timer.addEventListener(TimerEvent.TIMER, ClickTimer);
		}
		
		private function OnViewUpdate(event:Event):void
		{
			// Get new visList
			var newVisList:ArrayCollection = CreateVisList(model.ListViewerData);
			
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
		
		private function CreateVisList(data:ArrayCollection):ArrayCollection
		{
			var l1y:int = HeaderHeight;
			var l2y:int = HeaderHeight;
			var ry:int = HeaderHeight;
			
			var visList:ArrayCollection = new ArrayCollection();
			for each (var item:ListViewerItem in data)
			{
				if (item.Identical != null)
				{
					visList.addItem(CreateItemSprite(item.Identical, 0, {x1: 1, y1: l1y, x2: 2, y2: ry, type: 0}));
					visList.addItem(CreateItemSprite(item.Identical, 1, {x1: 3, y1: l2y, x2: 2, y2: ry, type: 0}));
					l1y += RowHeight;
					l2y += RowHeight;
					ry += RowHeight;
				}
				else if (item.L1Unique != null)
				{
					visList.addItem(CreateItemSprite(item.L1Unique, 0, {x1: 1, y1: l1y, x2: 0, y2: ry, type: 2}));
					l1y += RowHeight;
					ry += RowHeight;
				}
				else if (item.L2Unique != null)
				{
					visList.addItem(CreateItemSprite(item.L2Unique, 1, {x1: 3, y1: l2y, x2: 4, y2: ry, type: 2}));
					l2y += RowHeight;
					ry += RowHeight;
				}
				else
				{
					if (item.L1Similar != null)
						visList.addItem(CreateItemSprite(item.L1Similar, 0, {x1: 1, y1: l1y, x2: 1, y2: ry, type: 1}));
					if (item.L2Similar != null)
						visList.addItem(CreateItemSprite(item.L2Similar, 1, {x1: 3, y1: l2y, x2: 3, y2: ry, type: 1}));
					l1y += RowHeight;
					l2y += RowHeight;
					ry += RowHeight;
				}
			}
			return visList;
		}
		
		private function CreateColumn(index:int, color:int, title:String):RectSprite
		{
			var header:TextSprite = new TextSprite(title);
			header.color = colorText;
			header.size = textHeight;
			header.font = fontString;
			header.bold = true;
			header.letterSpacing = 3;
			header.horizontalAnchor = TextSprite.CENTER;
			header.x = columnWidth / 2;
			header.y = 0;
			
			var rect:RectSprite = new RectSprite(index * columnWidth, 0, columnWidth, columnHeight);
			rect.fillColor = rect.lineColor = color;
			rect.addChild(header);
			rect.addEventListener(MouseEvent.MOUSE_DOWN, ItemMouseDown);
			columnList.addItem(rect);
			
			return rect;
		}
		
		private function CreateHorizontalLine(y:int):LineSprite
		{
			var line:LineSprite = new LineSprite();
			line.lineColor = colorText;
			line.x1 = 0;
			line.y1 = y;
			line.x2 = columnWidth * 5;
			line.y2 = y;
			line.lineWidth = 2;
			
			return line;
		}
		
		private function CreateItemSprite(item:ListItem, listIdx:int, properties:Object):DataSprite
		{
			var sprite:DataSprite = new DataSprite();
			sprite.renderer = null;
			sprite.data = {properties: properties, item: item};
			sprite.buttonMode = true;
			sprite.doubleClickEnabled = true;
			sprite.addEventListener(MouseEvent.DOUBLE_CLICK, ItemDoubleClick);
			sprite.addEventListener(MouseEvent.MOUSE_DOWN, ItemMouseDown);
			sprite.addEventListener(MouseEvent.MOUSE_UP, ItemMouseUp);
			sprite.addEventListener(MouseEvent.ROLL_OVER, ItemRollOver);
			sprite.addEventListener(MouseEvent.ROLL_OUT, ItemRollOut);
			
			var nameText:TextSprite = new TextSprite(item.Name);
			var highlight:RectSprite;
			nameText.color = colorText;
			nameText.size = textHeight;
			nameText.font = fontString;
			nameText.doubleClickEnabled = true;
			if (item.NameUnique) {
				highlight = CreateHighlight(nameText, listIdx);
				highlight.alpha = reconciled ? 1 : 0;
				sprite.addChild(highlight);
			}
			sprite.addChild(nameText);
		
			var x:int = 0;
			var attrText:TextSprite;
			for each (var attr:ItemAttribute in item.Attributes) {
				attrText = new TextSprite(attr.ValuesString());
				attrText.color = colorText;
				attrText.size = textHeight - 4;
				attrText.font = fontString;
				attrText.doubleClickEnabled = true;
				attrText.x = x;
				attrText.y = textHeight + 4;
				if (attr.Unique) {
					highlight = CreateHighlight(attrText, listIdx);
					highlight.alpha = reconciled ? 1 : 0;
					sprite.addChild(highlight);
				}
				sprite.addChild(attrText);
				x += attrText.width;
			}
			
			return sprite;
		}
		
		private function UpdateButtonAnimations():void
		{
			animReconcile = new Parallel();
			animSeparate = new Parallel();
			
			var animSeparateItems:Sequence = new Sequence();
			var animSeparateIdentical:Parallel = new Parallel();
			var animSeparateSimilar:Parallel = new Parallel();
			var animSeparateUnique:Parallel = new Parallel();
			animSeparateItems.add(animSeparateIdentical);
			animSeparateItems.add(animSeparateUnique);
			animSeparateItems.add(animSeparateSimilar);
			animSeparate.add(animSeparateItems);
			
			// Animate the items
			for each (var sprite:DataSprite in visList)
			{
				animReconcile.add(new Tween(sprite, 1, {x: sprite.data.properties.x1, y: sprite.data.properties.y1}));
				
				if (sprite.data.properties.type == 0)
					animSeparateIdentical.add(new Tween(sprite, 0.5, {x: sprite.data.properties.x2, y: sprite.data.properties.y2}));
				else if (sprite.data.properties.type == 1)
					animSeparateSimilar.add(new Tween(sprite, 0.5, {x: sprite.data.properties.x2, y: sprite.data.properties.y2}));
				else if (sprite.data.properties.type == 2)
					animSeparateUnique.add(new Tween(sprite, 0.5, {x: sprite.data.properties.x2, y: sprite.data.properties.y2}));
				
				for (var i:int = 0; i < sprite.numChildren; i++) {
					var child:Sprite = sprite.getChildAt(i) as Sprite;
					if (child is RectSprite) {
						animReconcile.add(new Tween(child, 1, {alpha: 0}));
						if (sprite.data.properties.type == 0)
							animSeparateIdentical.add(new Tween(child, 1, {alpha: 1}));
						else if (sprite.data.properties.type == 1)
							animSeparateSimilar.add(new Tween(child, 1, {alpha: 1}));
						else if (sprite.data.properties.type == 2)
							animSeparateUnique.add(new Tween(child, 1, {alpha: 1}));
					}
				}
			}
			
			// Animate the column colors
			animSeparate.add(new Tween(columnList[0], 1, {fillColor: colorList1, lineColor: colorList1}));
			animSeparate.add(new Tween(columnList[1], 1, {fillColor: (colorList1 + colorIdentical) / 2, lineColor: (colorList1 + colorIdentical) / 2}));
			animSeparate.add(new Tween(columnList[2], 1, {fillColor: colorIdentical, lineColor: colorIdentical}));
			animSeparate.add(new Tween(columnList[3], 1, {fillColor: (colorList2 + colorIdentical) / 2, lineColor: (colorList2 + colorIdentical) / 2}));
			animSeparate.add(new Tween(columnList[4], 1, {fillColor: colorList2, lineColor: colorList2}));
			
			animReconcile.add(new Tween(columnList[0], 1, {fillColor: colorBackground, lineColor: colorBackground}));
			animReconcile.add(new Tween(columnList[1], 1, {fillColor: colorOriginal, lineColor: colorOriginal}));
			animReconcile.add(new Tween(columnList[2], 1, {fillColor: colorBackground, lineColor: colorBackground}));
			animReconcile.add(new Tween(columnList[3], 1, {fillColor: colorOriginal, lineColor: colorOriginal}));
			animReconcile.add(new Tween(columnList[4], 1, {fillColor: colorBackground, lineColor: colorBackground}));
			
			// Animate the column headers
			animSeparate.add(new Tween(columnList[0].getChildAt(0), 1, {text: model.VisibleLists[0].Name + ' - Unique'}));
			animSeparate.add(new Tween(columnList[1].getChildAt(0), 1, {text: model.VisibleLists[0].Name + ' - Similar'}));
			animSeparate.add(new Tween(columnList[2].getChildAt(0), 1, {text: 'Identical'}));
			animSeparate.add(new Tween(columnList[3].getChildAt(0), 1, {text: model.VisibleLists[1].Name + ' - Similar'}));
			animSeparate.add(new Tween(columnList[4].getChildAt(0), 1, {text: model.VisibleLists[1].Name + ' - Unique'}));
			
			animReconcile.add(new Tween(columnList[0].getChildAt(0), 1, {text: ''}));
			animReconcile.add(new Tween(columnList[1].getChildAt(0), 1, {text: model.VisibleLists[0].Name}));
			animReconcile.add(new Tween(columnList[2].getChildAt(0), 1, {text: ''}));
			animReconcile.add(new Tween(columnList[3].getChildAt(0), 1, {text: model.VisibleLists[1].Name}));
			animReconcile.add(new Tween(columnList[4].getChildAt(0), 1, {text: ''}));
		}
		
		protected function ReconcileButtonClick(event:MouseEvent):void
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
		
		private function ButtonRollOver(event:MouseEvent):void
		{
			event.currentTarget.color = 0xffff0000;
		}
		
		private function ButtonRollOut(event:MouseEvent):void
		{
			event.currentTarget.color = 0xff330000;
		}
		
		private function AcceptClick(event:MouseEvent):void
		{
			if (popup.alpha == 0)
				return;
			
			var item:ListItem = selectedSprite.data.item as ListItem;
			if (model.ActionListContains(item) == -1)
				model.AddActionListItem(item);
		}
		
		private function RejectClick(event:MouseEvent):void
		{
			if (popup.alpha == 0)
				return;
			
			var item:ListItem = selectedSprite.data.item as ListItem;
			if (model.ActionListContains(item) >= 0)
				model.DelActionListItem(item);
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
			// remove selected sprite popup and highlight
			if (selectedSprite != null) {
				if (selectedSprite.contains(popup))
					selectedSprite.removeChild(popup);
				Highlight(selectedSprite, false);
			}
			// get selected sprite (will be null if not item)
			var sprite:DataSprite = event.currentTarget as DataSprite;
			// if not item, update model and return
			if (sprite == null) {
				selectedSprite = null;
				model.SelectedItem = null;
				return;
			}
			// set selected item in model
			model.SelectedItem = sprite.data.item as ListItem;
			// set selected sprite and highlight
			selectedSprite = sprite;
			Highlight(sprite, true);
			// setup popup
			popup.alpha = 0;
			popup.x = sprite.getChildAt(0).width;
			popup.y = event.localY - popup.height / 2;
			sprite.addChild(popup);
			// start timer
			timer.start();
		}
		
		private function ItemMouseUp(event:MouseEvent):void
		{
			var sprite:DataSprite = event.currentTarget as DataSprite;
			timer.reset();
			popup.alpha = 0;
		}
		
		private function ClickTimer(event:TimerEvent):void
		{
			if (popup.alpha == 0)
			{
				var tween:Tween = new Tween(popup, 0.15, {alpha: 1});
				tween.play();
			}
		}
		
		private function ItemRollOver(event:MouseEvent):void
		{
			var sprite:DataSprite = event.currentTarget as DataSprite;
			if (sprite == selectedSprite)
				return;
			Highlight(sprite, true);
		}
		
		private function ItemRollOut(event:MouseEvent):void
		{
			var sprite:DataSprite = event.currentTarget as DataSprite;
			if (sprite == selectedSprite) {
				timer.reset();
				popup.alpha = 0;
				if (sprite.contains(popup))
					sprite.removeChild(popup);
			}
			else
				Highlight(sprite, false);
		}
		
		private function get HeaderHeight():int
		{
			return textHeight + 2 * textSpacing;
		}
		
		private function get RowHeight():int
		{
			return 2 * textHeight - 4 + textSpacing;
		}
		
		private function Highlight(sprite:Sprite, enabled:Boolean):void
		{
			var color:int = enabled ? colorTextHighlighted : colorText;
			for (var i:int = 0; i < sprite.numChildren; i++) {
				var text:TextSprite = sprite.getChildAt(i) as TextSprite;
				if (text != null)
					text.color = color;
			}
		}
		
		private function CreateHighlight(sprite:TextSprite, listIdx:int):RectSprite
		{
			var highlight:RectSprite = new RectSprite(sprite.x, sprite.y, sprite.width, sprite.height);
			highlight.fillColor = highlight.lineColor = listIdx == 0 ? colorDiffHighlight1 : colorDiffHighlight2;
			return highlight
		}
	}
}