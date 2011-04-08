package twinlist
{
	import mx.controls.advancedDataGridClasses.MXAdvancedDataGridItemRenderer;
	import mx.messaging.messages.ErrorMessage;
	
	public class ListViewerItemRendererClass extends MXAdvancedDataGridItemRenderer
	{
		public function ListViewerItemRendererClass():void
		{
			super();
		}

		protected function GetBackgroundColor():uint
		{
			if (listData == null)
				return 0xffffff;
			var col:int = listData.columnIndex;
			if ((col == 0) || (col == 4))
				return 0xffcfcf;
			else if ((col == 1) || (col == 3))
				return 0xffecd5;
			return 0xb3fec5;
		}
	}
}