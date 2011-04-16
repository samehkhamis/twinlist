package twinlist
{	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	import mx.collections.ArrayCollection;
	import mx.collections.Sort;
	
	import twinlist.filter.IFilter;
	import twinlist.list.AttributeDescriptor;
	import twinlist.list.ItemAttribute;
	import twinlist.list.List;
	import twinlist.list.ListItem;
	import twinlist.xml.XmlListLoader;

	[Bindable]
	public final class Model extends EventDispatcher
	{
		// event strings
		public static const DATA_LOADED:String = "DataLoaded";
		public static const VIEW_UPDATED:String = "ViewUpdated";
		// model
		private static var instance:Model = new Model();
		// sorting
		private static var defaultSort:Sort;
		// list info
		private var lists:ArrayCollection;
		private var listIdx:Object;
		private var visibleListIds:Array;
		private var listViewerData:ArrayCollection;
		private var actionListItems:ArrayCollection;
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
		
		public function Model()
		{
			if (instance != null)
				throw new Error("Model can only be accessed via Model.Instance()");
			
			// init
			lists = new ArrayCollection();
			listIdx = new Object();
			visibleListIds = new Array(2);
			listViewerData = new ArrayCollection();
			actionListItems = new ArrayCollection();
			itemAttributes = new ArrayCollection();
			categoricalAttributes = new ArrayCollection();
			numericalAttributes = new ArrayCollection();
			defaultSort = new Sort();
			selectedItem = null;
			sizeByAttribute = null;
			colorByAttribute = null;
			groupByAttribute = null;
			sortByAttribute = null;
			filterList = new ArrayCollection();
			// load data
			//LoadCannedData();
			new XmlListLoader("../data/list1.xml", OnReadXmlComplete);
			new XmlListLoader("../data/list2.xml", OnReadXmlComplete);
		}
		
		public static function get Instance():Model
		{
			return instance;
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
		
		public function get ActionListItems():ArrayCollection
		{
			return actionListItems;
		}
		
		public function ActionListContains(item:ListItem):int
		{
			for (var idx:int = 0; idx < actionListItems.length; idx++) {
				if (actionListItems[idx].Id == item.Id)
					return idx;
			}
			return -1;
		}
		
		public function AddActionListItem(item:ListItem):void
		{
			if (ActionListContains(item) >= 0)
				return;
			actionListItems.addItem(item);
		}
		
		public function DelActionListItem(item:ListItem):void
		{
			var idx:int = ActionListContains(item);
			if (idx >= 0) {
				actionListItems.removeItemAt(idx);
			}
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
		
		public function get VisibleListIds():Array
		{
			return visibleListIds;
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
					if (keep)
						newLists[i].addItem(item);
				}
			}
			ReconcileLists(newLists[0], newLists[1]);
			if (SortBy != null || GroupBy != null)
				SortListViewerData();
			else {
				listViewerData.refresh();
				dispatchEvent(new Event(VIEW_UPDATED));
			}
		}
		
		private function SortListViewerData():void
		{
			if (SortBy == null && GroupBy == null)
				return;
			var sort:Sort = new Sort();
			sort.compareFunction = SortFunction;
			sort.sort(listViewerData.source);
			listViewerData.refresh();
			dispatchEvent(new Event(VIEW_UPDATED));
		}
		
		private function SortFunction(a:Object, b:Object, fields:Array):int
		{
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
			if (listViewerItem.Identical != null)
				return listViewerItem.Identical;
			else if (listViewerItem.L1Similar != null)
				return listViewerItem.L1Similar;
			else if (listViewerItem.L1Unique != null)
				return listViewerItem.L1Unique;
			else
				return listViewerItem.L2Unique;
		}
		
		private function OnReadXmlComplete(list:List):void
		{
			listIdx[list.Id] = lists.length;
			lists.addItem(list);
			if (lists.length >= 2) {
				FinishInit();
			}
		}
		
		private function FinishInit():void
		{
			SetVisibleLists(lists[0].Id, lists[1].Id);
			//SortListViewerData();
			dispatchEvent(new Event(DATA_LOADED));
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
			listViewerData.removeAll();
			var map:Object = new Object();
			var arr:Array;
			for each (var item:ListItem in list1) {
				map[item.Name] = new Array(2);
				map[item.Name][0] = item;
			}
			for each (var item:ListItem in list2) {
				if (!(item.Name in map))
					map[item.Name] = new Array(2);
				map[item.Name][1] = item;
			}
			for each (var pair:Array in map) {
				var item1:ListItem = pair[0] as ListItem;
				var item2:ListItem = pair[1] as ListItem;
				var sim:Number = GetSimilarity(item1, item2);
				var listViewerItem:ListViewerItem;
				if (sim == 1) {
					// identical
					listViewerItem = new ListViewerItem();
					listViewerItem.Identical = item1;
					listViewerData.addItem(listViewerItem);
				}
				else if (sim >= 0) {
					// similar
					listViewerItem = new ListViewerItem();
					listViewerItem.L1Similar = item1;
					listViewerItem.L2Similar = item2;
					listViewerData.addItem(listViewerItem);
				}
				else {
					// unique
					listViewerItem = new ListViewerItem();
					if (item1 != null)
						listViewerItem.L1Unique = item1;
					else
						listViewerItem.L2Unique = item2;
					listViewerData.addItem(listViewerItem);						
				}
			}
		}
		
		private function GetSimilarity(item1:ListItem, item2:ListItem):Number
		{
			if (item1 == null || item2 == null)
				return -1;
			if (item1.Equals(item2))
				return 1;
			return 0;
		}
		
		private function LoadCannedData():void
		{
			// CANNED DATA
			// list 1
			var list1:List = new List("list1", "Patient");
			var item:ListItem = new ListItem("list1id1", "Calcitrol");
			item.Attributes["Dosage"] = new ItemAttribute("Dosage", ["0.25mg"]);
			item.Attributes["Form"] = new ItemAttribute("Form", ["PO"]);
			item.Attributes["Frequency"] = new ItemAttribute("Frequency", ["Daily"]);
			list1.addItem(item);
			item = new ListItem("list1id2", "Darbepoetin");
			item.Attributes["Dosage"] = new ItemAttribute("Dosage", ["60mg"]);
			item.Attributes["Form"] = new ItemAttribute("Form", ["SC"]);
			item.Attributes["Frequency"] = new ItemAttribute("Frequency", ["qFriday"]);
			list1.addItem(item);
			item = new ListItem("list1id3", "Docusate Sodium");
			item.Attributes["Dosage"] = new ItemAttribute("Dosage", ["100mg"]);
			item.Attributes["Form"] = new ItemAttribute("Form", ["PO"]);
			item.Attributes["Frequency"] = new ItemAttribute("Frequency", ["BID"]);
			list1.addItem(item);
			item = new ListItem("list1id4", "Ramipril");
			item.Attributes["Dosage"] = new ItemAttribute("Dosage", ["5mg"]);
			item.Attributes["Form"] = new ItemAttribute("Form", ["PO"]);
			item.Attributes["Frequency"] = new ItemAttribute("Frequency", ["Daily"]);
			list1.addItem(item);
			item = new ListItem("list1id5", "Acetaminophen");
			item.Attributes["Dosage"] = new ItemAttribute("Dosage", ["325mg"]);
			item.Attributes["Form"] = new ItemAttribute("Form", ["PO"]);
			item.Attributes["Frequency"] = new ItemAttribute("Frequency", ["q4h"]);
			list1.addItem(item);
			item = new ListItem("list1id6", "Calcium Carbonate");
			item.Attributes["Dosage"] = new ItemAttribute("Dosage", ["500mg"]);
			item.Attributes["Form"] = new ItemAttribute("Form", ["PO"]);
			item.Attributes["Frequency"] = new ItemAttribute("Frequency", ["TID CC"]);
			list1.addItem(item);
			item = new ListItem("list1id7", "Atorvistatin");
			item.Attributes["Dosage"] = new ItemAttribute("Dosage", ["40mg"]);
			item.Attributes["Form"] = new ItemAttribute("Form", ["PO"]);
			item.Attributes["Frequency"] = new ItemAttribute("Frequency", ["Daily"]);
			list1.addItem(item);
			item = new ListItem("list1id8", "Metoprolol");
			item.Attributes["Dosage"] = new ItemAttribute("Dosage", ["50mg"]);
			item.Attributes["Form"] = new ItemAttribute("Form", ["PO"]);
			item.Attributes["Frequency"] = new ItemAttribute("Frequency", ["Daily"]);
			list1.addItem(item);
			item = new ListItem("list1id9", "Aspirin");
			item.Attributes["Dosage"] = new ItemAttribute("Dosage", ["81mg"]);
			item.Attributes["Form"] = new ItemAttribute("Form", ["PO"]);
			item.Attributes["Frequency"] = new ItemAttribute("Frequency", ["Daily"]);
			list1.addItem(item);
			item = new ListItem("list1id10", "Meloxicam");
			item.Attributes["Dosage"] = new ItemAttribute("Dosage", ["7.5mg"]);
			item.Attributes["Form"] = new ItemAttribute("Form", ["PO"]);
			item.Attributes["Frequency"] = new ItemAttribute("Frequency", ["Daily"]);
			list1.addItem(item);
			listIdx[list1.Id] = lists.length;
			lists.addItem(list1);
			// list 2
			var list2:List = new List("list2", "Hospital");
			item = new ListItem("list2id1", "Calcitrol");
			item.Attributes["Dosage"] = new ItemAttribute("Dosage", ["0.25mg"]);
			item.Attributes["Form"] = new ItemAttribute("Form", ["PO"]);
			item.Attributes["Frequency"] = new ItemAttribute("Frequency", ["Daily"]);
			list2.addItem(item);
			item = new ListItem("list2id2", "Darbepoetin");
			item.Attributes["Dosage"] = new ItemAttribute("Dosage", ["60mg"]);
			item.Attributes["Form"] = new ItemAttribute("Form", ["SC"]);
			item.Attributes["Frequency"] = new ItemAttribute("Frequency", ["qFriday"]);
			list2.addItem(item);
			item = new ListItem("list2id3", "Docusate Sodium");
			item.Attributes["Dosage"] = new ItemAttribute("Dosage", ["100mg"]);
			item.Attributes["Form"] = new ItemAttribute("Form", ["PO"]);
			item.Attributes["Frequency"] = new ItemAttribute("Frequency", ["BID"]);
			list2.addItem(item);
			item = new ListItem("list2id4", "Ramipril");
			item.Attributes["Dosage"] = new ItemAttribute("Dosage", ["5mg"]);
			item.Attributes["Form"] = new ItemAttribute("Form", ["PO"]);
			item.Attributes["Frequency"] = new ItemAttribute("Frequency", ["Daily"]);
			list2.addItem(item);
			item = new ListItem("list2id5", "Acetaminophen");
			item.Attributes["Dosage"] = new ItemAttribute("Dosage", ["325mg"]);
			item.Attributes["Form"] = new ItemAttribute("Form", ["PO"]);
			item.Attributes["Frequency"] = new ItemAttribute("Frequency", ["q4h"]);
			list2.addItem(item);
			item = new ListItem("list2id6", "Calcium Carbonate");
			item.Attributes["Dosage"] = new ItemAttribute("Dosage", ["1000mg"]);
			item.Attributes["Form"] = new ItemAttribute("Form", ["PO"]);
			item.Attributes["Frequency"] = new ItemAttribute("Frequency", ["TID CC"]);
			list2.addItem(item);
			item = new ListItem("list2id7", "Atorvistatin");
			item.Attributes["Dosage"] = new ItemAttribute("Dosage", ["60mg"]);
			item.Attributes["Form"] = new ItemAttribute("Form", ["PO"]);
			item.Attributes["Frequency"] = new ItemAttribute("Frequency", ["Daily"]);
			list2.addItem(item);
			item = new ListItem("list2id8", "Metoprolol");
			item.Attributes["Dosage"] = new ItemAttribute("Dosage", ["100mg"]);
			item.Attributes["Form"] = new ItemAttribute("Form", ["PO"]);
			item.Attributes["Frequency"] = new ItemAttribute("Frequency", ["BID"]);			
			list2.addItem(item);
			item = new ListItem("list2id9", "Ferrous Gloconate");
			item.Attributes["Dosage"] = new ItemAttribute("Dosage", ["300mg"]);
			item.Attributes["Form"] = new ItemAttribute("Form", ["PO"]);
			item.Attributes["Frequency"] = new ItemAttribute("Frequency", ["TID"]);
			list2.addItem(item);
			item = new ListItem("list2id10", "Omeprazole");
			item.Attributes["Dosage"] = new ItemAttribute("Dosage", ["40mg"]);
			item.Attributes["Form"] = new ItemAttribute("Form", ["PO"]);
			item.Attributes["Frequency"] = new ItemAttribute("Frequency", ["Daily"]);
			list2.addItem(item);
			item = new ListItem("list2id11", "Ciproflaxocin");
			item.Attributes["Dosage"] = new ItemAttribute("Dosage", ["500mg"]);
			item.Attributes["Form"] = new ItemAttribute("Form", ["PO"]);
			item.Attributes["Frequency"] = new ItemAttribute("Frequency", ["Daily"]);
			list2.addItem(item);
			listIdx[list2.Id] = lists.length;
			lists.addItem(list2);
			FinishInit();
		}
	}		
}