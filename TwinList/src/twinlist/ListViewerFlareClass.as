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
		public var resetBtn:Button;
		[Bindable]
		public var leftAnimBtn:Button;
		[Bindable]
		public var rightAnimBtn:Button;
		[Bindable]
		public var scroller:Scroller;
		[Bindable]
		public var canvas:Group;
		// data
		private var visHash:Object;
		private var columnList:ArrayCollection;
		private var line1:LineSprite;
		private var line2:LineSprite;
		private var rowIdxHash:Object;
		private var colItems:Array;
		// selected sprite
		private var selectedSprite:DataSprite = null;
		private var popup:RectSprite;
		private var timer:Timer;
		// column details
		private var columnWidth:int = 0;
		private var columnHeight:int = 0;
		// font details
		private var textHeight:int = 16;
		private var fontString:String = "Sans Serif";
		// animation
		private var reset:Boolean;
		private var animState:int;
		private var animReset:Sequence;
		private var animMerge:Array;
		private var animSeparate:Array;
		private var speedCoef:Number = 1;
		// grouping
		private var groupName:String = '';
		private var groupVisList:ArrayCollection = new ArrayCollection();
		// colors
		private var colorList1:uint = 0xffffffdd;
		private var colorList2:uint = 0xffddddff;
		private var colorIdentical:uint = 0xffddffdd;
		private var colorOriginal:uint = 0xffdddddd;
		private var colorText:uint = 0xff000000;
		private var colorTextGray:uint = 0xffaaaaaa;
		private var colorTextHighlighted:uint = 0xff0000ff;
		private var colorTextSelected:uint = 0xffff0000;
		private var colorBackground:uint = 0xffffffff;
		private var colorDiffHighlight1:uint = 0xffffff40;
		private var colorDiffHighlight2:uint = 0xffB0B0ff;
		// options
		private var linkIdentical:Boolean = true;
		private var removeAfterAction:Boolean = true;
		
		public function ListViewerFlareClass()
		{
			super();
			vis = new Visualization();
			reset = false;
			animState = 0;
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
			visHash = CreateVisHash(model.ListViewerData);
			
			// create columns
			CreateColumns();
			
			// Fix x values and draw sprites
			var sprite:DataSprite;
			for each (sprite in visHash)
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
			UpdateAnimations();
		}
		
		private function CreateColumns():void
		{
			columnList = new ArrayCollection();
			vis.addChild(CreateColumn(0, colorBackground, model.VisibleLists[0].Name + " - Unique"));
			vis.addChild(CreateColumn(1, colorOriginal, model.VisibleLists[0].Name));
			vis.addChild(CreateColumn(2, colorBackground, "Identical"));
			vis.addChild(CreateColumn(3, colorOriginal, model.VisibleLists[1].Name));
			vis.addChild(CreateColumn(4, colorBackground, model.VisibleLists[1].Name + " - Unique"));
			line1 = CreateHorizontalLine(1);
			line2 = CreateHorizontalLine(2 * HeaderTextHeight + TextSpacing);
			vis.addChild(line1);
			vis.addChild(line2);
		}
		
		private function FixColumns():void
		{
			var x:int = 0;
			var sprite:TextSprite;
			for each (var rect:RectSprite in columnList)
			{
				rect.h = columnHeight;
				rect.w = columnWidth;
				rect.x = x;
				x += columnWidth;
				
				sprite = rect.getChildAt(0) as TextSprite;
				sprite.size = HeaderTextHeight;
				sprite.x = columnWidth / 2;
				
				sprite = rect.getChildAt(1) as TextSprite;
				sprite.size = HeaderTextHeight - 4;
				sprite.x = columnWidth / 2;
				sprite.y = HeaderTextHeight + 4;
			}
			
			line1.x2 = 5 * columnWidth;
			line2.x2 = 5 * columnWidth;
			line2.y1 = line2.y2 = 2 * HeaderTextHeight + TextSpacing;
		}
		
		private function OnViewUpdated(event:Event):void
		{
			// reset selected sprite
			selectedSprite = null;
			
			// Get new visList
			var newVisHash:Object = CreateVisHash(model.ListViewerData);
			
			// Fix the visualization
			FixColumns();
			
			canvas.invalidateDisplayList();
			
			// create transition animation
			var animUpdate:Parallel = new Parallel();
			
			// fade out old sprites
			var sprite:DataSprite;
			for each (sprite in visHash) {
				animUpdate.add(new Tween(sprite, 0.5, {alpha: 0}));
			}
			// fade in new sprites
			for each (sprite in newVisHash) {
				if (model.SelectedItem != null && model.SelectedItem.Id == sprite.data.item.Id) {
					selectedSprite = sprite;
					Highlight(sprite, enabled);
				}
				sprite.data.properties.x1 *= columnWidth;
				sprite.data.properties.x2 *= columnWidth;
				var stateThresh:int;
				if (sprite.data.properties.type == 0) {
					// identical
					stateThresh = 0;
				}
				else if (sprite.data.properties.type == 1) {
					// similar
					stateThresh = 2;
				}
				else {
					// unique
					stateThresh = 1;
				}
				sprite.x = animState > stateThresh ? sprite.data.properties.x2 : sprite.data.properties.x1;
				sprite.y = animState > stateThresh ? sprite.data.properties.y2 : sprite.data.properties.y1;
				sprite.alpha = 0;
				vis.addChild(sprite);
				animUpdate.add(new Tween(sprite, 0.5, {alpha: 1}));
			}
			
			for each (var header:Sprite in groupVisList)
			{
				vis.addChild(header);
				if (animState == 3)
					animUpdate.add(new Tween(header, 0.5, {alpha: 1}));
			}
			
			// Update display and animate
			animUpdate.addEventListener(TransitionEvent.END, function(e:Event):void {
				OnTransitionComplete(newVisHash);
			});
			animUpdate.play();
		}
		
		private function OnTransitionComplete(newVisHash:Object):void
		{
			// remove old sprites
			for each (var sprite:DataSprite in visHash) {
				vis.removeChild(sprite);
			}
			visHash = newVisHash;
			
			// Update the two animation sequences
			UpdateAnimations();
		}
		
		private function CreateVisHash(data:ArrayCollection):Object
		{
			var l1y:int = HeaderHeight;
			var l2y:int = HeaderHeight;
			var ry:int = HeaderHeight;
			
			var visHash:Object = new Object();
			
			rowIdxHash = new Object();
			colItems = new Array(5);
			for (var i:int = 0; i < 5; i++) {
				colItems[i] = new ArrayCollection();
			}
			var newValue:String = '';
			var curValue:String = '';
			var valueCount:int = 0;
			var idx:int = 0;
			
			// Remove old group sprites if group changed
			var header:TextSprite;
			for each (header in groupVisList)
			{
				vis.removeChild(header);
			}
			groupVisList.removeAll();
			
			
			for each (var item:ListViewerItem in data)
			{
				var sprite:DataSprite;
				if (item.Identical1 != null || item.Identical2 != null)
				{
					if (item.Identical1 != null && (!item.Identical1.ActedOn || !RemoveAfterAction)) {
						if (model.GroupBy)
						{
							newValue = item.Identical1.Attributes[model.GroupBy.Name].Values[0].toString();
							if (newValue != curValue)
							{
								header = CreateGroupHeader(newValue, ry);
								groupVisList.addItem(header);
								
								curValue = newValue;
								ry += TextSpacing;
								valueCount++;
							}
						}
						sprite = CreateItemSprite(item.Identical1, 0, {rowIdx: idx, x1: 1, y1: l1y, x2: 2, y2: ry, type: 0});
						visHash[item.Identical1.Id] = sprite;
						if (!(idx in rowIdxHash))
							rowIdxHash[idx] = new Array();
						rowIdxHash[idx].push(sprite);
						if (!linkIdentical)
							colItems[2].addItem(item.Identical1);
						l1y += RowHeight;
					}
					if (item.Identical2 != null && (!item.Identical2.ActedOn || !RemoveAfterAction)) {
						if (model.GroupBy)
						{
							newValue = item.Identical2.Attributes[model.GroupBy.Name].Values[0].toString();
							if (newValue != curValue)
							{
								header = CreateGroupHeader(newValue, ry);
								groupVisList.addItem(header);
								
								curValue = newValue;
								ry += TextSpacing;
								valueCount++;
							}
						}
						sprite = CreateItemSprite(item.Identical2, 1, {rowIdx: idx, x1: 3, y1: l2y, x2: 2, y2: ry, type: 0});
						visHash[item.Identical2.Id] = sprite;
						if (!(idx in rowIdxHash))
							rowIdxHash[idx] = new Array();
						rowIdxHash[idx].push(sprite);
						colItems[2].addItem(item.Identical2);
						l2y += RowHeight;
					}
					ry += RowHeight;
					++idx;
				}
				else if (item.L1Similar != null || item.L2Similar != null)
				{
					var added:Boolean = false;
					if (item.L1Similar != null && (!item.L1Similar.ActedOn || !RemoveAfterAction)) {
						if (model.GroupBy)
						{
							newValue = item.L1Similar.Attributes[model.GroupBy.Name].Values[0].toString();
							if (newValue != curValue)
							{
								header = CreateGroupHeader(newValue, ry);
								groupVisList.addItem(header);
								
								curValue = newValue;
								ry += TextSpacing;
								valueCount++;
							}
						}
						sprite = CreateItemSprite(item.L1Similar, 0, {rowIdx: idx, x1: 1, y1: l1y, x2: 1, y2: ry, type: 1});
						visHash[item.L1Similar.Id] = sprite;
						if (!(idx in rowIdxHash))
							rowIdxHash[idx] = new Array();
						rowIdxHash[idx].push(sprite);
						colItems[1].addItem(item.L1Similar);
						l1y += RowHeight;
						added = true;
					}
					if (item.L2Similar != null && (!item.L2Similar.ActedOn || !RemoveAfterAction)) {
						if (model.GroupBy)
						{
							newValue = item.L2Similar.Attributes[model.GroupBy.Name].Values[0].toString();
							if (newValue != curValue)
							{
								if (added)
									ry += RowHeight;
								
								header = CreateGroupHeader(newValue, ry);
								groupVisList.addItem(header);
								
								curValue = newValue;
								ry += TextSpacing;
								valueCount++;
							}
						}
						sprite = CreateItemSprite(item.L2Similar, 1, {rowIdx: idx, x1: 3, y1: l2y, x2: 3, y2: ry, type: 1});
						visHash[item.L2Similar.Id] = sprite;
						if (!(idx in rowIdxHash))
							rowIdxHash[idx] = new Array();
						rowIdxHash[idx].push(sprite);
						colItems[3].addItem(item.L2Similar);
						l2y += RowHeight;
					}
					ry += RowHeight;
					++idx;
				}
				else if (item.L1Unique != null)
				{
					if (!item.L1Unique.ActedOn || !RemoveAfterAction) {
						if (model.GroupBy)
						{
							newValue = item.L1Unique.Attributes[model.GroupBy.Name].Values[0].toString();
							if (newValue != curValue)
							{
								header = CreateGroupHeader(newValue, ry);
								groupVisList.addItem(header);
								
								curValue = newValue;
								ry += TextSpacing;
								valueCount++;
							}
						}
						sprite = CreateItemSprite(item.L1Unique, 0, {rowIdx: idx, x1: 1, y1: l1y, x2: 0, y2: ry, type: 2});
						visHash[item.L1Unique.Id] = sprite;
						if (!(idx in rowIdxHash))
							rowIdxHash[idx] = new Array();
						rowIdxHash[idx].push(sprite);
						colItems[0].addItem(item.L1Unique);
						l1y += RowHeight;
						ry += RowHeight;
						++idx;
					}
				}
				else if (item.L2Unique != null)
				{
					if (!item.L2Unique.ActedOn || !RemoveAfterAction) {
						if (model.GroupBy)
						{
							newValue = item.L2Unique.Attributes[model.GroupBy.Name].Values[0].toString();
							if (newValue != curValue)
							{
								header = CreateGroupHeader(newValue, ry);
								groupVisList.addItem(header);
								
								curValue = newValue;
								ry += TextSpacing;
								valueCount++;
							}
						}
						sprite = CreateItemSprite(item.L2Unique, 1, {rowIdx: idx, x1: 3, y1: l2y, x2: 4, y2: ry, type: 2});
						visHash[item.L2Unique.Id] = sprite;
						if (!(idx in rowIdxHash))
							rowIdxHash[idx] = new Array();
						rowIdxHash[idx].push(sprite);
						colItems[4].addItem(item.L2Unique);
						l2y += RowHeight;
						ry += RowHeight;
						++idx;
					}
				}
			}
			
			// Calculate column dimensions
			var calculatedColumnWidth:int = 0;
			for each (sprite in visHash) {
				if (sprite.getChildAt(0).width > calculatedColumnWidth)
					calculatedColumnWidth = sprite.getChildAt(0).width;
			}
			columnWidth = calculatedColumnWidth + 40;
			columnHeight = HeaderHeight + model.ListViewerData.length * RowHeight + valueCount * (TextSpacing + 3) + TextSpacing;
			
			
			// Change group line width
			for each (header in groupVisList)
			{
				(header.getChildAt(1) as LineSprite).x2 = columnWidth * 5;
			}
			
			return visHash;
		}
		
		private function CreateGroupHeader(value:String, y:int):TextSprite
		{
			var line:LineSprite = new LineSprite();
			line.lineColor = colorText;
			line.x1 = 0;
			line.y1 = textHeight;
			line.x2 = 0;
			line.y2 = textHeight;
			line.lineWidth = 2;
			
			var header:TextSprite = new TextSprite(value);
			header.font = fontString;
			header.color = colorText;
			header.size = textHeight - 4;
			header.letterSpacing = 2;
			header.x = 0;
			header.y = y;
			header.alpha = 0;
			header.addChild(line);
			
			return header;
		}
		
		private function CreateColumn(index:int, color:int, title:String):RectSprite
		{
			var header:TextSprite = new TextSprite(title);
			if (index % 2 == 0) {
				header.alpha = 0;
				header.visible = false;
			}
			header.color = colorText;
			header.size = HeaderTextHeight;
			header.font = fontString;
			header.bold = true;
			header.letterSpacing = 2;
			header.horizontalAnchor = TextSprite.CENTER;
			header.x = columnWidth / 2;
			header.y = 0;
			
			var button:TextSprite = new TextSprite("(Accept All)");
			if (index % 2 == 0) {
				button.alpha = 0;
				button.visible = false;
			}
			button.color = colorText;
			button.size = HeaderTextHeight - 4;
			button.font = fontString;
			button.horizontalAnchor = TextSprite.CENTER;
			button.x = columnWidth / 2;
			button.y = HeaderTextHeight + 4;
			button.backgroundBorder = true;
			button.backgroundBorderColor = colorText;
			button.buttonMode = true;
			button.addEventListener(MouseEvent.ROLL_OVER, function(e:Event):void {
				button.color = colorTextHighlighted;
			});
			button.addEventListener(MouseEvent.ROLL_OUT, function(e:Event):void {
				button.color = colorText;
			});
			button.addEventListener(MouseEvent.MOUSE_DOWN, function(e:Event):void {
				AcceptAll(index);
			});
			
			var rect:RectSprite = new RectSprite(index * columnWidth, 0, columnWidth, columnHeight);
			rect.fillColor = rect.lineColor = color;
			rect.addChild(header);
			rect.addChild(button);
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
				highlight = CreateDiffHighlight(nameText, listIdx);
				highlight.alpha = animState == 3 ? 1 : 0;
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
					highlight = CreateDiffHighlight(attrText, listIdx);
					highlight.alpha = animState == 3 ? 1 : 0;
					sprite.addChild(highlight);
				}
				sprite.addChild(attrText);
				x += attrText.width;
			}
			
			return sprite;
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
		
		private function UpdateAnimations():void
		{
			// iterator
			var i:int;
			
			// reset/merge/separate sequences
			animReset = new Sequence();
			animMerge = new Array(3);
			animSeparate = new Array(3);
			for (i = 0; i < 3; i++) {
				animMerge[i] = new Sequence();
				animSeparate[i] = new Sequence();
			}		
			
			// parallel animations
			var animResetCol:Parallel = new Parallel();
			var animResetItems:Parallel = new Parallel();
			var animMergeColIdentical:Parallel = new Parallel();
			var animMergeColUnique:Parallel = new Parallel();
			var animMergeColSimilar:Parallel = new Parallel();
			var animMergeIdentical:Parallel = new Parallel();
			var animMergeSimilar:Parallel = new Parallel();
			var animMergeUnique:Parallel = new Parallel();
			var animSeparateColIdentical:Parallel = new Parallel();
			var animSeparateColUnique:Parallel = new Parallel();
			var animSeparateColSimilar:Parallel = new Parallel();
			var animSeparateIdentical:Parallel = new Parallel();
			var animSeparateSimilar:Parallel = new Parallel();
			var animSeparateUnique:Parallel = new Parallel();
			
			// add parallels to appropriate sequences
			animReset.add(animResetCol);
			animReset.add(animResetItems);
			animMerge[0].add(animMergeColIdentical);
			animMerge[0].add(animMergeIdentical);
			animMerge[1].add(animMergeColUnique);
			animMerge[1].add(animMergeUnique);
			animMerge[2].add(animMergeColSimilar);
			animMerge[2].add(animMergeSimilar);
			animSeparate[0].add(animSeparateColIdentical);
			animSeparate[0].add(animSeparateIdentical);
			animSeparate[1].add(animSeparateColUnique);
			animSeparate[1].add(animSeparateUnique);
			animSeparate[2].add(animSeparateColSimilar);
			animSeparate[2].add(animSeparateSimilar);
						
			// item animations
			for each (var sprite:DataSprite in visHash)
			{
				animResetItems.add(new Tween(sprite, 1*speedCoef, {x: sprite.data.properties.x1, y: sprite.data.properties.y1}));
				
				if (sprite.data.properties.type == 0) {
					animMergeIdentical.add(new Tween(sprite, 1*speedCoef, {x: sprite.data.properties.x2, y: sprite.data.properties.y2}));
					animSeparateIdentical.add(new Tween(sprite, 1*speedCoef, {x: sprite.data.properties.x1, y: sprite.data.properties.y1}));
				}
				else if (sprite.data.properties.type == 1) {
					animMergeSimilar.add(new Tween(sprite, 1*speedCoef, {x: sprite.data.properties.x2, y: sprite.data.properties.y2}));
					animSeparateSimilar.add(new Tween(sprite, 1*speedCoef, {x: sprite.data.properties.x1, y: sprite.data.properties.y1}));
				}
				else if (sprite.data.properties.type == 2) {
					animMergeUnique.add(new Tween(sprite, 1*speedCoef, {x: sprite.data.properties.x2, y: sprite.data.properties.y2}));
					animSeparateUnique.add(new Tween(sprite, 1*speedCoef, {x: sprite.data.properties.x1, y: sprite.data.properties.y1}));
				}
				
				for (i = 0; i < sprite.numChildren; i++) {
					var child:Sprite = sprite.getChildAt(i) as Sprite;
					if (child is RectSprite) {
						animResetCol.add(new Tween(child, 0.25*speedCoef, {alpha: 0}));
						if (sprite.data.properties.type == 0) {
							animMergeIdentical.add(new Tween(child, 1*speedCoef, {alpha: 1}));
							animSeparateIdentical.add(new Tween(child, 1*speedCoef, {alpha: 0}));
						}
						else if (sprite.data.properties.type == 1) {
							animMergeSimilar.add(new Tween(child, 1*speedCoef, {alpha: 1}));
							animSeparateSimilar.add(new Tween(child, 1*speedCoef, {alpha: 0}));
						}
						else if (sprite.data.properties.type == 2) {
							animMergeUnique.add(new Tween(child, 1*speedCoef, {alpha: 1}));
							animSeparateUnique.add(new Tween(child, 1*speedCoef, {alpha: 0}));
						}
					}
				}
			}

			// Animate group headers
			for each (var header:Sprite in groupVisList)
			{
				animMergeSimilar.add(new Tween(header, 0.5*speedCoef, {alpha: 1}));
				animSeparateSimilar.add(new Tween(header, 0.5*speedCoef, {alpha: 0}));
				animReset.add(new Tween(header, 0.5*speedCoef, {alpha: 0}));
			}
			
			// "reset" column animation
			animResetCol.add(new Tween(columnList[0], 0.5*speedCoef, {fillColor: colorBackground, lineColor: colorBackground}));
			seq = new Sequence();
			seq.add(new Tween(columnList[0].getChildAt(0), 0.5*speedCoef, {alpha: 0}));
			seq.add(new Tween(columnList[0].getChildAt(0), 0, {visible: false}));
			animResetCol.add(seq);
			seq = new Sequence();
			seq.add(new Tween(columnList[0].getChildAt(1), 0.5*speedCoef, {alpha: 0}));
			seq.add(new Tween(columnList[0].getChildAt(1), 0, {visible: false}));
			animResetCol.add(seq);
			animResetCol.add(new Tween(columnList[2], 0.5, {fillColor: colorBackground, lineColor: colorBackground}));
			seq = new Sequence();
			seq.add(new Tween(columnList[2].getChildAt(0), 0.5*speedCoef, {alpha: 0}));
			seq.add(new Tween(columnList[2].getChildAt(0), 0, {visible: false}));
			animResetCol.add(seq);
			seq = new Sequence();
			seq.add(new Tween(columnList[2].getChildAt(1), 0.5*speedCoef, {alpha: 0}));
			seq.add(new Tween(columnList[2].getChildAt(1), 0, {visible: false}));
			animResetCol.add(seq);
			animResetCol.add(new Tween(columnList[4], 0.5*speedCoef, {fillColor: colorBackground, lineColor: colorBackground}));
			seq = new Sequence();
			seq.add(new Tween(columnList[4].getChildAt(0), 0.5*speedCoef, {alpha: 0}));
			seq.add(new Tween(columnList[4].getChildAt(0), 0, {visible: false}));
			animResetCol.add(seq);
			seq = new Sequence();
			seq.add(new Tween(columnList[4].getChildAt(1), 0.5*speedCoef, {alpha: 0}));
			seq.add(new Tween(columnList[4].getChildAt(1), 0, {visible: false}));
			animResetCol.add(seq);
			animResetCol.add(new Tween(columnList[1], 0.5*speedCoef, {fillColor: colorOriginal, lineColor: colorOriginal}));
			animResetCol.add(new Tween(columnList[1].getChildAt(0), 0.5*speedCoef, {text: model.VisibleLists[0].Name}));
			animResetCol.add(new Tween(columnList[3], 0.5*speedCoef, {fillColor: colorOriginal, lineColor: colorOriginal}));
			animResetCol.add(new Tween(columnList[3].getChildAt(0), 0.5*speedCoef, {text: model.VisibleLists[1].Name}));
			
			// "merge" column animation
			var seq:Sequence;
			animMergeColIdentical.add(new Tween(columnList[2], 0.25*speedCoef, {fillColor: colorIdentical, lineColor: colorIdentical}));
			seq = new Sequence();
			seq.add(new Tween(columnList[2].getChildAt(0), 0, {visible: true}));
			seq.add(new Tween(columnList[2].getChildAt(0), 0.25*speedCoef, {alpha: 1}));
			animMergeColIdentical.add(seq);
			seq = new Sequence();
			seq.add(new Tween(columnList[2].getChildAt(1), 0, {visible: true}));
			seq.add(new Tween(columnList[2].getChildAt(1), 0.25*speedCoef, {alpha: 1}));
			animMergeColIdentical.add(seq);
			animMergeColUnique.add(new Tween(columnList[0], 0.25*speedCoef, {fillColor: colorList1, lineColor: colorList1}));
			seq = new Sequence();
			seq.add(new Tween(columnList[0].getChildAt(0), 0, {visible: true}));
			seq.add(new Tween(columnList[0].getChildAt(0), 0.25*speedCoef, {alpha: 1}));
			animMergeColUnique.add(seq);
			seq = new Sequence();
			seq.add(new Tween(columnList[0].getChildAt(1), 0, {visible: true}));
			seq.add(new Tween(columnList[0].getChildAt(1), 0.25*speedCoef, {alpha: 1}));
			animMergeColUnique.add(seq);
			animMergeColUnique.add(new Tween(columnList[4], 0.25*speedCoef, {fillColor: colorList2, lineColor: colorList2}));
			seq = new Sequence();
			seq.add(new Tween(columnList[4].getChildAt(0), 0, {visible: true}));
			seq.add(new Tween(columnList[4].getChildAt(0), 0.25*speedCoef, {alpha: 1}));
			animMergeColUnique.add(seq);
			seq = new Sequence();
			seq.add(new Tween(columnList[4].getChildAt(1), 0, {visible: true}));
			seq.add(new Tween(columnList[4].getChildAt(1), 0.25*speedCoef, {alpha: 1}));
			animMergeColUnique.add(seq);
			animMergeColSimilar.add(new Tween(columnList[1], 0.25*speedCoef, {fillColor: (colorList1 + colorIdentical) / 2, lineColor: (colorList1 + colorIdentical) / 2}));
			animMergeColSimilar.add(new Tween(columnList[1].getChildAt(0), 0.25*speedCoef, {text: model.VisibleLists[0].Name + ' - Similar'}));
			animMergeColSimilar.add(new Tween(columnList[3], 0.25*speedCoef, {fillColor: (colorList2 + colorIdentical) / 2, lineColor: (colorList2 + colorIdentical) / 2}));
			animMergeColSimilar.add(new Tween(columnList[3].getChildAt(0), 0.25*speedCoef, {text: model.VisibleLists[1].Name + ' - Similar'}));
			
			// "separate" column animation
			animSeparateColIdentical.add(new Tween(columnList[2], 0.25*speedCoef, {fillColor: colorBackground, lineColor: colorBackground}));
			seq = new Sequence();
			seq.add(new Tween(columnList[2].getChildAt(0), 0.25*speedCoef, {alpha: 0}));
			seq.add(new Tween(columnList[2].getChildAt(0), 0, {visible: false}));
			animSeparateColIdentical.add(seq);
			seq = new Sequence();
			seq.add(new Tween(columnList[2].getChildAt(1), 0.25*speedCoef, {alpha: 0}));
			seq.add(new Tween(columnList[2].getChildAt(1), 0, {visible: false}));
			animSeparateColIdentical.add(seq);
			animSeparateColUnique.add(new Tween(columnList[0], 0.25, {fillColor: colorBackground, lineColor: colorBackground}));
			seq = new Sequence();
			seq.add(new Tween(columnList[0].getChildAt(0), 0.25*speedCoef, {alpha: 0}));
			seq.add(new Tween(columnList[0].getChildAt(0), 0, {visible: false}));
			animSeparateColUnique.add(seq);
			seq = new Sequence();
			seq.add(new Tween(columnList[0].getChildAt(1), 0.25*speedCoef, {alpha: 0}));
			seq.add(new Tween(columnList[0].getChildAt(1), 0, {visible: false}));
			animSeparateColUnique.add(seq);
			animSeparateColUnique.add(new Tween(columnList[4], 0.25*speedCoef, {fillColor: colorBackground, lineColor: colorBackground}));
			seq = new Sequence();
			seq.add(new Tween(columnList[4].getChildAt(0), 0.25*speedCoef, {alpha: 0}));
			seq.add(new Tween(columnList[4].getChildAt(0), 0, {visible: false}));
			animSeparateColUnique.add(seq);
			seq = new Sequence();
			seq.add(new Tween(columnList[4].getChildAt(1), 0.25*speedCoef, {alpha: 0}));
			seq.add(new Tween(columnList[4].getChildAt(1), 0, {visible: false}));
			animSeparateColUnique.add(seq);
			animSeparateColSimilar.add(new Tween(columnList[1], 0.25*speedCoef, {fillColor: colorOriginal, lineColor: colorOriginal}));
			animSeparateColSimilar.add(new Tween(columnList[1].getChildAt(0), 0.25*speedCoef, {text: model.VisibleLists[0].Name}));
			animSeparateColSimilar.add(new Tween(columnList[3], 0.25*speedCoef, {fillColor: colorOriginal, lineColor: colorOriginal}));
			animSeparateColSimilar.add(new Tween(columnList[3].getChildAt(0), 0.25*speedCoef, {text: model.VisibleLists[1].Name}));
			
			// add event listeners
			animReset.addEventListener(TransitionEvent.END, function(e:Event):void {
				reset = true;
				animState = 0;
				resetBtn.enabled = true;
				leftAnimBtn.enabled = true;
				rightAnimBtn.enabled = true;
			});
			for (i = 0; i < 3; i++) {
				animMerge[i].addEventListener(TransitionEvent.END, function(e:Event):void {
					++animState;
					reset = false;
					resetBtn.enabled = true;
					leftAnimBtn.enabled = true;
					rightAnimBtn.enabled = true;
				});
				animSeparate[i].addEventListener(TransitionEvent.END, function(e:Event):void {
					--animState;
					if (animState == 0)
						reset = true;
					resetBtn.enabled = true;
					leftAnimBtn.enabled = true;
					rightAnimBtn.enabled = true;
				});
			}
		}
		
		protected function ResetButtonClick(event:MouseEvent):void
		{
			if (reset)
				return;
			resetBtn.enabled = false;
			leftAnimBtn.enabled = false;
			rightAnimBtn.enabled = false;
			animReset.play();
		}
		
		protected function LeftAnimClick(event:MouseEvent):void
		{
			if (animState <= 0 || animState > 3)
				return;
			resetBtn.enabled = false;
			leftAnimBtn.enabled = false;
			rightAnimBtn.enabled = false;
			animSeparate[animState-1].play();
		}
		
		protected function RightAnimClick(event:MouseEvent):void
		{
			if (animState < 0 || animState >= 3)
				return;
			resetBtn.enabled = false;
			leftAnimBtn.enabled = false;
			rightAnimBtn.enabled = false;
			animMerge[animState].play();
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
			model.SelectedItem = null;
			model.AddActionListItem(item, true);
		}
		
		private function AcceptAll(colIdx:int):void
		{
			if (reset)
				model.AddActionListItems(colItems[colIdx], true);
			else {
				if (colIdx == 1)
					model.AddActionListItems(model.VisibleLists[0], true);
				else
					model.AddActionListItems(model.VisibleLists[1], true);
			}		
		}
		
		private function RejectClick(event:MouseEvent):void
		{
			if (popup.alpha == 0)
				return;
			
			var item:ListItem = selectedSprite.data.item as ListItem;
			model.SelectedItem = null;
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
			return 2 * HeaderTextHeight + 2 * TextSpacing;
		}
		
		private function get RowHeight():int
		{
			return 2 * textHeight - 4 + TextSpacing;
		}
		
		private function get HeaderTextHeight():int
		{
			return textHeight;
		}
		
		private function get TextSpacing():int
		{
			return textHeight - 2;
		}
		
		private function Highlight(sprite:DataSprite, enabled:Boolean):void
		{
			var color:uint;
			if (!enabled)
				color = sprite.data.item.ActedOn ? colorTextGray : colorText;
			else if (sprite == selectedSprite)
				color = colorTextSelected;
			else
				color = colorTextHighlighted;
			var text:TextSprite;
			var i:int;
			for (i = 0; i < sprite.numChildren; i++) {
				text = sprite.getChildAt(i) as TextSprite;
				if (text != null)
					text.color = color;
			}
			if (linkIdentical) {
				var other:DataSprite = FindDuplicateRowIndex(sprite);
				if (other != null) {
					for (i = 0; i < other.numChildren; i++) {
						text = other.getChildAt(i) as TextSprite;
						if (text != null)
							text.color = color;
					}
				}
			}
		}

		private function CreateDiffHighlight(sprite:TextSprite, listIdx:int):RectSprite
		{
			var highlight:RectSprite = new RectSprite(sprite.x, sprite.y, sprite.width, sprite.height);
			highlight.fillColor = highlight.lineColor = listIdx == 0 ? colorDiffHighlight1 : colorDiffHighlight2;
			return highlight
		}
		
		private function OnOptionsUpdated(event:TwinListEvent):void
		{
			var opt:Option = event.Data as Option;
			switch (opt.Name) {
				case Option.OPT_FONTSIZE:
					textHeight = opt.Value as int;
					OnViewUpdated(event);
					break;
				case Option.OPT_ANIMATIONSPEED:
					speedCoef = opt.Value as Number;
					UpdateAnimations();
					break;
				case Option.OPT_LINKIDENTICAL:
					linkIdentical = opt.Value as Boolean;
					break;
				case Option.OPT_AFTERACTION:
					removeAfterAction = opt.Value == Option.OPTVAL_REMOVE;
					OnViewUpdated(event);
					break;
			}
		}
		
		private function FindDuplicateRowIndex(sprite:DataSprite):DataSprite
		{
			if (sprite == null || sprite.data.properties.type != 0)
				return null;
			var idx:int = sprite.data.properties.rowIdx;
			var item1:ListItem = sprite.data.item as ListItem;
			for each (var other:DataSprite in rowIdxHash[idx]) {
				var item2:ListItem = other.data.item as ListItem;
				if (sprite.data.properties.rowIdx == other.data.properties.rowIdx && item1.Id != item2.Id)
					return other;
			}
			return null;
		}
	}
}