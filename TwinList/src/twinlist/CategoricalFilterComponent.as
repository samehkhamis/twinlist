package twinlist
{
	import flash.events.Event;
	
	import spark.components.List;
	import spark.events.IndexChangeEvent;
	import spark.layouts.VerticalLayout;
	
	import twinlist.filter.CategoricalAttributeFilter;
	import twinlist.list.AttributeDescriptor;

	public class CategoricalFilterComponent extends FilterComponent
	{
		private var lb:List;
		
		public function CategoricalFilterComponent(attribute:AttributeDescriptor)
		{
			super();
			Attribute = attribute;
			lb = new spark.components.List();
			var layout:VerticalLayout = new VerticalLayout();
			layout.requestedRowCount = 4;
			lb.layout = layout;
			lb.minWidth = 200;
			lb.allowMultipleSelection = true;
			lb.dataProvider = attribute.Values;
			lb.addEventListener(IndexChangeEvent.CHANGE, OnChange);
			addElementAt(lb, 0);
			filter = new CategoricalAttributeFilter(attribute.Name);
		}
		
		override public function SelectAll():void
		{
			var allIdx:Vector.<int> = new Vector.<int>(Attribute.Values.length);
			for (var i:int = 0; i < allIdx.length; i++) {
				allIdx[i] = i;
			}
			lb.selectedIndices = allIdx;
			(filter as CategoricalAttributeFilter).Values = Attribute.Values.toArray();
			super.SelectAll();
		}
		
		override public function ClearAll():void
		{
			lb.selectedIndex = -1;
			(filter as CategoricalAttributeFilter).Values = new Array();
			super.ClearAll();
		}
		
		override protected function OnChange(event:Event):void
		{
			var values:Array = new Array(lb.selectedItems.length);
			for (var i:int = 0; i < values.length; i++) {
				values[i] = lb.selectedItems[i];
			}
			(filter as CategoricalAttributeFilter).Values = values;
			super.OnChange(event);
		}
	}
}