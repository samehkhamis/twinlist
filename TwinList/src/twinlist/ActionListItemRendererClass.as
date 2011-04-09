package twinlist
{
	import mx.controls.advancedDataGridClasses.MXAdvancedDataGridItemRenderer;
	import mx.core.IFactory;
	
	[Bindable]
	public class ActionListItemRendererClass extends MXAdvancedDataGridItemRenderer implements IFactory
	{
		private var colName:String = null;
		
		public function ActionListItemRendererClass()
		{
			super();
		}
		
		public function newInstance():*
		{
			return new ActionListItemRendererClass();
		}
		
		override public function set data(value:Object):void
		{
			var item:ListItem = value as ListItem;
			if (item == null || colName == null)
				return;
			if (colName == "Name")
				label = item.Name;
			var attr:ListItemAttribute = item.Attributes[colName];
			if (attr != null)
				label = attr.Values.toString();
		}
		
		public function get ColumnName():String
		{
			return colName;
		}
		public function set ColumnName(colName:String):void
		{
			this.colName = colName;
		}
	}
}