package twinlist {
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import mx.events.FlexEvent;
	
	import spark.components.*;
	
	import twinlist.list.AttributeDescriptor;
	import twinlist.list.ItemAttribute;
	
	public class FilterPanelClass extends Group
	{
		[Bindable]
		protected var model:Model = Model.Instance;
		public var enableAllBtn:Button;
		public var disableAllBtn:Button;
		public var clearAllBtn:Button;
		[Bindable]
		public var filterGroup:VGroup;
		private var filterComponents:Object;
		
		public function FilterPanelClass()
		{
			super();
			addEventListener(FlexEvent.CREATION_COMPLETE, OnInitComplete);
			model.addEventListener(Model.DATA_LOADED, function(e:Event):void {
				CreateFilters();
			});
		}
		
		private function OnInitComplete(event:FlexEvent):void
		{
			removeEventListener(FlexEvent.CREATION_COMPLETE, OnInitComplete);
			// add listeners to buttons
			enableAllBtn.addEventListener(MouseEvent.CLICK, function(e:Event):void {
				SetAllFilters(true);
			});
			disableAllBtn.addEventListener(MouseEvent.CLICK, function(e:Event):void {
				SetAllFilters(false);
			});
			clearAllBtn.addEventListener(MouseEvent.CLICK, function(e:Event):void {
				ClearAllFilters();
			});
			CreateFilters();
		}
		
		private function CreateFilters():void
		{
			if (filterComponents != null)
				RemoveFilters();
			filterComponents = new Object();
			var fc:FilterComponentClass;
			for each (var attri:AttributeDescriptor in model.ItemAttributes) {
				if (attri.Type == ItemAttribute.TYPE_NUMERICAL)
					fc = new NumericalFilterComponent(attri);
				else
					fc = new CategoricalFilterComponent(attri);
				filterGroup.addElement(fc);
				filterComponents[attri.Name] = fc;
			}
		}
		
		private function RemoveFilters():void
		{
			filterGroup.removeAllElements();
			filterComponents = new Object();
		}
		
		private function SetAllFilters (option:Boolean): void
		{
			for each (var fc:FilterComponentClass in filterComponents) {
				fc.Checked = option;
			}
		}
		
		private function ClearAllFilters(): void
		{
			for each (var fc:FilterComponentClass in filterComponents) {
				fc.ClearAll();
			}
		}
	}
}
