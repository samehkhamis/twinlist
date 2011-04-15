package twinlist
{
	import flash.events.Event;
	
	import mx.controls.HSlider;
	import mx.events.SliderEvent;
	
	import spark.components.Label;
	import spark.components.VGroup;
	
	import twinlist.filter.NumericalFilter;

	public class NumericalFilterComponent extends FilterComponent
	{
		private var slider:HSlider;
		
		public function NumericalFilterComponent(attribute:AttributeDescriptor)
		{
			super();
			if (attribute.Type != ItemAttribute.TYPE_NUMERICAL)
				throw new Error("NumericalFilterComponent only valid for ItemAttribute.TYPE_NUMERICAL.");
			Attribute = attribute;
			var minVal:Number = attribute.Properties[AttributeDescriptor.PROP_MINVAL];
			var maxVal:Number = attribute.Properties[AttributeDescriptor.PROP_MAXVAL];
			var vg:VGroup = new VGroup();
			var lbl:Label;
			vg.minWidth = 200;
			lbl = new Label();
			lbl.text = "Lower Bound";
			vg.addElement(lbl);
			slider = new HSlider();
			slider.width = 200;
			slider.thumbCount = 2;
			slider.allowThumbOverlap = false;
			slider.minimum = minVal;
			slider.maximum = maxVal;
			slider.labels = [minVal, maxVal];
			slider.values = [minVal, maxVal];
			slider.addEventListener(SliderEvent.THUMB_RELEASE, OnChange);
			vg.addElement(slider);
			addElementAt(vg, 0);
			filter = new NumericalFilter(attribute.Name, minVal, maxVal);
		}
		
		override public function SelectAll():void
		{
			slider.values = [slider.minimum, slider.maximum];
			super.SelectAll();
		}
		
		override public function ClearAll():void
		{
			slider.values = [slider.minimum, slider.maximum];
			super.ClearAll();
		}
		
		override protected function OnChange(event:Event):void
		{
			var f:NumericalFilter = filter as NumericalFilter;
			f.MinValue = slider.values[0];
			f.MaxValue = slider.values[1];
			super.OnChange(event);
		}
	}
}