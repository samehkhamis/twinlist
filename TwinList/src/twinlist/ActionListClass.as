package twinlist
{
	import flash.events.Event;
	
	import mx.collections.ArrayCollection;
	import mx.collections.Sort;
	import mx.controls.AdvancedDataGrid;
	import mx.controls.advancedDataGridClasses.AdvancedDataGridColumn;
	import mx.core.ClassFactory;
	import mx.events.FlexEvent;
	
	import spark.components.Group;
	
	import twinlist.list.AttributeDescriptor;
	
	public class ActionListClass extends Group
	{
		public static const BUTTON_COL:String = "__BUTTON__";
		public static const ACCEPT_LIST:String = "__ACCEPT_LIST__";
		public static const REJECT_LIST:String = "__REJECT_LIST__";
		[Bindable]
		protected var model:Model = Model.Instance;
		[Bindable]
		protected var listName:String;
		[Bindable]
		protected var dataSource:ArrayCollection;
		public var dataGrid:AdvancedDataGrid;
		private static var defaultSort:Sort
		
		public function ActionListClass(listName:String = "")
		{
			super();
			ListName = listName;
			defaultSort = new Sort();
			this.addEventListener(FlexEvent.CREATION_COMPLETE, OnInitComplete);
		}
		
		public function get DataSource():ArrayCollection
		{
			return dataSource;
		}
		public function set DataSource(source:ArrayCollection):void
		{
			dataSource = source;
		}
		
		public function get ListName():String
		{
			return listName;
		}
		public function set ListName(value:String):void
		{
			listName = value;
		}
		
		private function OnInitComplete(event:Event):void
		{
			this.removeEventListener(FlexEvent.CREATION_COMPLETE, OnInitComplete);
			var columns:Array = dataGrid.columns;
			var col:AdvancedDataGridColumn;
			var factory:ClassFactory;
			// create a button column
			col = new AdvancedDataGridColumn(BUTTON_COL);
			col.headerText = "";
			factory = new ClassFactory(ActionListItemRenderer);
			factory.properties = {ColumnName:BUTTON_COL, ListName:ListName};
			col.itemRenderer = factory;
			col.sortable = false;
			col.width = 80;
			columns.push(col);
			// create column for each data field
			for each (var attr:AttributeDescriptor in model.ItemAttributes) {
				col = new AdvancedDataGridColumn(attr.Name);
				col.headerText = attr.toString();
				factory = new ClassFactory(ActionListItemRenderer);
				factory.properties = {ColumnName:attr.Name};
				col.itemRenderer = factory;
				if (attr.Name != "Name") {
					col.sortable = false;
//					col.sortCompareFunction = function(a:Object, b:Object, fields:Array):int {
//						var val1:Object = (a as ListItem).Attributes[attr.Name][0];
//						var val2:Object = (b as ListItem).Attributes[attr.Name][0];
//						return defaultSort.compareFunction.call(null, val1, val2, null);
//					};
				}
				columns.push(col);
			}			
			dataGrid.columns = columns;
		}
	}
}