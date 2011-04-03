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
	}	
}