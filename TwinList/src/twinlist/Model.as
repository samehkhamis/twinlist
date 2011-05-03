	package twinlist
{	
	import com.carlcalderon.arthropod.Debug;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	import mx.collections.ArrayCollection;
	import mx.collections.IList;
	import mx.collections.Sort;
	
	import twinlist.filter.IFilter;
	import twinlist.list.AttributeDescriptor;
	import twinlist.list.ItemAttribute;
	import twinlist.list.List;
	import twinlist.list.ListItem;
	import twinlist.list.ListSchema;
	import twinlist.list.SimilarityItem;
	import twinlist.xml.DifferenceItem;
	import twinlist.xml.XmlListLoader;
	import twinlist.xml.XmlSchemaLoader;
	import twinlist.xml.XmlSimilarityLoader;
	
	[Bindable]
	public final class Model extends EventDispatcher
	{
		// event strings
		public static const DATA_LOADED:String = "__DATA_LOADED__";
		public static const VIEW_UPDATED:String = "__VIEW_UPDATED__";
		public static const ACTION_TAKEN:String = "__ACTION_TAKEN__";
		public static const OPTIONS_UPDATED:String = "__OPTIONS_UPDATED__";
		// dataset strings
		public static const DATA_CARS:String = "__DATA_CARS__";
		public static const DATA_MED_REC:String = "__DATA_MED_REC__";
		public static const DATA_SOTU:String = "__DATA_SOTU__";
		// model
		private static var instance:Model = new Model();
		// sorting
		private static var defaultSort:Sort;
		// list info
		private var loaded:int = 0;
		private var schema:Object;
		private var lists:ArrayCollection;
		private var listIdx:Object;
		private var itemTwinHash:Object;
		private var visibleListIds:Array;
		private var listViewerData:ArrayCollection;
		private var listViewerIdxHash:Object;
		private var hashSimilarities:Object;
		// action lists
		private var acceptedItems:ArrayCollection;
		private var rejectedItems:ArrayCollection;
		private var visibleActionListIdx:int;
		// attributes
		private var itemAttributes:ArrayCollection;
		private var categoricalAttributes:ArrayCollection;
		private var numericalAttributes:ArrayCollection;
		// publicly set variables
		private var selectedItem:ListItem;
		private var sizeByAttribute:AttributeDescriptor;
		private var colorByAttribute:AttributeDescriptor;
		private var groupByAttribute:AttributeDescriptor;
		private var sortByAttribute:AttributeDescriptor;
		private var filterList:ArrayCollection;
		//data
		private var list1File:String;
		private var list2File:String;
		private var simFile:String;
		
		// options hashmap
		private var options:Object;
		
		public function Model()
		{
			if (instance != null)
			  throw new Error("Model can only be accessed via Model.Instance()");
			
			// init
			loaded = 0;
			lists = new ArrayCollection();
			listIdx = new Object();
			itemTwinHash = new Object();
			visibleListIds = new Array(2);
			listViewerData = new ArrayCollection();
			listViewerIdxHash = new Object();
			hashSimilarities = new ArrayCollection();
			acceptedItems = new ArrayCollection();
			rejectedItems = new ArrayCollection();
			visibleActionListIdx = 0;
			itemAttributes = new ArrayCollection();
			categoricalAttributes = new ArrayCollection();
			numericalAttributes = new ArrayCollection();
			defaultSort = new Sort();
			SelectedItem = null;
			sizeByAttribute = null;
			colorByAttribute = null;
			groupByAttribute = null;
			sortByAttribute = null;
			filterList = new ArrayCollection();
			SetDataset(DATA_MED_REC);

			// default options
			options = new Object();
			SetOption(new Option(Option.OPT_FONTSIZE, 16));
			SetOption(new Option(Option.OPT_LINKIDENTICAL, true));
			SetOption(new Option(Option.OPT_AFTERACTION, Option.OPTVAL_REMOVE));			
		}
		
		public static function get Instance():Model
		{
			return instance;
		}

		public function SetDataset(dataset:String):void
		{
			switch (dataset) {
				case DATA_CARS:
					list1File = "../data/cars/FordFiesta.xml";
					list2File = "../data/cars/ToyotaCorolla.xml";
					simFile= "../data/cars/carSimilarities.xml";
					break;
				case DATA_MED_REC:
					list1File = "../data/medication/list1.xml";
					list2File = "../data/medication/list2.xml";
					simFile= "../data/medication/list1_list2_similarities.xml";
					break;
				case DATA_SOTU:
					list1File = "../data/sotu/bush08.0809.xml";
					list2File = "../data/sotu/obama09.0809.xml";
					simFile= "../data/sotu/bush_08_obama_09_similarities.xml";
					break;
			}
			LoadData();
		}
		
		public function GetOption(name:String):Option
		{
			if (name in options)
				return options[name];
			return null;
		}
		
		public function SetOption(option:Option):void
		{
			options[option.Name] = option;
			dispatchEvent(new TwinListEvent(OPTIONS_UPDATED, option));
		}
		
		public function get Lists():ArrayCollection
		{
			return lists;
		}
		
		public function get ListIndices():Object
		{
			return listIdx;
		}
		
		public function get ListViewerData():ArrayCollection
		{
			return listViewerData;
		}
		
		public function get AcceptedListItems():ArrayCollection
		{
			return acceptedItems;
		}
		
		public function AcceptedListContains(item:ListItem):int
		{
			for (var idx:int = 0; idx < acceptedItems.length; idx++) {
				if (acceptedItems[idx].Id == item.Id)
					return idx;
			}
			return -1;
		}
		
		public function get RejectedListItems():ArrayCollection
		{
			return rejectedItems;
		}
		
		public function RejectedListContains(item:ListItem):int
		{
			for (var idx:int = 0; idx < rejectedItems.length; idx++) {
				if (rejectedItems[idx].Id == item.Id)
					return idx;
			}
			return -1;
		}
		
		public function AddActionListItem(item:ListItem, accepted:Boolean):void
		{
			if (accepted) {
				if (AcceptedListContains(item) >= 0)
					return;
				acceptedItems.addItemAt(item, 0);
				visibleActionListIdx = 0;
			}
			else {
				if (RejectedListContains(item) >= 0)
					return;
				rejectedItems.addItemAt(item, 0);
				visibleActionListIdx = 1;
			}
			item.ActedOn = true;
			if (GetOption(Option.OPT_LINKIDENTICAL).Value) {
				var twin:ListItem = FindItemTwin(item);
				if (twin != null)
					twin.ActedOn = true;
			}
			dispatchEvent(new TwinListEvent(ACTION_TAKEN));
			RefreshView();
		}
		
		public function AddActionListItems(items:IList, accepted:Boolean):void
		{
			var item:ListItem;
			var twin:ListItem;
			if (accepted) {
				for each (item in items) {
					if (AcceptedListContains(item) >= 0)
						continue;
					acceptedItems.addItemAt(item, 0);
					item.ActedOn = true;
				}
				visibleActionListIdx = 0;
			}
			else {
				for each (item in items) {
					if (RejectedListContains(item) >= 0)
						continue;
					rejectedItems.addItemAt(item, 0);
					item.ActedOn = true;
				}
				visibleActionListIdx = 1;
			}
			if (GetOption(Option.OPT_LINKIDENTICAL).Value) {
				for each (item in items) {
					twin = FindItemTwin(item);
					if (twin != null)
						twin.ActedOn = true;
				}
			}
			dispatchEvent(new TwinListEvent(ACTION_TAKEN));
			RefreshView();
		}
		
		public function DelActionListItem(item:ListItem, accepted:Boolean):void
		{
			var idx:int;
			if (accepted) {
				idx = AcceptedListContains(item);
				if (idx < 0)
					return;
				acceptedItems.removeItemAt(idx);
				visibleActionListIdx = 0;
			}
			else {
				idx = RejectedListContains(item);
				if (idx < 0)
					return;
				rejectedItems.removeItemAt(idx);
				visibleActionListIdx = 1;
			}
			item.ActedOn = false;
			if (GetOption(Option.OPT_LINKIDENTICAL).Value) {
				var twin:ListItem = FindItemTwin(item);
				if (twin != null)
					twin.ActedOn = false;
			}
			dispatchEvent(new TwinListEvent(ACTION_TAKEN));
			RefreshView();
		}
		
		public function get VisibleActionListIndex():int
		{
			return visibleActionListIdx;
		}
		
		public function get SelectedItem():ListItem
		{
			return selectedItem;
		}
		public function set SelectedItem(listItem:ListItem):void
		{
			selectedItem = listItem;
		}
		
		public function get ItemAttributes():ArrayCollection
		{
			return itemAttributes;
		}
		
		public function get CategoricalAttributes():ArrayCollection
		{
			return categoricalAttributes;
		}
		
		public function get NumericalAttributes():ArrayCollection
		{
			return numericalAttributes;
		}
		
		public function get SizeBy():AttributeDescriptor
		{
			return sizeByAttribute;
		}
		public function set SizeBy(attributeName:AttributeDescriptor):void
		{
			sizeByAttribute = attributeName;
		}
		
		public function get ColorBy():AttributeDescriptor
		{
			return colorByAttribute;
		}
		public function set ColorBy(attributeName:AttributeDescriptor):void
		{
			colorByAttribute = attributeName;
		}
		
		public function get GroupBy():AttributeDescriptor
		{
			return groupByAttribute;
		}
		public function set GroupBy(attributeName:AttributeDescriptor):void
		{
			groupByAttribute = attributeName;
			SortListViewerData();
		}
		
		public function get SortBy():AttributeDescriptor
		{
			return sortByAttribute;
		}
		public function set SortBy(attributeName:AttributeDescriptor):void
		{
			sortByAttribute = attributeName;
			SortListViewerData();
		}
		
		public function get Filters():ArrayCollection
		{
			return filterList;
		}
		
		public function FilterListContains(filter:IFilter):int
		{
			for (var idx:int = 0; idx < filterList.length; idx++) {
				if (filterList[idx].AttributeName == filter.AttributeName)
					return idx;
			}
			return -1;
		}
		
		public function AddFilter(filter:IFilter):void
		{
			if (FilterListContains(filter) >= 0)
				return;
			filterList.addItem(filter);
			FilterListViewerData();
		}
		
		public function DelFilter(filter:IFilter):void
		{
			var idx:int = FilterListContains(filter);
			if (idx >= 0) {
				filterList.removeItemAt(idx);
			}
			FilterListViewerData();
		}
		
		public function get VisibleLists():Array
		{
			return [lists[listIdx[visibleListIds[0]]], lists[listIdx[visibleListIds[1]]]];
		}
		
		public function SetVisibleLists(id1:String, id2:String):void
		{
			visibleListIds[0] = id1;
			visibleListIds[1] = id2;
			ReconcileLists(lists[listIdx[id1]], lists[listIdx[id2]]);
			DetectAttributes();
		}
		
		public function FilterListViewerData():void
		{
			var newLists:Array = new Array(2);
			for (var i:int = 0; i < 2; i++) {
				var list:List = lists[listIdx[visibleListIds[i]]];
				newLists[i] = new List(list.Id, list.Name);
				for each (var item:ListItem in list) {
					var keep:Boolean = true;
					for each (var f:IFilter in Filters) {
						keep &&= f.Apply(item);
					}
					item.Display = keep;
//					if (keep)
//						newLists[i].addItem(item);
				}
			}
			RefreshView();
//			ReconcileLists(newLists[0], newLists[1]);
//			if (SortBy != null || GroupBy != null)
//				SortListViewerData();
//			else {
//				RefreshView();
//			}
		}
		
		private function FindItemTwin(item:ListItem):ListItem
		{
			if (item.Id in itemTwinHash)
				return itemTwinHash[item.Id];
//			if (item.Id in listViewerIdxHash)
//			{
//				var lvi:ListViewerItem = listViewerData[listViewerIdxHash[item.Id]];
//				if (lvi.Identical1 != null && lvi.Identical1.Id != item.Id)
//					return lvi.Identical1;
//				else if (lvi.Identical2 != null && lvi.Identical2.Id != item.Id)
//					return lvi.Identical2;
//			}
			return null;
		}
		
		private function SortListViewerData():void
		{
			var sort:Sort = new Sort();
			sort.compareFunction = SortFunction;
			sort.sort(listViewerData.source);
			RefreshView();
		}
		
		private function SortFunction(a:Object, b:Object, fields:Array):int
		{
			if (groupByAttribute == null && sortByAttribute == null)
				return defaultSort.compareFunction.call(null, a.RowIndex, b.RowIndex, fields);
			var item1:ListItem = GetListItemToSortOn(a as ListViewerItem);
			var item2:ListItem = GetListItemToSortOn(b as ListViewerItem);
			var val1:Object;
			var val2:Object;
			var sortVal:int = 0;
			if (groupByAttribute != null) {
				if (groupByAttribute.Name == "Name") {
					val1 = item1.Name;
					val2 = item2.Name;		
				}
				else {
					val1 = item1.Attributes[groupByAttribute.Name].Values[0];
					val2 = item2.Attributes[groupByAttribute.Name].Values[0];		
				}
				sortVal = defaultSort.compareFunction.call(null, val1, val2, fields);
			}
			if (sortVal != 0)
				return sortVal;
			if (sortByAttribute != null) {
				if (sortByAttribute.Name == "Name") {
					val1 = item1.Name;
					val2 = item2.Name;		
				}
				else {
					val1 = item1.Attributes[sortByAttribute.Name].Values[0];
					val2 = item2.Attributes[sortByAttribute.Name].Values[0];		
				}
				sortVal = defaultSort.compareFunction.call(null, val1, val2, fields);
			}
			return sortVal;
		}
		
		private function GetListItemToSortOn(listViewerItem:ListViewerItem):ListItem
		{
			if (listViewerItem.Identical1 != null)
				return listViewerItem.Identical1;
			else if (listViewerItem.L1Similar != null)
				return listViewerItem.L1Similar;
			else if (listViewerItem.L1Unique != null)
				return listViewerItem.L1Unique;
			else
				return listViewerItem.L2Unique;
		}
		
		private function RefreshView():void
		{
			if (SelectedItem != null && !SelectedItem.Display)
				SelectedItem = null;
			listViewerData.refresh();
			dispatchEvent(new TwinListEvent(VIEW_UPDATED));			
		}
		
		private function Reset():void
		{
			loaded = 0;
			lists = new ArrayCollection();
			listIdx = new Object();
			itemTwinHash = new Object();
			visibleListIds = new Array(2);
			listViewerData = new ArrayCollection();
			listViewerIdxHash = new Object();
			hashSimilarities = new ArrayCollection();
			acceptedItems.removeAll();
			rejectedItems.removeAll();
			visibleActionListIdx = 0;
			itemAttributes.removeAll();
			categoricalAttributes.removeAll();
			numericalAttributes.removeAll();
			SelectedItem = null;
			sizeByAttribute = null;
			colorByAttribute = null;
			groupByAttribute = null;
			sortByAttribute = null;
			filterList.removeAll();
		}
		
		private function LoadData():void
		{
			Reset();
			new XmlListLoader(list1File, OnReadListXmlComplete);
			new XmlListLoader(list2File, OnReadListXmlComplete);	
			new XmlSimilarityLoader(simFile, OnReadSimilarityXmlComplete);
		}
		
		private function OnReadSchemaXmlComplete(schema:ListSchema):void
		{
			this.schema = schema;
		}

		private function OnReadListXmlComplete(list:List):void
		{
			// update index hash and add to lists
			listIdx[list.Id] = lists.length;
			lists.addItem(list);
			loaded++;
			// check for data load complete
			if (loaded == 3) {
				FinishInit();
			}
		}
		
		private function OnReadSimilarityXmlComplete(hash:Object):void
		{
			// Setting similarities to hash of similarities in the model.
			hashSimilarities = hash;
			loaded++;
			// check for data load complete
			if (loaded == 3) {
				FinishInit();
			}
		}
		
		private function FinishInit():void
		{
			SetVisibleLists(lists[0].Id, lists[1].Id);
			dispatchEvent(new TwinListEvent(DATA_LOADED));
		}
		
		private function DetectAttributes():void
		{
			// local vars
			var added:Object = new Object();
			var attrNames:Array = new Array();
			// add name field
			added["Name"] = new AttributeDescriptor("Name", ItemAttribute.TYPE_GENERAL);
			attrNames.push("Name");
			// iterate over all lists, items and detect attributes
			for (var i:int = 0; i < 2; i++) {
				var list:List = lists[listIdx[visibleListIds[i]]];
				for each (var item:ListItem in list) {
					if (!added["Name"].Values.contains(item.Name))
						added["Name"].Values.addItem(item.Name);
					for each (var a:ItemAttribute in item.Attributes) {
						if (!(a.Name in added)) {
							added[a.Name] = new AttributeDescriptor(a.Name, a.Type);
							added[a.Name].Properties[AttributeDescriptor.PROP_UNIT] = a.Unit;
							attrNames.push(a.Name);
						}
						if (a.Type == ItemAttribute.TYPE_NUMERICAL) {
							var minVal:Number = added[a.Name].Properties[AttributeDescriptor.PROP_MINVAL];
							var maxVal:Number = added[a.Name].Properties[AttributeDescriptor.PROP_MAXVAL];
							for each (var val:Number in a.Values) {
								if (isNaN(minVal) || minVal > val)
									minVal = val;
								if (isNaN(maxVal) || maxVal < val)
									maxVal = val;
							}
							added[a.Name].Properties[AttributeDescriptor.PROP_MINVAL] = minVal;
							added[a.Name].Properties[AttributeDescriptor.PROP_MAXVAL] = maxVal;
						}
						for each (var obj:Object in a.Values) {
							if (!added[a.Name].Values.contains(obj))
								added[a.Name].Values.addItem(obj);
						}
					}
				}
			}
			// empty current collections
			itemAttributes.removeAll();
			categoricalAttributes.removeAll();
			numericalAttributes.removeAll();
			// add attributes to collections
			// (using attrNames array to preserve ordering)
			var sort:Sort = new Sort();
			for each (var name:String in attrNames) {
				var ad:AttributeDescriptor = added[name];
				sort.sort(ad.Values.source);
				itemAttributes.addItem(ad);
				switch (ad.Type) {
					case ItemAttribute.TYPE_CATEGORICAL: categoricalAttributes.addItem(ad); break;
					case ItemAttribute.TYPE_NUMERICAL: numericalAttributes.addItem(ad); break;
				}			
			}
		}
		
		private function ReconcileLists(list1:List, list2:List):void
		{
			listViewerIdxHash = new Object();
			listViewerData.removeAll();
			// hash item IDs in either list
			var map1:Object = new Object();
			var map2:Object = new Object();
			{
				var item:ListItem;
				for each (item in list1) {
					map1[item.Id] = item;
				}
				for each (item in list2) {
					map2[item.Id] = item;
				}
			}
			// iterate over similarity hash and find corresponding items
			var item1:ListItem;
			var item2:ListItem;
			var lvi:ListViewerItem;
			var idx:int = 0;
			for each (var simItem:SimilarityItem in hashSimilarities) {
				lvi = new ListViewerItem();
				lvi.RowIndex = idx;
				if (simItem.Type == SimilarityItem.IDENTICAL) {
					// identical
					item1 = map1[simItem.L1Id] as ListItem;
					if (item1 != null) {
						lvi.Identical1 = item1;
						listViewerIdxHash[item1.Id] = idx;
					}
					item2 = map2[simItem.L2Id] as ListItem;
					if (item2 != null) {
						lvi.Identical2 = item2;
						listViewerIdxHash[item2.Id] = idx;
					}
					if (lvi.Identical1 != null || lvi.Identical2 != null) {
						listViewerData.addItem(lvi);
						++idx;
					}
					if (item1 != null && item2 != null) {
						itemTwinHash[item1.Id] = item2;
						itemTwinHash[item2.Id] = item1;
					}
				}
				else if (simItem.Type == SimilarityItem.SIMILAR) {
					// similar
					var diff:DifferenceItem;
					item1 = map1[simItem.L1Id] as ListItem;
					if (item1 != null) {
						for each (diff in simItem.AttributeDifferences) {
							if (diff.Name == "Name")
								item1.NameUnique = true;
							else
								item1.Attributes[diff.Name].Unique = true;
						}
						lvi.L1Similar = item1;
						listViewerIdxHash[item1.Id] = idx;
					}
					item2 = map2[simItem.L2Id] as ListItem;
					if (item2 != null) {
						for each (diff in simItem.AttributeDifferences) {
							if (diff.Name == "Name")
								item2.NameUnique = true;
							else
								item2.Attributes[diff.Name].Unique = true;
						}
						lvi.L2Similar = item2;
						listViewerIdxHash[item2.Id] = idx;
					}
					if (lvi.L1Similar != null || lvi.L2Similar != null) {
						listViewerData.addItem(lvi);
						++idx;
					}
				}
				else {
					// unique
					if (simItem.L1Id != "") {
						item1 = map1[simItem.L1Id] as ListItem;
						if (item1 != null) {
							lvi.L1Unique = item1;
							listViewerIdxHash[item1.Id] = idx;
							listViewerData.addItem(lvi);
							++idx;
						}
					}
					else {
						item2 = map2[simItem.L2Id] as ListItem;
						if (item2 != null) {
							lvi.L2Unique = item2;
							listViewerIdxHash[item2.Id] = idx;
							listViewerData.addItem(lvi);
							++idx;
						}
					}
				}
			}
		}
	}
}