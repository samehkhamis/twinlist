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
		public var mergeBtn:Button;
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
		
		private var merged:Boolean;
		private var animMerge:Sequence;
		private var animSeparate:Sequence;
		
		private var colorList1:uint = 0xffffffdd;
		private var colorList2:uint = 0xffddddff;
		private var colorIdentical:uint = 0xffddffdd;
		private var colorOriginal:uint = 0xffdddddd;
		private var colorText:uint = 0xff000000;
		private var colorTextGray:uint = 0xff707070;
		private var colorTextHighlighted:uint = 0xff0000ff;
		private var colorBackground:uint = 0xffffffff;
		private var colorDiffHighlight1:uint = 0xffffff40;
		private var colorDiffHighlight2:uint = 0xffB0B0ff;
		
		private var removeAfterAction:Boolean = true;
		
		public function ListViewerFlareClass()
		{
			super();
			vis = new Visualization();
			merged = false;
			model.addEventListener(Model.DATA_LOADED, OnDataLoaded);
			model.addEventListener(Model.VIEW_UPDATED, OnViewUpdated);
			model.addEventListener(Model.OPTIONS_UPDATED, OnOptionsUpdated);
		}
		
		public function get RemoveAfterAction():Boolean
		{
			return removeAfterAction;
		}
		public function set RemoveAfterAction(enabled:Boolean):void
		{
			removeAfterAction = enabled;
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
			acceptBtn.addEventListener(MouseEvent.MOUSE_OVER, PopupButtonRollOver);
			acceptBtn.addEventListener(MouseEvent.MOUSE_OUT, PopupButtonRollOut);
			acceptBtn.addEventListener(MouseEvent.MOUSE_UP, AcceptClick);
			
			var rejectBtn:TextSprite = new TextSprite("Reject?");
			rejectBtn.size = textHeight;
			rejectBtn.font = fontString;
			rejectBtn.color = 0xff330000;
			rejectBtn.buttonMode = true;
			rejectBtn.x = acceptBtn.width;
			rejectBtn.addEventListener(MouseEvent.MOUSE_OVER, PopupButtonRollOver);
			rejectBtn.addEventListener(MouseEvent.MOUSE_OUT, PopupButtonRollOut);
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
		
		private function OnViewUpdated(event:Event):void
		{
			// reset selected sprite
			selectedSprite = null;
			
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
				sprite.x = merged ? sprite.data.properties.x2 : sprite.data.properties.x1;
				sprite.y = merged ? sprite.data.properties.y2 : sprite.data.properties.y1;
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
				var sprite:DataSprite;
				if (item.Identical != null)
				{
					if (!item.Identical.ActedOn || !RemoveAfterAction) {
						sprite = CreateItemSprite(item.Identical, 0, {x1: 1, y1: l1y, x2: 2, y2: ry, type: 0});
						visList.addItem(sprite);
						sprite = CreateItemSprite(item.Identical, 1, {x1: 3, y1: l2y, x2: 2, y2: ry, type: 0});
						visList.addItem(sprite);
						l1y += RowHeight;
						l2y += RowHeight;
						ry += RowHeight;
					}
				}
				else if (item.L1Unique != null)
				{
					if (!item.L1Unique.ActedOn || !RemoveAfterAction) {
						sprite = CreateItemSprite(item.L1Unique, 0, {x1: 1, y1: l1y, x2: 0, y2: ry, type: 2});
						visList.addItem(sprite);
						l1y += RowHeight;
						ry += RowHeight;
					}
				}
				else if (item.L2Unique != null)
				{
					if (!item.L2Unique.ActedOn || !RemoveAfterAction) {
						sprite = CreateItemSprite(item.L2Unique, 1, {x1: 3, y1: l2y, x2: 4, y2: ry, type: 2});
						visList.addItem(sprite);
						l2y += RowHeight;
						ry += RowHeight;
					}
				}
				else
				{
					if (item.L1Similar != null) {
						if (!item.L1Similar.ActedOn || !RemoveAfterAction) {
							sprite = CreateItemSprite(item.L1Similar, 0, {x1: 1, y1: l1y, x2: 1, y2: ry, type: 1});
							visList.addItem(sprite);
							l1y += RowHeight;
						}
					}
					if (item.L2Similar != null) {
						if (!item.L2Similar.ActedOn || !RemoveAfterAction) {
							sprite = CreateItemSprite(item.L2Similar, 1, {x1: 3, y1: l2y, x2: 3, y2: ry, type: 1});
							visList.addItem(sprite);
							l2y += RowHeight;
						}
					}
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
			if (!item.ActedOn) {
				sprite.buttonMode = true;
				sprite.addEventListener(MouseEvent.MOUSE_DOWN, ItemMouseDown);
				sprite.addEventListener(MouseEvent.MOUSE_UP, ItemMouseUp);
				sprite.addEventListener(MouseEvent.ROLL_OVER, ItemRollOver);
				sprite.addEventListener(MouseEvent.ROLL_OUT, ItemRollOut);
			}
			
			var nameText:TextSprite = new TextSprite(item.Name);
			var highlight:RectSprite;
			nameText.color = item.ActedOn ? colorTextGray : colorText;
			nameText.size = textHeight;
			nameText.font = fontString;
			if (item.NameUnique) {
				highlight = CreateHighlight(nameText, listIdx);
				highlight.alpha = merged ? 1 : 0;
				sprite.addChild(highlight);
			}
			sprite.addChild(nameText);
		
			var x:int = 0;
			var attrText:TextSprite;
			for each (var attr:ItemAttribute in item.Attributes) {
				attrText = new TextSprite(attr.ValuesString());
				attrText.color = item.ActedOn ? colorTextGray : colorText;
				attrText.size = textHeight - 4;
				attrText.font = fontString;
				attrText.x = x;
				attrText.y = textHeight + 4;
				if (attr.Unique) {
					highlight = CreateHighlight(attrText, listIdx);
					highlight.alpha = merged ? 1 : 0;
					sprite.addChild(highlight);
				}
				sprite.addChild(attrText);
				x += attrText.width;
			}
			
			return sprite;
		}
		
		private function UpdateButtonAnimations():void
		{
			animMerge = new Sequence();
			animSeparate = new Sequence();
			
			var animSeparateColIdentical:Parallel = new Parallel();
			var animSeparateColUnique:Parallel = new Parallel();
			var animSeparateColSimilar:Parallel = new Parallel();
			var animSeparateIdentical:Parallel = new Parallel();
			var animSeparateSimilar:Parallel = new Parallel();
			var animSeparateUnique:Parallel = new Parallel();
			
			animSeparate.add(animSeparateColIdentical);
			animSeparate.add(animSeparateIdentical);
			animSeparate.add(animSeparateColUnique);
			animSeparate.add(animSeparateUnique);
			animSeparate.add(animSeparateColSimilar);
			animSeparate.add(animSeparateSimilar);
			
			var animReconcileCol:Parallel = new Parallel();
			var animReconcileItems:Parallel = new Parallel();
			
			animMerge.add(animReconcileCol);
			animMerge.add(animReconcileItems);
			
			// Animate the items
			for each (var sprite:DataSprite in visList)
			{
				animReconcileItems.add(new Tween(sprite, 1, {x: sprite.data.properties.x1, y: sprite.data.properties.y1}));
				
				if (sprite.data.properties.type == 0)
					animSeparateIdentical.add(new Tween(sprite, 1, {x: sprite.data.properties.x2, y: sprite.data.properties.y2}));
				else if (sprite.data.properties.type == 1)
					animSeparateSimilar.add(new Tween(sprite, 1, {x: sprite.data.properties.x2, y: sprite.data.properties.y2}));
				else if (sprite.data.properties.type == 2)
					animSeparateUnique.add(new Tween(sprite, 1, {x: sprite.data.properties.x2, y: sprite.data.properties.y2}));
				
				for (var i:int = 0; i < sprite.numChildren; i++) {
					var child:Sprite = sprite.getChildAt(i) as Sprite;
					if (child is RectSprite) {
						animReconcileCol.add(new Tween(child, 0.25, {alpha: 0}));
						if (sprite.data.properties.type == 0)
							animSeparateIdentical.add(new Tween(child, 1, {alpha: 1}));
						else if (sprite.data.properties.type == 1)
							animSeparateSimilar.add(new Tween(child, 1, {alpha: 1}));
						else if (sprite.data.properties.type == 2)
							animSeparateUnique.add(new Tween(child, 1, {alpha: 1}));
					}
				}
			}
			
			// Animate the column colors and headers after
			animSeparateColIdentical.add(new Tween(columnList[2], 0.25, {fillColor: colorIdentical, lineColor: colorIdentical}));
			animSeparateColIdentical.add(new Tween(columnList[2].getChildAt(0), 0.25, {text: 'Identical'}));
			
			animSeparateColUnique.add(new Tween(columnList[0], 0.25, {fillColor: colorList1, lineColor: colorList1}));
			animSeparateColUnique.add(new Tween(columnList[0].getChildAt(0), 0.25, {text: model.VisibleLists[0].Name + ' - Unique'}));
			animSeparateColUnique.add(new Tween(columnList[4], 0.25, {fillColor: colorList2, lineColor: colorList2}));
			animSeparateColUnique.add(new Tween(columnList[4].getChildAt(0), 0.25, {text: model.VisibleLists[1].Name + ' - Unique'}));
			
			animSeparateColSimilar.add(new Tween(columnList[1], 0.25, {fillColor: (colorList1 + colorIdentical) / 2, lineColor: (colorList1 + colorIdentical) / 2}));
			animSeparateColSimilar.add(new Tween(columnList[1].getChildAt(0), 0.25, {text: model.VisibleLists[0].Name + ' - Similar'}));
			animSeparateColSimilar.add(new Tween(columnList[3], 0.25, {fillColor: (colorList2 + colorIdentical) / 2, lineColor: (colorList2 + colorIdentical) / 2}));
			animSeparateColSimilar.add(new Tween(columnList[3].getChildAt(0), 0.25, {text: model.VisibleLists[1].Name + ' - Similar'}));
			
			// Animate the column colors and headers before
			animReconcileCol.add(new Tween(columnList[0], 0.25, {fillColor: colorBackground, lineColor: colorBackground}));
			animReconcileCol.add(new Tween(columnList[0].getChildAt(0), 0.25, {text: ''}));
			animReconcileCol.add(new Tween(columnList[2], 0.25, {fillColor: colorBackground, lineColor: colorBackground}));
			animReconcileCol.add(new Tween(columnList[2].getChildAt(0), 0.25, {text: ''}));
			animReconcileCol.add(new Tween(columnList[4], 0.25, {fillColor: colorBackground, lineColor: colorBackground}));
			animReconcileCol.add(new Tween(columnList[4].getChildAt(0), 0.25, {text: ''}));
			
			animReconcileCol.add(new Tween(columnList[1], 0.25, {fillColor: colorOriginal, lineColor: colorOriginal}));
			animReconcileCol.add(new Tween(columnList[1].getChildAt(0), 0.25, {text: model.VisibleLists[0].Name}));
			animReconcileCol.add(new Tween(columnList[3], 0.25, {fillColor: colorOriginal, lineColor: colorOriginal}));
			animReconcileCol.add(new Tween(columnList[3].getChildAt(0), 0.25, {text: model.VisibleLists[1].Name}));
			
			// Enable the reconcile button after
			animMerge.addEventListener(TransitionEvent.END, function(e:Event):void {
				mergeBtn.enabled = true;
				mergeBtn.label = "Merge";
			});
			animSeparate.addEventListener(TransitionEvent.END, function(e:Event):void {
				mergeBtn.enabled = true;
				mergeBtn.label = "Separate";
			});
		}
		
		protected function ReconcileButtonClick(event:MouseEvent):void
		{
			// Disable the button for the animation duration
			mergeBtn.enabled = false;
			
			if (merged)
			{
				animMerge.play();
				merged = false;
			}
			else
			{
				animSeparate.play();
				merged = true;
			}
		}
		
		private function PopupButtonRollOver(event:MouseEvent):void
		{
			event.currentTarget.color = 0xffff0000;
		}
		
		private function PopupButtonRollOut(event:MouseEvent):void
		{
			event.currentTarget.color = 0xff330000;
		}
		
		private function AcceptClick(event:MouseEvent):void
		{
			if (popup.alpha == 0)
				return;
			
			var item:ListItem = selectedSprite.data.item as ListItem;
			model.AddActionListItem(item, true);
		}
		
		private function RejectClick(event:MouseEvent):void
		{
			if (popup.alpha == 0)
				return;
			
			var item:ListItem = selectedSprite.data.item as ListItem;
			model.AddActionListItem(item, false);
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
		
		private function OnOptionsUpdated(event:TwinListEvent):void
		{
			var opt:Array = event.Data as Array;
			switch (opt[0]) {
				case OptionsPanelClass.OPT_FONTSIZE:
					textHeight = opt[1] as int;
					break;
				case OptionsPanelClass.OPT_AFTERACTION:
					removeAfterAction = opt[1] == OptionsPanelClass.OPTVAL_REMOVE;
					break;
			}
			OnViewUpdated(event);
		}
	}
}