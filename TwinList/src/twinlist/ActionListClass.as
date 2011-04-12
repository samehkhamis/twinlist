package twinlist
{
	import flash.events.Event;
	
	import mx.collections.Sort;
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
		private static var defaultSort:Sort
		
		public function ActionListClass()
		{
			super();
			defaultSort = new Sort();
			this.addEventListener(FlexEvent.CREATION_COMPLETE, onInitComplete);
		}
		
		private function onInitComplete(event:Event):void
		{
			this.removeEventListener(FlexEvent.CREATION_COMPLETE, onInitComplete);
			var columns:Array = dataGrid.columns;
			var col:AdvancedDataGridColumn;
			var factory:ClassFactory;
			for each (var attr:String in model.ListItemAttributes) {
				col = new AdvancedDataGridColumn(attr);
				factory = new ClassFactory(ActionListItemRenderer);
				factory.properties = {ColumnName:attr};
				col.itemRenderer = factory;
				if (attr != "Name") {
					col.sortable = false;
//					col.sortCompareFunction = function(a:Object, b:Object, fields:Array):int {
//						var val1:Object = (a as ListItem).Attributes[attr][0];
//						var val2:Object = (b as ListItem).Attributes[attr][0];
//						return defaultSort.compareFunction.call(null, val1, val2, null);
//					};
				}
				columns.push(col);
			}			
			dataGrid.columns = columns;
		}
	}
}