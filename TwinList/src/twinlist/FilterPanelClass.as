package twinlist {
	
	import com.carlcalderon.arthropod.Debug;
	
	import mx.collections.ArrayCollection;
	import mx.controls.CheckBox;
	import mx.events.FlexEvent;
	
	import spark.components.*;
	
	public class FilterPanelClass extends VGroup
	{
		[Bindable]
		protected var model:Model = Model.Instance;
		private var listGeneral:Array = new Array();
		private var listCateg:Array = new Array();
		private var listNumer:Array = new Array();
		
		public function FilterPanelClass()
		{
			super();
			addEventListener(FlexEvent.CREATION_COMPLETE, OnInitComplete);
		}
		
		private function OnButtonDown(event:mx.events.FlexEvent):void {

			var b:Button = event.target as Button;
			switch (b.label) {
				case "Select all": 
					setOrResetFilters (true);
					break;
				case "De-select all":
					setOrResetFilters (false);
				case "Clear all":
					clearAllKeyValues ();
					break;
				case "Apply filters":
					Debug.log("Still not decided!");
			}			
			
		}
		
		private function OnInitComplete(event:mx.events.FlexEvent):void {

			removeEventListener(FlexEvent.CREATION_COMPLETE, OnInitComplete);

			// Add a filter component to name attribute
			var l:spark.components.Label=new spark.components.Label();
			l.text="General";
			l.setStyle("fontWeight","bold");
			addElement(l);
			var fc:FilterComponent = new FilterComponent(ItemAttribute.TYPE_GENERAL, "Name");
			addElement(fc);
			listGeneral["Name"]=fc;

			
			// Add filter components to categorical attributes
			if (model.CategoricalAttributes.length > 0) {
				
				l=new spark.components.Label();
				l.text="Categorical Attributes";
				l.setStyle("fontWeight","bold");
				addElement(l);
			
				for each (var attr:String in model.CategoricalAttributes) {
					Debug.log(attr);
					fc = new FilterComponent(ItemAttribute.TYPE_CATEGORICAL, attr);
					addElement(fc);
					listCateg[attr]=fc;
				}
			}

			// Add filter components to numerical attributes
			if (model.NumericalAttributes.length > 0) {
				
				l=new spark.components.Label();
				l.text="Categorical Attributes";
				l.setStyle("fontWeight","bold");
				addElement(l);
				
				for each (attr in model.NumericalAttributes) {
					Debug.log(attr);
					fc = new FilterComponent(ItemAttribute.TYPE_CATEGORICAL, attr);
					addElement(fc);
					listCateg[attr]=fc;
				}
			}
			
			var buttonPanel:HGroup=new HGroup();
			
			// Add Apply filters button
			var b:Button = new Button();
			b.label="Apply filters";
			buttonPanel.addElement(b);
			b.addEventListener(FlexEvent.BUTTON_DOWN,OnButtonDown);
			
			// Add select all button
			b = new Button();
			b.label="Select all";
			buttonPanel.addElement(b);
			b.addEventListener(FlexEvent.BUTTON_DOWN,OnButtonDown);
			
			// Add de-select all button
			b = new Button();
			b.label="De-select all";
			buttonPanel.addElement(b);
			b.addEventListener(FlexEvent.BUTTON_DOWN,OnButtonDown);
			
			// Add clear all button
			b = new Button();
			b.label="Clear all";
			buttonPanel.addElement(b);
			b.addEventListener(FlexEvent.BUTTON_DOWN,OnButtonDown);
			
			addElement(buttonPanel);

		}
		
		private function setOrResetFilters (option:Boolean): void {
		// Set/reset selections
			
			// General
			var fc:FilterComponent=listGeneral["Name"] as FilterComponent;
			Debug.log(fc.Checked);
			fc.Checked=option;
			
			// Categ
			for each (var attr:String in model.CategoricalAttributes) {
				fc=listCateg[attr] as FilterComponent;
				Debug.log(fc.Checked);
				fc.Checked=option;
			}
			// Numer
			for each (attr in model.NumericalAttributes) {
				fc=listNumer[attr] as FilterComponent;
				Debug.log(fc.Checked);
				fc.Checked=option;
			}
			
		}
		
		private function clearAllKeyValues(): void {
			
			// General
			var fc:FilterComponent=listGeneral["Name"] as FilterComponent;
			fc.KeyValue="";
			
			// Categ
			for each (var attr:String in model.CategoricalAttributes) {
				fc=listCateg[attr] as FilterComponent;
				fc.KeyValue="";
			}
			// Numer
			for each (attr in model.NumericalAttributes) {
				fc=listNumer[attr] as FilterComponent;
				fc.KeyValue="";
			}
			
			
			

		}
}		
		

}