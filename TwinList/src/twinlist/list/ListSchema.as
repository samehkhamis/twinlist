package twinlist.list
{
	import twinlist.list.AttributeDescriptor;

        [Bindable]
        public class ListSchema
	{
	  private var srcFile:String;
	  private var attributes:Object;

	  public function ListSchema()
	  {
	    attributes = new Object();
	  }
	  public function addAttribute(name:String,  attrDescriptor:AttributeDescriptor):void
	  {
	    attributes[name]=attrDescriptor;
	  }
	  public function get Attributes():Object
	  {
	    return attributes;
	  }
	}
}