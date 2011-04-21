package twinlist
{
	import spark.components.Group;
	
	public class ActionListDockClass extends Group
	{
		[Bindable]
		protected var model:Model = Model.Instance;
		[Bindable]
		protected var visibleActionListIdx:int = 0;

		public function ActionListDockClass()
		{
			super();
			model.addEventListener(Model.ACTION_TAKEN, OnActionTaken);
		}
		
		private function OnActionTaken(event:Event):void
		{
			visibleActionListIdx = model.VisibleActionListIndex;
		}
	}
}