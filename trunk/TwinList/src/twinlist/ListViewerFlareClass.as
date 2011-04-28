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
	import mx.events.FlexEvent;
	
	import spark.components.Button;
	import spark.components.Group;
	import spark.components.Scroller;
	
	import twinlist.list.ItemAttribute;
	import twinlist.list.ListItem;
	
	[Bindable]
	public class ListViewerFlareClass extends Group
	{
		protected var model:Model = Model.Instance;
		// flare vis
		protected var vis:Visualization;
		protected var stateVis:Visualization;
		// components
		public var animBtn:Button;
		public var scroller:Scroller;
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
		private var fontSizeItem:int = 16;
		private var fontSizeHeader:int = 16;
		private var fontSizePopup:int = 16;
		private var fontSizeGroupHeader:int = 12;
		private var fontString:String = "Sans Serif";
		// animation
		private var reset:Boolean;
		private var animState:int;
		private var animMatch:Array;
		private var animReset:Array;
		private var speedCoef:Number = 1;
		private var stateSprites:Array;
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
		private var colorStateActive:uint = 0xffdddddd;
		private var colorStateInactive:uint = 0xfffffff;
		private var colorStateText:uint = colorText;
		// options
		private var linkIdentical:Boolean = true;
		private var removeAfterAction:Boolean = true;
		
		public function ListViewerFlareClass()
		{
			super();
			vis = new Visualization();
			stateVis = new Visualization();
			reset = true;
			animState = 0;
			model.addEventListener(Model.DATA_LOADED, OnDataLoaded);
			model.addEventListener(Model.VIEW_UPDATED, OnViewUpdated);
			model.addEventListener(Model.OPTIONS_UPDATED, OnOptionsUpdated);
		}
		
		private function OnDataLoaded(event:Event):void
		{
			// create state visualization
			CreateStateVis();
			//SetState(0);
			
			// Get visList
			visHash = CreateVisHash(model.ListViewerData);
			
			// create columns
			columnList = CreateColumns();
			for each (var col:Sprite in columnList) {
				vis.addChild(col);
			}
			// add header horizontal lines
			line1 = CreateHorizontalLine(1);
			line2 = CreateHorizontalLine(2 * HeaderFontSize + TextSpacing);
			vis.addChild(line1);
			vis.addChild(line2);
			
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
		
		private function OnViewUpdated(event:Event):void
		{
			// reset selected sprite
			selectedSprite = null;
			
			// Get new visList
			var newVisHash:Object = CreateVisHash(model.ListViewerData);
			
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
			// fix columns
			var x:int = 0;
			for each (var rect:RectSprite in columnList)
			{
				animUpdate.add(new Tween(rect, 0.5, {w: columnWidth, h: columnHeight, x: x}));
				x += columnWidth;				
			}
			animUpdate.add(new Tween(line1, 0.5, {x2: 5 * columnWidth}));
			animUpdate.add(new Tween(line2, 0.5, {x2: 5 * columnWidth}));
			// fix group headers
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
						if (model.GroupBy != null)
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
						if (model.GroupBy != null)
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
						if (model.GroupBy != null)
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
						if (model.GroupBy != null)
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
						if (model.GroupBy != null)
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
						if (model.GroupBy != null)
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
			line.y1 = HeaderFontSize;
			line.x2 = 0;
			line.y2 = HeaderFontSize;
			line.lineWidth = 2;
			
			var header:TextSprite = new TextSprite(value);
			header.font = fontString;
			header.color = colorText;
			header.size = GroupHeaderFontSize;
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
			header.size = HeaderFontSize;
			header.font = fontString;
			header.bold = true;
			header.letterSpacing = 2;
			//header.horizontalAnchor = TextSprite.CENTER;
			header.x = 10;//columnWidth / 2;
			header.y = 0;
			
			var button:TextSprite = new TextSprite("(Accept All)");
			if (index % 2 == 0) {
				button.alpha = 0;
				button.visible = false;
			}
			button.color = colorText;
			button.size = HeaderFontSize - 4;
			button.font = fontString;
			//button.horizontalAnchor = TextSprite.CENTER;
			button.x = 10;//columnWidth / 2;
			button.y = HeaderFontSize + 4;
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

			return rect;
		}
		
		private function CreateColumns():ArrayCollection
		{
			var colList:ArrayCollection = new ArrayCollection();
			colList.addItem(CreateColumn(0, colorBackground, model.VisibleLists[0].Name + " - Unique"));
			colList.addItem(CreateColumn(1, colorOriginal, model.VisibleLists[0].Name));
			colList.addItem(CreateColumn(2, colorBackground, "Identical"));
			colList.addItem(CreateColumn(3, colorOriginal, model.VisibleLists[1].Name));
			colList.addItem(CreateColumn(4, colorBackground, model.VisibleLists[1].Name + " - Unique"));
			return colList;
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
			nameText.size = ItemFontSize;
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
				attrText.size = ItemFontSize - 4;
				attrText.font = fontString;
				attrText.x = x;
				attrText.y = ItemFontSize + 4;
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
			acceptBtn.size = PopupFontSize;
			acceptBtn.font = fontString;
			acceptBtn.color = 0xff330000;
			acceptBtn.buttonMode = true;
			acceptBtn.addEventListener(MouseEvent.MOUSE_OVER, PopupButtonRollOver);
			acceptBtn.addEventListener(MouseEvent.MOUSE_OUT, PopupButtonRollOut);
			acceptBtn.addEventListener(MouseEvent.MOUSE_UP, AcceptClick);
			
			var rejectBtn:TextSprite = new TextSprite("Reject?");
			rejectBtn.size = PopupFontSize;
			rejectBtn.font = fontString;
			rejectBtn.color = 0xff330000;
			rejectBtn.buttonMode = true;
			rejectBtn.y = acceptBtn.height;
			rejectBtn.addEventListener(MouseEvent.MOUSE_OVER, PopupButtonRollOver);
			rejectBtn.addEventListener(MouseEvent.MOUSE_OUT, PopupButtonRollOut);
			rejectBtn.addEventListener(MouseEvent.MOUSE_UP, RejectClick);
			
			popup = new RectSprite(0, 0, acceptBtn.width, acceptBtn.height + rejectBtn.height);
			popup.fillColor = popup.lineColor = 0x55aaaaaa;
			popup.alpha = 0;
			popup.addChild(acceptBtn);
			popup.addChild(rejectBtn);
			
			// Create the timer
			timer = new Timer(250);
			timer.addEventListener(TimerEvent.TIMER, ClickTimer);
		}
		
		private function CreateStateVis():void
		{
			var circ:DataSprite;
			var text:TextSprite;
			var stateText:Array = ["Separate", "Find Identical", "Find Unique", "Find Similar"];
			var width:int = 75;
			var w:int = 10;
			
			stateSprites = new Array(4);
			for (var i:int = 0; i < stateText.length; i++) {
				circ = new DataSprite();
				circ.data = i;
				circ.size = 1.5;
				circ.fillColor = colorStateInactive;
				circ.lineColor = colorStateActive;
				circ.lineWidth = 2;
				circ.buttonMode = true;
				circ.x = width / 2 + w; 
				circ.y = 20;
				w += width + 10;
				text = new TextSprite(stateText[i]);
				text.font = fontString;
				text.color = colorStateText;
				text.size = 12;
				text.buttonMode = true;
				text.x = 0;
				text.y = -27;
				text.horizontalAnchor = TextSprite.CENTER;
				circ.addChild(text);
				stateSprites[i] = circ;
				stateVis.addChild(circ);
				circ.addEventListener(MouseEvent.ROLL_OVER, StateRollOver);
				circ.addEventListener(MouseEvent.ROLL_OUT, StateRollOut);
				circ.addEventListener(MouseEvent.CLICK, OnStateClick);
			}
			stateVis.update();
		}
		
		private function UpdateAnimations():void
		{
			// local vars
			var i:int;
			
			// reset/merge/separate sequences
			animMatch = new Array(3);
			animReset = new Array(3);
			for (i = 0; i < 3; i++) {
				animMatch[i] = new Sequence();
				animReset[i] = new Sequence();
			}
			
			// parallel animations
			var animMatchColIdentical:Parallel = new Parallel();
			var animMatchColUnique:Parallel = new Parallel();
			var animMatchColSimilar:Parallel = new Parallel();
			var animMatchIdentical:Parallel = new Parallel();
			var animMatchSimilar:Parallel = new Parallel();
			var animMatchUnique:Parallel = new Parallel();
			var animResetColIdentical:Parallel = new Parallel();
			var animResetColUnique:Parallel = new Parallel();
			var animResetColSimilar:Parallel = new Parallel();
			var animResetIdentical:Parallel = new Parallel();
			var animResetSimilar:Parallel = new Parallel();
			var animResetUnique:Parallel = new Parallel();
			
			// add parallels to appropriate sequences
			animMatch[0].add(animMatchColIdentical);
			animMatch[0].add(animMatchIdentical);
			animMatch[1].add(animMatchColUnique);
			animMatch[1].add(animMatchUnique);
			animMatch[2].add(animMatchColSimilar);
			animMatch[2].add(animMatchSimilar);
			animReset[0].add(animResetColIdentical);
			animReset[0].add(animResetIdentical);
			animReset[1].add(animResetColUnique);
			animReset[1].add(animResetUnique);
			animReset[2].add(animResetColSimilar);
			animReset[2].add(animResetSimilar);
						
			// item animations
			for each (var sprite:DataSprite in visHash)
			{
				if (sprite.data.properties.type == 0) {
					animMatchIdentical.add(new Tween(sprite, 1*AnimationSpeed, {x: sprite.data.properties.x2, y: sprite.data.properties.y2}));
					animResetIdentical.add(new Tween(sprite, 1*AnimationSpeed, {x: sprite.data.properties.x1, y: sprite.data.properties.y1}));
				}
				else if (sprite.data.properties.type == 1) {
					animMatchSimilar.add(new Tween(sprite, 1*AnimationSpeed, {x: sprite.data.properties.x2, y: sprite.data.properties.y2}));
					animResetSimilar.add(new Tween(sprite, 1*AnimationSpeed, {x: sprite.data.properties.x1, y: sprite.data.properties.y1}));
				}
				else if (sprite.data.properties.type == 2) {
					animMatchUnique.add(new Tween(sprite, 1*AnimationSpeed, {x: sprite.data.properties.x2, y: sprite.data.properties.y2}));
					animResetUnique.add(new Tween(sprite, 1*AnimationSpeed, {x: sprite.data.properties.x1, y: sprite.data.properties.y1}));
				}
				
				for (i = 0; i < sprite.numChildren; i++) {
					var child:Sprite = sprite.getChildAt(i) as Sprite;
					if (child is RectSprite) {
						if (sprite.data.properties.type == 0) {
							animMatchIdentical.add(new Tween(child, 1*AnimationSpeed, {alpha: 1}));
							animResetIdentical.add(new Tween(child, 1*AnimationSpeed, {alpha: 0}));
						}
						else if (sprite.data.properties.type == 1) {
							animMatchSimilar.add(new Tween(child, 1*AnimationSpeed, {alpha: 1}));
							animResetSimilar.add(new Tween(child, 1*AnimationSpeed, {alpha: 0}));
						}
						else if (sprite.data.properties.type == 2) {
							animMatchUnique.add(new Tween(child, 1*AnimationSpeed, {alpha: 1}));
							animResetUnique.add(new Tween(child, 1*AnimationSpeed, {alpha: 0}));
						}
					}
				}
			}

			// Animate group headers
			for each (var header:Sprite in groupVisList)
			{
				animMatchSimilar.add(new Tween(header, 0.5*AnimationSpeed, {alpha: 1}));
				animResetSimilar.add(new Tween(header, 0.5*AnimationSpeed, {alpha: 0}));
			}

			// step-by-step "match" column animation
			var seq:Sequence;
			animMatchColIdentical.add(new Tween(columnList[2], 0.25*AnimationSpeed, {fillColor: colorIdentical, lineColor: colorIdentical}));
			seq = new Sequence();
			seq.add(new Tween(columnList[2].getChildAt(0), 0, {visible: true}));
			seq.add(new Tween(columnList[2].getChildAt(0), 0.25*AnimationSpeed, {alpha: 1}));
			animMatchColIdentical.add(seq);
			seq = new Sequence();
			seq.add(new Tween(columnList[2].getChildAt(1), 0, {visible: true}));
			seq.add(new Tween(columnList[2].getChildAt(1), 0.25*AnimationSpeed, {alpha: 1}));
			animMatchColIdentical.add(seq);
			animMatchColUnique.add(new Tween(columnList[0], 0.25*AnimationSpeed, {fillColor: colorList1, lineColor: colorList1}));
			seq = new Sequence();
			seq.add(new Tween(columnList[0].getChildAt(0), 0, {visible: true}));
			seq.add(new Tween(columnList[0].getChildAt(0), 0.25*AnimationSpeed, {alpha: 1}));
			animMatchColUnique.add(seq);
			seq = new Sequence();
			seq.add(new Tween(columnList[0].getChildAt(1), 0, {visible: true}));
			seq.add(new Tween(columnList[0].getChildAt(1), 0.25*AnimationSpeed, {alpha: 1}));
			animMatchColUnique.add(seq);
			animMatchColUnique.add(new Tween(columnList[4], 0.25*AnimationSpeed, {fillColor: colorList2, lineColor: colorList2}));
			seq = new Sequence();
			seq.add(new Tween(columnList[4].getChildAt(0), 0, {visible: true}));
			seq.add(new Tween(columnList[4].getChildAt(0), 0.25*AnimationSpeed, {alpha: 1}));
			animMatchColUnique.add(seq);
			seq = new Sequence();
			seq.add(new Tween(columnList[4].getChildAt(1), 0, {visible: true}));
			seq.add(new Tween(columnList[4].getChildAt(1), 0.25*AnimationSpeed, {alpha: 1}));
			animMatchColUnique.add(seq);
			animMatchColSimilar.add(new Tween(columnList[1], 0.25*AnimationSpeed, {fillColor: (colorList1 + colorIdentical) / 2, lineColor: (colorList1 + colorIdentical) / 2}));
			animMatchColSimilar.add(new Tween(columnList[1].getChildAt(0), 0.25*AnimationSpeed, {text: model.VisibleLists[0].Name + ' - Similar'}));
			animMatchColSimilar.add(new Tween(columnList[3], 0.25*AnimationSpeed, {fillColor: (colorList2 + colorIdentical) / 2, lineColor: (colorList2 + colorIdentical) / 2}));
			animMatchColSimilar.add(new Tween(columnList[3].getChildAt(0), 0.25*AnimationSpeed, {text: model.VisibleLists[1].Name + ' - Similar'}));
			
			// step-by-step "reset" column animation
			animResetColIdentical.add(new Tween(columnList[2], 0.25*AnimationSpeed, {fillColor: colorBackground, lineColor: colorBackground}));
			seq = new Sequence();
			seq.add(new Tween(columnList[2].getChildAt(0), 0.25*AnimationSpeed, {alpha: 0}));
			seq.add(new Tween(columnList[2].getChildAt(0), 0, {visible: false}));
			animResetColIdentical.add(seq);
			seq = new Sequence();
			seq.add(new Tween(columnList[2].getChildAt(1), 0.25*AnimationSpeed, {alpha: 0}));
			seq.add(new Tween(columnList[2].getChildAt(1), 0, {visible: false}));
			animResetColIdentical.add(seq);
			animResetColUnique.add(new Tween(columnList[0], 0.25, {fillColor: colorBackground, lineColor: colorBackground}));
			seq = new Sequence();
			seq.add(new Tween(columnList[0].getChildAt(0), 0.25*AnimationSpeed, {alpha: 0}));
			seq.add(new Tween(columnList[0].getChildAt(0), 0, {visible: false}));
			animResetColUnique.add(seq);
			seq = new Sequence();
			seq.add(new Tween(columnList[0].getChildAt(1), 0.25*AnimationSpeed, {alpha: 0}));
			seq.add(new Tween(columnList[0].getChildAt(1), 0, {visible: false}));
			animResetColUnique.add(seq);
			animResetColUnique.add(new Tween(columnList[4], 0.25*AnimationSpeed, {fillColor: colorBackground, lineColor: colorBackground}));
			seq = new Sequence();
			seq.add(new Tween(columnList[4].getChildAt(0), 0.25*AnimationSpeed, {alpha: 0}));
			seq.add(new Tween(columnList[4].getChildAt(0), 0, {visible: false}));
			animResetColUnique.add(seq);
			seq = new Sequence();
			seq.add(new Tween(columnList[4].getChildAt(1), 0.25*AnimationSpeed, {alpha: 0}));
			seq.add(new Tween(columnList[4].getChildAt(1), 0, {visible: false}));
			animResetColUnique.add(seq);
			animResetColSimilar.add(new Tween(columnList[1], 0.25*AnimationSpeed, {fillColor: colorOriginal, lineColor: colorOriginal}));
			animResetColSimilar.add(new Tween(columnList[1].getChildAt(0), 0.25*AnimationSpeed, {text: model.VisibleLists[0].Name}));
			animResetColSimilar.add(new Tween(columnList[3], 0.25*AnimationSpeed, {fillColor: colorOriginal, lineColor: colorOriginal}));
			animResetColSimilar.add(new Tween(columnList[3].getChildAt(0), 0.25*AnimationSpeed, {text: model.VisibleLists[1].Name}));
			
			// add event listeners
			for (i = 0; i < 3; i++) {
				animMatch[i].addEventListener(TransitionEvent.START, function(e:Event):void {
					SetState(animState+1);
				});
				animReset[i].addEventListener(TransitionEvent.START, function(e:Event):void {
					SetState(animState-1);
				});
			}
		}
		
		protected function AnimButtonClick(event:MouseEvent):void
		{
			if (reset)
				ChangeState(3);
			else
				ChangeState(0);
		}
		
		private function OnStateClick(event:MouseEvent):void
		{
			var sprite:DataSprite = event.currentTarget as DataSprite;
			var state:int = sprite.data as int;
			if (state == animState)
				return;
			ChangeState(state);
		}
		
		private function StateRollOver(event:MouseEvent):void
		{
			var sprite:DataSprite = event.currentTarget as DataSprite;
			if (sprite.data == animState)
				return;
			var text:TextSprite = sprite.getChildAt(0) as TextSprite;
			text.color = colorTextHighlighted;
		}
		
		private function StateRollOut(event:MouseEvent):void
		{
			var sprite:DataSprite = event.currentTarget as DataSprite;
			if (sprite.data == animState)
				return;
			var text:TextSprite = sprite.getChildAt(0) as TextSprite;
			text.color = colorStateText;
		}
		
		private function ChangeState(state:int):void
		{
			if (state == animState)
				return;
			EnableAnimButtons(false);
			var seq:Sequence = new Sequence();
			var i:int;
			if (state > animState) {
				for (i = animState; i < state; i++) {
					seq.add(animMatch[i]);
				}
			}
			else {
				for (i = animState; i > state; i--) {
					seq.add(animReset[i-1]);
				}
			}
			seq.addEventListener(TransitionEvent.END, function(e:Event):void {
				if (animState == 0) {
					reset = true;
					animBtn.label = "Match Lists";
				}
				else {
					reset = false;
					animBtn.label = "Reset View";
				}
				EnableAnimButtons(true);
			});
			seq.play();
		}
		
		private function SetState(state:int):void
		{
			// remove highlighting from old state
			var sprite:DataSprite = stateSprites[animState] as DataSprite;
			sprite.fillColor = colorStateInactive;
			var text:TextSprite = sprite.getChildAt(0) as TextSprite;
			text.color = colorStateText;
			// highlight new state
			sprite = stateSprites[state] as DataSprite;
			sprite.fillColor = colorStateActive;
			text = sprite.getChildAt(0) as TextSprite;
			text.color = colorTextHighlighted;
			animState = state;
			stateVis.update();
		}
		
		private function EnableAnimButtons(enabled:Boolean):void
		{
			animBtn.enabled = enabled;
			colorStateText = enabled ? colorText : colorTextGray;
			for (var i:int = 0; i < stateSprites.length; i++) {
				var sprite:DataSprite = stateSprites[i] as DataSprite;
				sprite.buttonMode = enabled;
				var text:TextSprite = sprite.getChildAt(0) as TextSprite;
				text.buttonMode = enabled;
				if (i != animState)
					text.color = colorStateText;
				if (enabled) {
					sprite.addEventListener(MouseEvent.ROLL_OVER, StateRollOver);
					sprite.addEventListener(MouseEvent.CLICK, OnStateClick);
				}
				else {
					sprite.removeEventListener(MouseEvent.ROLL_OVER, StateRollOver);
					sprite.removeEventListener(MouseEvent.CLICK, OnStateClick);
				}
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
			model.SelectedItem = null;
			model.AddActionListItem(item, true);
		}
		
		private function AcceptAll(colIdx:int):void
		{
			if (animState == 0) {
				if (colIdx == 1)
					model.AddActionListItems(model.VisibleLists[0], true);
				else
					model.AddActionListItems(model.VisibleLists[1], true);
			}
			else if (animState == 1) {
				if (colIdx == 1)
					model.AddActionListItems(colItems[0].source.concat(colItems[1].source), true);
				else if (colIdx == 3)
					model.AddActionListItems(colItems[3].source.concat(colItems[4].source), true);
				else
					model.AddActionListItems(colItems[2], true);
			}
			else
				model.AddActionListItems(colItems[colIdx], true);				
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
		
		public function get RemoveAfterAction():Boolean
		{
			return removeAfterAction;
		}
		public function set RemoveAfterAction(enabled:Boolean):void
		{
			removeAfterAction = enabled;
		}
		
		public function get AnimationSpeed():Number
		{
			return speedCoef;
		}
		public function set AnimationSpeed(value:Number):void
		{
			speedCoef = value;
		}
		
		public function get ItemFontSize():int
		{
			return fontSizeItem;
		}
		public function set ItemFontSize(value:int):void
		{
			fontSizeItem = value;
		}
		
		public function get HeaderFontSize():int
		{
			return fontSizeHeader;
		}
		public function set HeaderFontSize(value:int):void
		{
			fontSizeHeader = value;
		}
		
		public function get PopupFontSize():int
		{
			return fontSizePopup;
		}
		public function set PopupFontSize(value:int):void
		{
			fontSizePopup = value;
		}
		
		public function get GroupHeaderFontSize():int
		{
			return fontSizeGroupHeader;
		}
		public function set GroupHeaderFontSize(value:int):void
		{
			fontSizeGroupHeader = value;
		}
		
		private function get TextSpacing():int
		{
			return 14;//ItemFontSize - 2;
		}
		
		private function get HeaderHeight():int
		{
			return 2 * HeaderFontSize + 2 * TextSpacing;
		}
		
		private function get RowHeight():int
		{
			return 2 * ItemFontSize - 4 + TextSpacing;
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
					ItemFontSize = opt.Value as int;
					OnViewUpdated(event);
					break;
				case Option.OPT_ANIMATIONSPEED:
					AnimationSpeed = opt.Value as Number;
					UpdateAnimations();
					break;
				case Option.OPT_LINKIDENTICAL:
					linkIdentical = opt.Value as Boolean;
					break;
				case Option.OPT_AFTERACTION:
					RemoveAfterAction = opt.Value == Option.OPTVAL_REMOVE;
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