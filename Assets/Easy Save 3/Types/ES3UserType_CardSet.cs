using System;
using UnityEngine;

namespace ES3Types
{
	[UnityEngine.Scripting.Preserve]
	[ES3PropertiesAttribute("name", "code", "image", "type", "cardsDefs")]
	public class ES3UserType_CardSet : ES3ObjectType
	{
		public static ES3Type Instance = null;

		public ES3UserType_CardSet() : base(typeof(CardSet)){ Instance = this; priority = 1; }


		protected override void WriteObject(object obj, ES3Writer writer)
		{
			var instance = (CardSet)obj;
			
			writer.WriteProperty("name", instance.name, ES3Type_string.Instance);
			writer.WriteProperty("code", instance.code, ES3Type_string.Instance);
			writer.WritePropertyByRef("image", instance.image);
			writer.WriteProperty("type", instance.type, ES3Internal.ES3TypeMgr.GetOrCreateES3Type(typeof(CardSetType)));
			writer.WriteProperty("cardsDefs", instance.cardsDefs, ES3Internal.ES3TypeMgr.GetOrCreateES3Type(typeof(System.Collections.Generic.List<CardDefinition>)));
		}

		protected override void ReadObject<T>(ES3Reader reader, object obj)
		{
			var instance = (CardSet)obj;
			foreach(string propertyName in reader.Properties)
			{
				switch(propertyName)
				{
					
					case "name":
						instance.name = reader.Read<System.String>(ES3Type_string.Instance);
						break;
					case "code":
						instance.code = reader.Read<System.String>(ES3Type_string.Instance);
						break;
					case "image":
						instance.image = reader.Read<UnityEngine.Sprite>(ES3Type_Sprite.Instance);
						break;
					case "type":
						instance.type = reader.Read<CardSetType>();
						break;
					case "cardsDefs":
						instance.cardsDefs = reader.Read<System.Collections.Generic.List<CardDefinition>>();
						break;
					default:
						reader.Skip();
						break;
				}
			}
		}

		protected override object ReadObject<T>(ES3Reader reader)
		{
			var instance = new CardSet();
			ReadObject<T>(reader, instance);
			return instance;
		}
	}


	public class ES3UserType_CardSetArray : ES3ArrayType
	{
		public static ES3Type Instance;

		public ES3UserType_CardSetArray() : base(typeof(CardSet[]), ES3UserType_CardSet.Instance)
		{
			Instance = this;
		}
	}
}