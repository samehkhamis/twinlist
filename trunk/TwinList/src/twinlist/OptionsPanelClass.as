package twinlist
{
	import flash.events.Event;
	
	import spark.components.CheckBox;
	import spark.components.Group;
	import spark.components.NumericStepper;
	import spark.components.RadioButtonGroup;

	public class OptionsPanelClass extends Group
	{
		[Bindable]
		protected var model:Model = Model.Instance;
		
		public function OptionsPanelClass()
		{
			super();
		}
		
		protected function OnFontSizeChange(event:Event):void
		{
			var tgt:NumericStepper = event.target as NumericStepper;
			model.SetOption(new Option(Option.OPT_FONTSIZE, tgt.value));
		}
		
		protected function OnLinkIdenticalChange(event:Event):void
		{
			var tgt:CheckBox = event.target as CheckBox;
			model.SetOption(new Option(Option.OPT_LINKIDENTICAL, tgt.selected));
		}
		
		protected function OnAfterActionChange(event:Event):void
		{
			var tgt:RadioButtonGroup = event.target as RadioButtonGroup;
			model.SetOption(new Option(Option.OPT_AFTERACTION, tgt.selectedValue as String));
		}
	}
}