package twinlist
{
	import flash.events.Event;
	
	import mx.collections.ArrayCollection;
	import mx.containers.*;
	import mx.core.*;
	import mx.events.FlexEvent;
	
	import spark.components.Group;
	import spark.components.List;
	import spark.events.IndexChangeEvent;
	import spark.layouts.VerticalLayout;
	
	public class AttributeFilterComponentClass extends Group
	{
		
		[Bindable]
		protected var model:Model = Model.Instance;
		[Bindable]
		protected var attributes:ArrayCollection;
		[Bindable]
		protected var attrToShow:ArrayCollection;
		[Bindable]
		public var lb:List;
		
		public function AttributeFilterComponentClass()
		{
			super();
			model.addEventListener(Model.DATA_LOADED, function(e:Event):void {
				Attributes = model.AllAttributes;
			});
		}
		
		public function get Attributes():ArrayCollection
		{
			return attributes;
		}
		public function set Attributes(attributes:ArrayCollection):void
		{
			this.attributes = attributes;
			SelectAll();
		}
		
		protected function OnSelectAll(event:Event):void
		{
			SelectAll();
		}
		
		protected function OnClearAll(event:Event):void
		{
			ClearAll();
		}
		
		protected function OnChange(event:Event):void
		{
			var values:Array = new Array(lb.selectedItems.length);
			for (var i:int = 0; i < values.length; i++) {
				values[i] = lb.selectedItems[i];
			}
			attrToShow = new ArrayCollection(values);
			model.ShownAttributes = attrToShow;
		}
		
		private function SelectAll():void
		{
			var allIdx:Vector.<int> = new Vector.<int>(attributes.length);
			for (var i:int = 0; i < allIdx.length; i++) {
				allIdx[i] = i;
			}
			lb.selectedIndices = allIdx;
			attrToShow = new ArrayCollection(attributes.toArray());
			model.ShownAttributes = attrToShow;
		}
		
		private function ClearAll():void
		{
			lb.selectedIndex = -1;
			attrToShow = new ArrayCollection();
			model.ShownAttributes = attrToShow;
		}
	}
}