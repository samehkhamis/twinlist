package twinlist
{
	import flash.events.Event;
	
	import mx.controls.advancedDataGridClasses.MXAdvancedDataGridItemRenderer;
	import mx.core.IFactory;
	
	import twinlist.list.ItemAttribute;
	import twinlist.list.ListItem;
	
	[Bindable]
	public class ActionListItemRendererClass extends MXAdvancedDataGridItemRenderer implements IFactory
	{
		protected var model:Model = Model.Instance;
		private var colName:String;
		private var listName:String;
		
		public function ActionListItemRendererClass(colName:String = "", listName:String = "")
		{
			super();
			ColumnName = colName;
			ListName = listName;
		}
		
		public function newInstance():*
		{
			return new ActionListItemRenderer();
		}
		
		override public function set data(value:Object):void
		{
			if (colName == ActionListClass.BUTTON_COL)
				return;
			var item:ListItem = value as ListItem;
			if (item == null || colName == null)
				return;
			if (colName == "Name")
				label = item.Name;
			var attr:ItemAttribute = item.Attributes[colName];
			if (attr != null)
				label = attr.Values.toString();
		}
		
		public function get ColumnName():String
		{
			return colName;
		}
		public function set ColumnName(name:String):void
		{
			colName = name;
		}
		
		public function get ListName():String
		{
			return listName;
		}
		public function set ListName(name:String):void
		{
			listName = name;
		}
		
		protected function PutBack(event:Event):void
		{
			var item:ListItem;
			if (ListName == ActionListClass.ACCEPT_LIST) {
				item = model.AcceptedListItems[itemIndex];
				model.DelActionListItem(item, true);
			}
			else {
				item = model.RejectedListItems[itemIndex];
				model.DelActionListItem(item, false);
			}
		}
	}
}