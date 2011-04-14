package twinlist
{	
	import com.carlcalderon.arthropod.Debug;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	
	import mx.collections.ArrayCollection;
	import mx.collections.Sort;
	import mx.core.IFactory;
	import mx.events.CollectionEvent;
	
	import twinlist.filter.IFilter;

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
		private var dataAttributes:ArrayCollection;
		private var categoricalAttributes:ArrayCollection;
		private var numericalAttributes:ArrayCollection;
		// publicly set variables
		private var selectedItem:ListItem;
		private var sizeByAttribute:String;
		private var colorByAttribute:String;
		private var sortByAttribute:String;
		private var groupByAttribute:String;
		private var filterByString:String;
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
			dataAttributes = new ArrayCollection();
			categoricalAttributes = new ArrayCollection();
			numericalAttributes = new ArrayCollection();
			defaultSort = new Sort();
			selectedItem = null;
			groupByAttribute = null;
			sortByAttribute = null;
			filterByString = null;
			filterList = new ArrayCollection();
			// load data
			//LoadCannedData();
			ReadXml("../data/list1.xml");
			ReadXml("../data/list2.xml");
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
		
		public function get DataAttributes():ArrayCollection
		{
			return dataAttributes;
		}
		
		public function get CategoricalAttributes():ArrayCollection
		{
			return categoricalAttributes;
		}
		
		public function get NumericalAttributes():ArrayCollection
		{
			return numericalAttributes;
		}
		
		public function get SizeBy():String
		{
			return sizeByAttribute;
		}
		public function set SizeBy(attributeName:String):void
		{
			sizeByAttribute = attributeName;
		}
		
		public function get ColorBy():String
		{
			return colorByAttribute;
		}
		public function set ColorBy(attributeName:String):void
		{
			colorByAttribute = attributeName;
		}
		
		public function get GroupBy():String
		{
			return groupByAttribute;
		}
		public function set GroupBy(attributeName:String):void
		{
			groupByAttribute = attributeName;
			SortListViewerData();
		}
		
		public function get SortBy():String
		{
			return sortByAttribute;
		}
		public function set SortBy(attributeName:String):void
		{
			sortByAttribute = attributeName;
			SortListViewerData();
		}
		
		public function get FilterByString():String
		{
			return filterByString;
		}
		public function set FilterByString(filterString:String):void
		{
			filterByString=filterString;
			Debug.log(filterString);
			// Here a function will be call to filter the rows of the list viewer and refresh it.
			//FilterListViewerData();
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
		}
		
		public function DelFilter(filter:IFilter):void
		{
			var idx:int = FilterListContains(filter);
			if (idx >= 0) {
				filterList.removeItemAt(idx);
			}
		}
		
		public function get VisibleListIds():Array
		{
			return visibleListIds;
		}
		
		public function SetVisibleLists(id1:String, id2:String):void
		{
			ReconcileLists(lists[listIdx[id1]], lists[listIdx[id2]]);
			visibleListIds[0] = id1;
			visibleListIds[1] = id2;
		}
		
		private function SortListViewerData():void
		{
			var sort:Sort = new Sort();
			sort.compareFunction = SortFunction;
			sort.sort(listViewerData.source);
			listViewerData.refresh();
		}
		
		private function SortFunction(a:Object, b:Object, fields:Array):int
		{
			var item1:ListItem = GetListItemToSortOn(a as ListViewerItem);
			var item2:ListItem = GetListItemToSortOn(b as ListViewerItem);
			var val1:Object;
			var val2:Object;
			var sortVal:int = 0;
			if (groupByAttribute != null) {
				if (groupByAttribute == "Name") {
					val1 = item1.Name;
					val2 = item2.Name;		
				}
				else {
					val1 = item1.Attributes[groupByAttribute].Values[0];
					val2 = item2.Attributes[groupByAttribute].Values[0];		
				}
				sortVal = defaultSort.compareFunction.call(null, val1, val2, fields);
			}
			if (sortVal != 0)
				return sortVal;
			if (sortByAttribute != null) {
				if (sortByAttribute == "Name") {
					val1 = item1.Name;
					val2 = item2.Name;		
				}
				else {
					val1 = item1.Attributes[sortByAttribute].Values[0];
					val2 = item2.Attributes[sortByAttribute].Values[0];		
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
		
		private function ReadXml(filePath:String):void
		{
			var urlReq:URLRequest = new URLRequest(filePath);
			var loader:URLLoader = new URLLoader(urlReq);
			loader.dataFormat = URLLoaderDataFormat.TEXT;
			loader.addEventListener(Event.COMPLETE, function(event:Event):void {
				OnReadXmlComplete(loader);
			});
		}
		
		private function OnReadXmlComplete(loader:URLLoader):void
		{
			var xml:XML = XML(loader.data);
			var listId:String = xml.attribute("id");
			var listName:String = xml.attribute("name");
			var list:List = new List(listId, listName);
			for each (var itemXml:XML in xml.children()) {
				var itemId:String = itemXml.attribute("id");
				var itemName:String = itemXml.attribute("name");
				var item:ListItem = new ListItem(itemId, itemName);
				for each (var attrXml:XML in itemXml.children()) {
					var attrName:String = attrXml.attribute("name");
					var attr:ListItemAttribute = new ListItemAttribute(attrName);
					switch (attrXml.attribute("type").toString()) {
						case "Categorical": attr.Type = ListItemAttribute.TYPE_CATEGORICAL; break;
						case "Numerical": attr.Type = ListItemAttribute.TYPE_NUMERICAL; break;
						default : attr.Type = ListItemAttribute.TYPE_GENERAL; break;
					}
					attr.Values = new Array();
					for each (var valXml:XML in attrXml.children()) {
						var value:Object;
						if (attr.Type == ListItemAttribute.TYPE_NUMERICAL) {
							value = parseFloat(valXml.attribute("value").toString());
						}
						else {
							value = valXml.attribute("value").toString();
						}
						attr.Values.push(value);
					}
					item.Attributes[attr.Name] = attr;
				}
				list.addItem(item);
			}
			listIdx[list.Id] = lists.length;
			lists.addItem(list);
			if (lists.length >= 2) {
				FinishInit();
			}
		}
		
		private function FinishInit():void
		{
			SetVisibleLists(lists[0].Id, lists[1].Id);
			DetectAttributes();
			//SortListViewerData();
			this.dispatchEvent(new Event(DATA_LOADED));
		}

		private function LoadCannedData():void
		{
			// CANNED DATA
			// list 1
			var list1:List = new List("list1", "Patient");
			var item:ListItem = new ListItem("list1id1", "Calcitrol");
			item.Attributes["Dosage"] = new ListItemAttribute("Dosage", ["0.25mg"]);
			item.Attributes["Form"] = new ListItemAttribute("Form", ["PO"]);
			item.Attributes["Frequency"] = new ListItemAttribute("Frequency", ["Daily"]);
			list1.addItem(item);
			item = new ListItem("list1id2", "Darbepoetin");
			item.Attributes["Dosage"] = new ListItemAttribute("Dosage", ["60mg"]);
			item.Attributes["Form"] = new ListItemAttribute("Form", ["SC"]);
			item.Attributes["Frequency"] = new ListItemAttribute("Frequency", ["qFriday"]);
			list1.addItem(item);
			item = new ListItem("list1id3", "Docusate Sodium");
			item.Attributes["Dosage"] = new ListItemAttribute("Dosage", ["100mg"]);
			item.Attributes["Form"] = new ListItemAttribute("Form", ["PO"]);
			item.Attributes["Frequency"] = new ListItemAttribute("Frequency", ["BID"]);
			list1.addItem(item);
			item = new ListItem("list1id4", "Ramipril");
			item.Attributes["Dosage"] = new ListItemAttribute("Dosage", ["5mg"]);
			item.Attributes["Form"] = new ListItemAttribute("Form", ["PO"]);
			item.Attributes["Frequency"] = new ListItemAttribute("Frequency", ["Daily"]);
			list1.addItem(item);
			item = new ListItem("list1id5", "Acetaminophen");
			item.Attributes["Dosage"] = new ListItemAttribute("Dosage", ["325mg"]);
			item.Attributes["Form"] = new ListItemAttribute("Form", ["PO"]);
			item.Attributes["Frequency"] = new ListItemAttribute("Frequency", ["q4h"]);
			list1.addItem(item);
			item = new ListItem("list1id6", "Calcium Carbonate");
			item.Attributes["Dosage"] = new ListItemAttribute("Dosage", ["500mg"]);
			item.Attributes["Form"] = new ListItemAttribute("Form", ["PO"]);
			item.Attributes["Frequency"] = new ListItemAttribute("Frequency", ["TID CC"]);
			list1.addItem(item);
			item = new ListItem("list1id7", "Atorvistatin");
			item.Attributes["Dosage"] = new ListItemAttribute("Dosage", ["40mg"]);
			item.Attributes["Form"] = new ListItemAttribute("Form", ["PO"]);
			item.Attributes["Frequency"] = new ListItemAttribute("Frequency", ["Daily"]);
			list1.addItem(item);
			item = new ListItem("list1id8", "Metoprolol");
			item.Attributes["Dosage"] = new ListItemAttribute("Dosage", ["50mg"]);
			item.Attributes["Form"] = new ListItemAttribute("Form", ["PO"]);
			item.Attributes["Frequency"] = new ListItemAttribute("Frequency", ["Daily"]);
			list1.addItem(item);
			item = new ListItem("list1id9", "Aspirin");
			item.Attributes["Dosage"] = new ListItemAttribute("Dosage", ["81mg"]);
			item.Attributes["Form"] = new ListItemAttribute("Form", ["PO"]);
			item.Attributes["Frequency"] = new ListItemAttribute("Frequency", ["Daily"]);
			list1.addItem(item);
			item = new ListItem("list1id10", "Meloxicam");
			item.Attributes["Dosage"] = new ListItemAttribute("Dosage", ["7.5mg"]);
			item.Attributes["Form"] = new ListItemAttribute("Form", ["PO"]);
			item.Attributes["Frequency"] = new ListItemAttribute("Frequency", ["Daily"]);
			list1.addItem(item);
			listIdx[list1.Id] = lists.length;
			lists.addItem(list1);
			// list 2
			var list2:List = new List("list2", "Hospital");
			item = new ListItem("list2id1", "Calcitrol");
			item.Attributes["Dosage"] = new ListItemAttribute("Dosage", ["0.25mg"]);
			item.Attributes["Form"] = new ListItemAttribute("Form", ["PO"]);
			item.Attributes["Frequency"] = new ListItemAttribute("Frequency", ["Daily"]);
			list2.addItem(item);
			item = new ListItem("list2id2", "Darbepoetin");
			item.Attributes["Dosage"] = new ListItemAttribute("Dosage", ["60mg"]);
			item.Attributes["Form"] = new ListItemAttribute("Form", ["SC"]);
			item.Attributes["Frequency"] = new ListItemAttribute("Frequency", ["qFriday"]);
			list2.addItem(item);
			item = new ListItem("list2id3", "Docusate Sodium");
			item.Attributes["Dosage"] = new ListItemAttribute("Dosage", ["100mg"]);
			item.Attributes["Form"] = new ListItemAttribute("Form", ["PO"]);
			item.Attributes["Frequency"] = new ListItemAttribute("Frequency", ["BID"]);
			list2.addItem(item);
			item = new ListItem("list2id4", "Ramipril");
			item.Attributes["Dosage"] = new ListItemAttribute("Dosage", ["5mg"]);
			item.Attributes["Form"] = new ListItemAttribute("Form", ["PO"]);
			item.Attributes["Frequency"] = new ListItemAttribute("Frequency", ["Daily"]);
			list2.addItem(item);
			item = new ListItem("list2id5", "Acetaminophen");
			item.Attributes["Dosage"] = new ListItemAttribute("Dosage", ["325mg"]);
			item.Attributes["Form"] = new ListItemAttribute("Form", ["PO"]);
			item.Attributes["Frequency"] = new ListItemAttribute("Frequency", ["q4h"]);
			list2.addItem(item);
			item = new ListItem("list2id6", "Calcium Carbonate");
			item.Attributes["Dosage"] = new ListItemAttribute("Dosage", ["1000mg"]);
			item.Attributes["Form"] = new ListItemAttribute("Form", ["PO"]);
			item.Attributes["Frequency"] = new ListItemAttribute("Frequency", ["TID CC"]);
			list2.addItem(item);
			item = new ListItem("list2id7", "Atorvistatin");
			item.Attributes["Dosage"] = new ListItemAttribute("Dosage", ["60mg"]);
			item.Attributes["Form"] = new ListItemAttribute("Form", ["PO"]);
			item.Attributes["Frequency"] = new ListItemAttribute("Frequency", ["Daily"]);
			list2.addItem(item);
			item = new ListItem("list2id8", "Metoprolol");
			item.Attributes["Dosage"] = new ListItemAttribute("Dosage", ["100mg"]);
			item.Attributes["Form"] = new ListItemAttribute("Form", ["PO"]);
			item.Attributes["Frequency"] = new ListItemAttribute("Frequency", ["BID"]);			
			list2.addItem(item);
			item = new ListItem("list2id9", "Ferrous Gloconate");
			item.Attributes["Dosage"] = new ListItemAttribute("Dosage", ["300mg"]);
			item.Attributes["Form"] = new ListItemAttribute("Form", ["PO"]);
			item.Attributes["Frequency"] = new ListItemAttribute("Frequency", ["TID"]);
			list2.addItem(item);
			item = new ListItem("list2id10", "Omeprazole");
			item.Attributes["Dosage"] = new ListItemAttribute("Dosage", ["40mg"]);
			item.Attributes["Form"] = new ListItemAttribute("Form", ["PO"]);
			item.Attributes["Frequency"] = new ListItemAttribute("Frequency", ["Daily"]);
			list2.addItem(item);
			item = new ListItem("list2id11", "Ciproflaxocin");
			item.Attributes["Dosage"] = new ListItemAttribute("Dosage", ["500mg"]);
			item.Attributes["Form"] = new ListItemAttribute("Form", ["PO"]);
			item.Attributes["Frequency"] = new ListItemAttribute("Frequency", ["Daily"]);
			list2.addItem(item);
			listIdx[list2.Id] = lists.length;
			lists.addItem(list2);
			FinishInit();
		}
		
		private function DetectAttributes():void
		{
			// empty current collections
			dataAttributes.removeAll();
			categoricalAttributes.removeAll();
			numericalAttributes.removeAll();
			// add name field
			dataAttributes.addItem("Name");
			// iterate over all lists, items and detect attributes
			var attrKeys:Object = new Object();
			for each (var list:ArrayCollection in lists) {
				for each (var item:ListItem in list) {
					for each (var attr:ListItemAttribute in item.Attributes) {
						if (!(attr.Name in attrKeys)) {
							attrKeys[attr.Name] = attr.Name;
							dataAttributes.addItem(attr.Name);
							switch (attr.Type) {
								case ListItemAttribute.TYPE_CATEGORICAL: categoricalAttributes.addItem(attr.Name); break;
								case ListItemAttribute.TYPE_NUMERICAL: numericalAttributes.addItem(attr.Name); break;
							}
						}
					}
				}
			}
		}
		
		private function ReconcileLists(list1:List, list2:List):void
		{
			listViewerData.removeAll();
			var maxLen:int = Math.max(list1.length, list2.length);
			var iter1:int = 0;
			var iter2:int = 0;
			while ((iter1 < list1.length) || (iter2 < list2.length)) {
				var item1:ListItem = null;
				if (iter1 < list1.length)
					item1 = list1.getItemAt(iter1) as ListItem;
				++iter1;
				var item2:ListItem = null;
				if (iter2 < list2.length)
					item2 = list2.getItemAt(iter2) as ListItem;
				++iter2;
				if ((item1 != null) && (item2 != null)) {
					var listViewerItem:ListViewerItem;
					if (AreIdentical(item1, item2)) {
						listViewerItem = new ListViewerItem();
						listViewerItem.Identical = item1;
						listViewerData.addItem(listViewerItem);
					}
					else if (AreSimilar(item1, item2)) {
						listViewerItem = new ListViewerItem();
						listViewerItem.L1Similar = item1;
						listViewerItem.L2Similar = item2;
						listViewerData.addItem(listViewerItem);
					}
					else {
						listViewerItem = new ListViewerItem();
						listViewerItem.L1Unique = item1;
						listViewerData.addItem(listViewerItem);						
						listViewerItem = new ListViewerItem();
						listViewerItem.L2Unique = item2;
						listViewerData.addItem(listViewerItem);						
					}
				}
			}
		}
		
		private function AreIdentical(item1:ListItem, item2:ListItem):Boolean
		{
			return item1.Equals(item2);
		}
		
		private function AreSimilar(item1:ListItem, item2:ListItem):Boolean
		{
			return item1.Name == item2.Name;
		}
	}
}