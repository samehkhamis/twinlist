package twinlist
{
	import flash.events.Event;
	
	import mx.collections.ArrayCollection;
	import mx.controls.dataGridClasses.DataGridListData;
	
	import spark.components.Group;
	import spark.components.List;
	
	import twinlist.list.ItemAttribute;
	import twinlist.list.ListItem;

	public class DetailPanelClass extends Group
	{
		[Bindable]
		protected var model:Model = Model.Instance;
		
		public function DetailPanelClass()
		{
			super();
		}
		
		protected function GetAttributes(item:ListItem):ArrayCollection
		{
			var array:ArrayCollection = new ArrayCollection();
			if (item != null) {
				for each (var attr:ItemAttribute in item.Attributes) {
					array.addItem({Name:attr.toString(), Values:attr.Values});
				}
			}
			return array;
		}
	}	
}