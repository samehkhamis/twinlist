package twinlist
{
	import mx.events.ListEvent;
	
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
			model.SelectedItem = item;
		}
	}
}