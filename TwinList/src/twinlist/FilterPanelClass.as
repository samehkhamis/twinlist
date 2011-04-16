package twinlist {
	
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
		}
		
		private function OnInitComplete(event:FlexEvent):void
		{
			removeEventListener(FlexEvent.CREATION_COMPLETE, OnInitComplete);
			
			// add listeners to buttons
			enableAllBtn.addEventListener(MouseEvent.CLICK, function(e:Event):void {
				setAllFilters(true);
			});
			disableAllBtn.addEventListener(MouseEvent.CLICK, function(e:Event):void {
				setAllFilters(false);
			});
			clearAllBtn.addEventListener(MouseEvent.CLICK, function(e:Event):void {
				clearAllFilters();
			});
			// add a listener for each attribute
			filterComponents = new Object();
			var fc:FilterComponentClass;
			for each (var attr:AttributeDescriptor in model.ItemAttributes) {
				if (attr.Type == ItemAttribute.TYPE_NUMERICAL)
					fc = new NumericalFilterComponent(attr);
				else
					fc = new CategoricalFilterComponent(attr);
				filterGroup.addElement(fc);
				filterComponents[attr.Name] = fc;
			}
		}
		
		private function setAllFilters (option:Boolean): void
		{
			for each (var fc:FilterComponentClass in filterComponents) {
				fc.Checked = option;
			}
		}
		
		private function clearAllFilters(): void
		{
			for each (var fc:FilterComponentClass in filterComponents) {
				fc.ClearAll();
			}
		}
	}
}