package twinlist
{
	import flash.events.Event;
	
	import mx.controls.AdvancedDataGrid;
	import mx.controls.advancedDataGridClasses.AdvancedDataGridColumn;
	import mx.controls.advancedDataGridClasses.MXAdvancedDataGridItemRenderer;
	import mx.core.ClassFactory;
	import mx.events.FlexEvent;
	import mx.events.ListEvent;
	
	import spark.components.Group;
	
	public class ActionListClass extends Group
	{
		[Bindable]
		protected var model:Model = Model.Instance;
		public var dataGrid:AdvancedDataGrid;
		
		public function ActionListClass()
		{
			super();
			this.addEventListener(FlexEvent.CREATION_COMPLETE, onInitComplete);
		}
		
		private function onInitComplete(event:Event):void
		{
			this.removeEventListener(FlexEvent.CREATION_COMPLETE, onInitComplete);
			var columns:Array = dataGrid.columns;
			var col:AdvancedDataGridColumn = new AdvancedDataGridColumn("Name");
			var factory:ClassFactory = new ClassFactory(ActionListItemRenderer);
			factory.properties = {ColumnName:"Name"};
			col.itemRenderer = factory;
			columns.push(col);
			for each (var attr:String in model.ListItemAttributes) {
				col = new AdvancedDataGridColumn(attr);
				factory = new ClassFactory(ActionListItemRenderer);
				factory.properties = {ColumnName:attr};
				col.itemRenderer = factory;
				columns.push(col);
			}			
			dataGrid.columns = columns;
		}
	}
}