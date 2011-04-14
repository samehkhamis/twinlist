package twinlist
{
	import mx.collections.ArrayCollection;
	import mx.controls.dataGridClasses.DataGridListData;
	
	import spark.components.Group;
	import spark.components.List;

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
			for each (var attr:ItemAttribute in item.Attributes) {
				array.addItem(attr);
			}
			return array;
		}
	}	
}