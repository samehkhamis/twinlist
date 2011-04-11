package twinlist
{
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import mx.events.CollectionEvent;
	import mx.events.ListEvent;
	import mx.managers.ToolTipManager;
	
	import spark.components.Group;
	
	public class ListViewerClass extends Group
	{
		[Bindable]
		protected var model:Model = Model.Instance;
		
		public function ListViewerClass()
		{
			super();
		}
		
		protected function OnItemClick(event:ListEvent):void
		{
			model.SelectedItem = GetClickedItem(event);
		}
		
		protected function OnItemDoubleClick(event:ListEvent):void
		{
			var item:ListItem = GetClickedItem(event);
			if (item == null)
				return;
			if (model.ActionListContains(item))
				model.DelActionListItem(item);
			else
				model.AddActionListItem(item);
		}
		
		private function GetClickedItem(event:ListEvent):ListItem
		{
			var rowIdx:int = event.rowIndex;
			var colIdx:int = event.columnIndex;
			var row:ListViewerItem = model.ListViewerData[rowIdx] as ListViewerItem;
			var item:ListItem = null;
			switch (colIdx) {
				case 0: item = row.L1Unique; break;
				case 1: item = row.L1Similar; break;
				case 2: item = row.Identical; break;
				case 3: item = row.L2Similar; break;
				case 4: item = row.L2Unique; break;
			}
			return item;			
		}
		
		private function OnDataChange(event:Event):void
		{
			
		}
	}
}