package twinlist
{
	import mx.collections.ArrayCollection;
	import mx.utils.ObjectUtil;

	[Bindable]
	public final class Model
	{
		private static var instance:Model = new Model();		
		private var lists:Object = null;
		private var listViewerData:ArrayCollection = null;
		private var listItemAttributes:Object = null;
		private var actionListItems:ArrayCollection = null;
		private var actionListData:ArrayCollection = null;
		private var selectedItem:ListItem = null;
		
		public function Model()
		{
			if (instance != null)
				throw new Error("Model can only be accessed via Model.Instance()");
			
			// init
			lists = loadListData();
			listItemAttributes = DetectAttributes(lists);
			listViewerData = ReconcileLists(lists["list1"], lists["list2"]);
			actionListItems = new ArrayCollection();
			actionListData = new ArrayCollection();
		}
		
		public static function get Instance():Model
		{
			return instance;
		}
		
		public function get Lists():Object
		{
			return lists;
		}
		
		public function get ListViewerData():ArrayCollection
		{
			return listViewerData;
		}
		
		public function get ActionListItems():ArrayCollection
		{
			return actionListItems;
		}
		
		public function get ActionListData():ArrayCollection
		{
			return actionListData;
		}
		
		public function AddActionListItem(item:ListItem):void
		{
			if (actionListItems.contains(item))
				return;
			var itemArray:Array = new Array();
			itemArray["Name"] = item.Name;
			for each (var attr:ListItemAttribute in item.Attributes) {
				itemArray[attr.Name] = attr.Value;
			}
			actionListItems.addItem(item);
			actionListData.addItem(itemArray);
		}
		public function DelActionListItem(item:ListItem):void
		{
			var itemArray:Array = new Array();
			itemArray["Name"] = item.Name;
			for each (var attr:ListItemAttribute in item.Attributes) {
				itemArray[attr.Name] = attr.Value;
			}
			var idx:int = actionListItems.getItemIndex(item);
			actionListItems.removeItemAt(idx);
			actionListData.removeItemAt(idx);
		}
		
		public function get SelectedItem():ListItem
		{
			return selectedItem;
		}
		public function set SelectedItem(listItem:ListItem):void
		{
			selectedItem = listItem;
		}
		
		public function get ListItemAttributes():Object
		{
			return listItemAttributes;
		}
		
		private function loadListData():Array
		{
			var lists:Array = new Array();
			// CANNED DATA
			// list 1
			var list1:ArrayCollection = new ArrayCollection();
			var item:ListItem = new ListItem("list1id1", "Calcitrol");
			item.Attributes.addItem(new ListItemAttribute("Dosage", "0.25mcg"));
			item.Attributes.addItem(new ListItemAttribute("Form", "PO"));
			item.Attributes.addItem(new ListItemAttribute("Frequency", "Daily"));
			list1.addItem(item)
			item = new ListItem("list1id2", "Darbepoetin");
			item.Attributes.addItem(new ListItemAttribute("Dosage", "60mcg"));
			item.Attributes.addItem(new ListItemAttribute("Form", "SC"));
			item.Attributes.addItem(new ListItemAttribute("Frequency", "qFriday"));
			list1.addItem(item)
			item = new ListItem("list1id3", "Docusate Sodium");
			item.Attributes.addItem(new ListItemAttribute("Dosage", "100mg"));
			item.Attributes.addItem(new ListItemAttribute("Form", "PO"));
			item.Attributes.addItem(new ListItemAttribute("Frequency", "BID"));
			list1.addItem(item)
			item = new ListItem("list1id4", "Ramipril");
			item.Attributes.addItem(new ListItemAttribute("Dosage", "5mg"));
			item.Attributes.addItem(new ListItemAttribute("Form", "PO"));
			item.Attributes.addItem(new ListItemAttribute("Frequency", "Daily"));
			list1.addItem(item)
			item = new ListItem("list1id5", "Acetaminophen");
			item.Attributes.addItem(new ListItemAttribute("Dosage", "325mg"));
			item.Attributes.addItem(new ListItemAttribute("Form", "PO"));
			item.Attributes.addItem(new ListItemAttribute("Frequency", "q4h"));
			list1.addItem(item)
			item = new ListItem("list1id6", "Calcium Carbonate");
			item.Attributes.addItem(new ListItemAttribute("Dosage", "500mg"));
			item.Attributes.addItem(new ListItemAttribute("Form", "PO"));
			item.Attributes.addItem(new ListItemAttribute("Frequency", "TID CC"));
			list1.addItem(item)
			item = new ListItem("list1id7", "Atorvistatin");
			item.Attributes.addItem(new ListItemAttribute("Dosage", "40mg"));
			item.Attributes.addItem(new ListItemAttribute("Form", "PO"));
			item.Attributes.addItem(new ListItemAttribute("Frequency", "Daily"));
			list1.addItem(item)
			item = new ListItem("list1id8", "Metoprolol");
			item.Attributes.addItem(new ListItemAttribute("Dosage", "50mg"));
			item.Attributes.addItem(new ListItemAttribute("Form", "PO"));
			item.Attributes.addItem(new ListItemAttribute("Frequency", "Daily"));
			list1.addItem(item)
			item = new ListItem("list1id9", "Aspirin");
			item.Attributes.addItem(new ListItemAttribute("Dosage", "81mg"));
			item.Attributes.addItem(new ListItemAttribute("Form", "PO"));
			item.Attributes.addItem(new ListItemAttribute("Frequency", "Daily"));
			list1.addItem(item)
			item = new ListItem("list1id10", "Meloxicam");
			item.Attributes.addItem(new ListItemAttribute("Dosage", "7.5mg"));
			item.Attributes.addItem(new ListItemAttribute("Form", "PO"));
			item.Attributes.addItem(new ListItemAttribute("Frequency", "Daily"));
			list1.addItem(item)
			lists["list1"] = list1;
			// list 2
			var list2:ArrayCollection = new ArrayCollection();
			item = new ListItem("list2id1", "Calcitrol");
			item.Attributes.addItem(new ListItemAttribute("Dosage", "0.25mcg"));
			item.Attributes.addItem(new ListItemAttribute("Form", "PO"));
			item.Attributes.addItem(new ListItemAttribute("Frequency", "Daily"));
			list2.addItem(item)
			item = new ListItem("list2id2", "Darbepoetin");
			item.Attributes.addItem(new ListItemAttribute("Dosage", "60mcg"));
			item.Attributes.addItem(new ListItemAttribute("Form", "SC"));
			item.Attributes.addItem(new ListItemAttribute("Frequency", "qFriday"));
			list2.addItem(item)
			item = new ListItem("list2id3", "Docusate Sodium");
			item.Attributes.addItem(new ListItemAttribute("Dosage", "100mg"));
			item.Attributes.addItem(new ListItemAttribute("Form", "PO"));
			item.Attributes.addItem(new ListItemAttribute("Frequency", "BID"));
			list2.addItem(item)
			item = new ListItem("list2id4", "Ramipril");
			item.Attributes.addItem(new ListItemAttribute("Dosage", "5mg"));
			item.Attributes.addItem(new ListItemAttribute("Form", "PO"));
			item.Attributes.addItem(new ListItemAttribute("Frequency", "Daily"));
			list2.addItem(item)
			item = new ListItem("list2id5", "Acetaminophen");
			item.Attributes.addItem(new ListItemAttribute("Dosage", "325mg"));
			item.Attributes.addItem(new ListItemAttribute("Form", "PO"));
			item.Attributes.addItem(new ListItemAttribute("Frequency", "q4h"));
			list2.addItem(item)
			item = new ListItem("list2id6", "Calcium Carbonate");
			item.Attributes.addItem(new ListItemAttribute("Dosage", "1000mg"));
			item.Attributes.addItem(new ListItemAttribute("Form", "PO"));
			item.Attributes.addItem(new ListItemAttribute("Frequency", "TID CC"));
			list2.addItem(item)
			item = new ListItem("list2id7", "Atorvistatin");
			item.Attributes.addItem(new ListItemAttribute("Dosage", "60mg"));
			item.Attributes.addItem(new ListItemAttribute("Form", "PO"));
			item.Attributes.addItem(new ListItemAttribute("Frequency", "Daily"));
			list2.addItem(item)
			item = new ListItem("list2id8", "Metoprolol");
			item.Attributes.addItem(new ListItemAttribute("Dosage", "100mg"));
			item.Attributes.addItem(new ListItemAttribute("Form", "PO"));
			item.Attributes.addItem(new ListItemAttribute("Frequency", "BID"));			
			list2.addItem(item)
			item = new ListItem("list2id9", "Ferrous Gloconate");
			item.Attributes.addItem(new ListItemAttribute("Dosage", "300mg"));
			item.Attributes.addItem(new ListItemAttribute("Form", "PO"));
			item.Attributes.addItem(new ListItemAttribute("Frequency", "TID"));
			list2.addItem(item)
			item = new ListItem("list2id10", "Omeprazole");
			item.Attributes.addItem(new ListItemAttribute("Dosage", "40mg"));
			item.Attributes.addItem(new ListItemAttribute("Form", "PO"));
			item.Attributes.addItem(new ListItemAttribute("Frequency", "Daily"));
			list2.addItem(item)
			item = new ListItem("list2id11", "Ciproflaxocin");
			item.Attributes.addItem(new ListItemAttribute("Dosage", "500mg"));
			item.Attributes.addItem(new ListItemAttribute("Form", "PO"));
			item.Attributes.addItem(new ListItemAttribute("Frequency", "Daily"));
			list2.addItem(item)
			lists["list2"] = list2;
			return lists;
		}
		
		private function DetectAttributes(listData:Object):Object
		{
			var attrKeys:Object = new Object();
			for each (var list:ArrayCollection in listData) {
				for each (var item:ListItem in list) {
					for each (var attr:ListItemAttribute in item.Attributes) {
						if (!(attr.Name in attrKeys)) {
							attrKeys[attr.Name] = attr.Name;
						}
					}
				}
			}
			return attrKeys;
		}
		
		private function ReconcileLists(list1:ArrayCollection, list2:ArrayCollection):ArrayCollection
		{
			var listViewerData:ArrayCollection = new ArrayCollection();
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
			return listViewerData;
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