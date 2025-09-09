using System;
using UnityEngine;

namespace ES3Types
{
	[UnityEngine.Scripting.Preserve]
	[ES3PropertiesAttribute("id", "name", "imageKey", "rarity", "setCode", "tribe", "element", "cost", "attack", "health", "marketForces", "basePrice")]
	public class ES3UserType_CardDefinition : ES3ObjectType
	{
		public static ES3Type Instance = null;

		public ES3UserType_CardDefinition() : base(typeof(CardDefinition)){ Instance = this; priority = 1; }


		protected override void WriteObject(object obj, ES3Writer writer)
		{
			var instance = (CardDefinition)obj;
			
			writer.WriteProperty("id", instance.id, ES3Type_string.Instance);
			writer.WriteProperty("name", instance.name, ES3Type_string.Instance);
			writer.WriteProperty("imageKey", instance.imageKey, ES3Type_string.Instance);
			writer.WriteProperty("rarity", instance.rarity, ES3Internal.ES3TypeMgr.GetOrCreateES3Type(typeof(Rarity)));
			writer.WriteProperty("setCode", instance.setCode, ES3Type_string.Instance);
			writer.WriteProperty("tribe", instance.tribe, ES3Internal.ES3TypeMgr.GetOrCreateES3Type(typeof(CardTribe)));
			writer.WriteProperty("element", instance.element, ES3Internal.ES3TypeMgr.GetOrCreateES3Type(typeof(CardElement)));
			writer.WriteProperty("cost", instance.cost, ES3Type_int.Instance);
			writer.WriteProperty("attack", instance.attack, ES3Type_int.Instance);
			writer.WriteProperty("health", instance.health, ES3Type_int.Instance);
			writer.WriteProperty("marketForces", instance.marketForces, ES3Internal.ES3TypeMgr.GetOrCreateES3Type(typeof(System.Collections.Generic.List<MarketForceType>)));
			writer.WriteProperty("basePrice", instance.basePrice, ES3Type_float.Instance);
		}

		protected override void ReadObject<T>(ES3Reader reader, object obj)
		{
			var instance = (CardDefinition)obj;
			foreach(string propertyName in reader.Properties)
			{
				switch(propertyName)
				{
					
					case "id":
						instance.id = reader.Read<System.String>(ES3Type_string.Instance);
						break;
					case "name":
						instance.name = reader.Read<System.String>(ES3Type_string.Instance);
						break;
					case "imageKey":
						instance.imageKey = reader.Read<System.String>(ES3Type_string.Instance);
						break;
					case "rarity":
						instance.rarity = reader.Read<Rarity>();
						break;
					case "setCode":
						instance.setCode = reader.Read<System.String>(ES3Type_string.Instance);
						break;
					case "tribe":
						instance.tribe = reader.Read<CardTribe>();
						break;
					case "element":
						instance.element = reader.Read<CardElement>();
						break;
					case "cost":
						instance.cost = reader.Read<System.Int32>(ES3Type_int.Instance);
						break;
					case "attack":
						instance.attack = reader.Read<System.Int32>(ES3Type_int.Instance);
						break;
					case "health":
						instance.health = reader.Read<System.Int32>(ES3Type_int.Instance);
						break;
					case "marketForces":
						instance.marketForces = reader.Read<System.Collections.Generic.List<MarketForceType>>();
						break;
					case "basePrice":
						instance.basePrice = reader.Read<System.Single>(ES3Type_float.Instance);
						break;
					default:
						reader.Skip();
						break;
				}
			}
		}

		protected override object ReadObject<T>(ES3Reader reader)
		{
			var instance = new CardDefinition();
			ReadObject<T>(reader, instance);
			return instance;
		}
	}


	public class ES3UserType_CardDefinitionArray : ES3ArrayType
	{
		public static ES3Type Instance;

		public ES3UserType_CardDefinitionArray() : base(typeof(CardDefinition[]), ES3UserType_CardDefinition.Instance)
		{
			Instance = this;
		}
	}
}