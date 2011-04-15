package twinlist
{
	import flash.events.Event;
	
	import mx.events.DragEvent;
	
	import spark.components.HSlider;
	import spark.components.VGroup;

	public class NumericalFilterComponent extends FilterComponent
	{
		private var minSlider:HSlider;
		private var maxSlider:HSlider;
		
		public function NumericalFilterComponent(attribute:AttributeDescriptor)
		{
			super();
			if (attribute.Type != ItemAttribute.TYPE_NUMERICAL)
				throw new Error("NumericalFilterComponent only valid for ItemAttribute.TYPE_NUMERICAL.");
			Attribute = attribute;
			var group:VGroup = new VGroup();
			group.minWidth = 200;
			minSlider = new HSlider();
			minSlider.minimum = attribute.Properties[AttributeDescriptor.PROP_MINVAL];
			minSlider.maximum = attribute.Properties[AttributeDescriptor.PROP_MAXVAL];
			minSlider.value = minSlider.minimum;
			minSlider.addEventListener(DragEvent.DRAG_COMPLETE, OnChange);
			group.addElement(minSlider);
			maxSlider = new HSlider();
			maxSlider.minimum = attribute.Properties[AttributeDescriptor.PROP_MINVAL];
			maxSlider.maximum = attribute.Properties[AttributeDescriptor.PROP_MAXVAL];
			maxSlider.value = maxSlider.maximum;
			maxSlider.addEventListener(DragEvent.DRAG_COMPLETE, OnChange);
			group.addElement(maxSlider);
			addElementAt(group, 0);
		}
		
		override public function SelectAll():void
		{
			minSlider.value = minSlider.minimum;
			maxSlider.value = maxSlider.maximum;			
			super.SelectAll();
		}
		
		override public function ClearAll():void
		{
			minSlider.value = minSlider.minimum;
			maxSlider.value = maxSlider.minimum;
			super.ClearAll();
		}
		
		override protected function OnChange(event:Event):void
		{
			if (event.target == minSlider && minSlider.value > maxSlider.value)
				maxSlider.value = minSlider.value;
			else if (maxSlider.value < minSlider.value)
				minSlider.value = maxSlider.value;
			super.OnChange(event);
		}
	}
}